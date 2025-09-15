terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Remove the public read policy data source and IAM policy resources for putting bucket policy,
# as the bucket should be private and accessed only via CloudFront with OAC.
resource "aws_s3_bucket" "resume_website" {
  bucket = "resume-website-${random_id.bucket_suffix.hex}"

  #Enable versioning for safety
  versioning {
    enabled = true
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

# 4. Create an Origin Access Control (OAC) for CloudFront to access the private S3 bucket
resource "aws_cloudfront_origin_access_control" "resume_oac" {
  name                              = "resume-website-oac-${random_id.bucket_suffix.hex}"
  description                       = "OAC for resume website S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always" # Sign requests (recommended)
  signing_protocol                  = "sigv4"
}

# 5. Update the S3 bucket policy to allow access only from CloudFront using the OAC
data "aws_iam_policy_document" "s3_oac_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resume_website.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.resume_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "resume_website_policy" {
  bucket = aws_s3_bucket.resume_website.id
  policy = data.aws_iam_policy_document.s3_oac_access.json
}

# 6. Ensure public access is blocked on the S3 bucket
resource "aws_s3_bucket_public_access_block" "resume_website" {
  bucket                  = aws_s3_bucket.resume_website.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# resource "random_id" "index_version" {
#   byte_length = 4
# }

# #Update the CloudFront distribution to use the S3 bucket's regional endpoint and OAC
# resource "aws_s3_object" "index_file" {
#   bucket = aws_s3_bucket.resume_website.id
#   key    = "index-${random_id.index_version.hex}.html"
#   content = templatefile("${path.module}/../frontend/index.html.tpl", {
#     backend_api_url = aws_api_gateway_deployment.resume_api_deployment.invoke_url
#     index_version   = random_id.index_version.hex

#     # backend_api_url = module.resume_api.api_base_url
#   })
#   content_type = "text/html"
# }

# resource "aws_s3_object" "styles_css" {
#   bucket       = aws_s3_bucket.resume_website.id
#   key          = "styles-${random_id.index_version.hex}.css"
#   content      = file("${path.module}/../frontend/styles.css")
#   content_type = "text/css"
# }

# resource "aws_s3_object" "scripts_js" {
#   bucket       = aws_s3_bucket.resume_website.id
#   key          = "scripts-${random_id.index_version.hex}.js"
#   content      = templatefile("${path.module}/../frontend/scripts.js", {
#     backend_api_url = aws_api_gateway_deployment.resume_api_deployment.invoke_url
#   })
#   content_type = "application/javascript"
# }

#Update the CloudFront distribution to use the S3 bucket's regional endpoint and OAC
resource "aws_cloudfront_distribution" "resume_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.resume_website.bucket_regional_domain_name
    origin_id                = "S3-resume-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.resume_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-resume-website"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_dynamodb_table" "visitor_count" {
  name         = "ResumeVisitorCount"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
  
  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_lambda_function" "visitor_counter" {
  filename      = "../lambda/visitor-counter/visitor-form.zip"
  function_name = "resume_visitor_counter"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_count.name
    }
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }

}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

# resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
# }

resource "aws_iam_policy" "lambda_dynamodb_least_privilege" {
  name        = "lambda-dynamodb-least-privilege"
  description = "Least privilege policy for Lambda to access DynamoDB table"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.visitor_count.arn
      }
    ]
  })
}

resource "aws_ses_email_identity" "contact" {
  email = "columcharlton@gmail.com"
}

# SES SendEmail policy for Lambda contact form
resource "aws_iam_policy" "lambda_ses_send_email" {
  name        = "lambda-ses-send-email"
  description = "Allow Lambda to send email via SES for contact form"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "arn:aws:ses:eu-west-1:458879677191:identity/columcharlton@gmail.com"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_least_privilege.arn
}

# Attach SES SendEmail policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ses" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ses_send_email.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_api_gateway_rest_api" "resume_api" {
  name        = "ResumeWebsiteAPI"
  description = "API for resume website backend services"

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_api_gateway_resource" "visitor" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_rest_api.resume_api.root_resource_id
  path_part   = "visitor"
}

# Contact form API Gateway resource
resource "aws_api_gateway_resource" "contact" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_rest_api.resume_api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "visitor_get" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.visitor.id
  http_method   = "GET"
  authorization = "NONE"
}

# Contact form API Gateway method (POST)
resource "aws_api_gateway_method" "contact_post" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "visitor_integration" {
  rest_api_id             = aws_api_gateway_rest_api.resume_api.id
  resource_id             = aws_api_gateway_resource.visitor.id
  http_method             = aws_api_gateway_method.visitor_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter.invoke_arn
}

# Contact form API Gateway integration
resource "aws_api_gateway_integration" "contact_integration" {
  rest_api_id             = aws_api_gateway_rest_api.resume_api.id
  resource_id             = aws_api_gateway_resource.contact.id
  http_method             = aws_api_gateway_method.contact_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_form.invoke_arn
}


# Visitor GET method response for CORS
resource "aws_api_gateway_method_response" "visitor_get_cors" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.visitor.id
  http_method = "GET"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "visitor_get_cors" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.visitor.id
  http_method = aws_api_gateway_method.visitor_get.http_method
  status_code = "200"

  depends_on = [aws_api_gateway_method_response.visitor_get_cors]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# Contact POST method response for CORS
resource "aws_api_gateway_method_response" "contact_post_cors" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = "POST"
  status_code = "200"

  depends_on = [aws_api_gateway_method_response.contact_post_cors]

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "contact_post_cors" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*/*"
}

# Contact form Lambda permission for API Gateway
resource "aws_lambda_permission" "apigw_contact_lambda" {
  statement_id  = "AllowExecutionFromAPIGatewayContact"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "resume_api_deployment" {
  depends_on = [aws_api_gateway_integration.visitor_integration, aws_api_gateway_integration.contact_integration]

  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  stage_name  = "prod"
}

# Store the API base URL in SSM Parameter Store for CI/CD consumption
resource "aws_ssm_parameter" "api_base_url" {
  name  = "/resume/api_base_url"
  type  = "String"
  value = aws_api_gateway_deployment.resume_api_deployment.invoke_url

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_ses_domain_identity" "resume_domain" {
  domain = aws_s3_bucket.resume_website.website_endpoint

}

resource "aws_lambda_function" "contact_form" {
  filename      = "../lambda/contact-form/contact-form.zip"
  function_name = "resume_contact_form"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      EMAIL_RECIPIENT = var.contact_email
    }
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_cloudwatch_dashboard" "resume_dashboard" {
  dashboard_name = "ResumeWebsiteDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/S3", "NumberOfObjects", "StorageType", "AllStorageTypes", "BucketName", aws_s3_bucket.resume_website.bucket],
            ["AWS/CloudFront", "Requests", "DistributionId", aws_cloudfront_distribution.resume_distribution.id, "Region", "Global"]
          ]
          period = 300
          stat   = "Sum"
          region = "eu-west-1"
          title  = "Website Metrics"
        }
      }
    ]
  })


}

data "aws_ssm_parameter" "github_token" {
  name            = "/resume/github_token"
  with_decryption = true
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "codepipeline_s3_access" {
  name        = "CodePipelineS3Access"
  description = "Allows CodePipeline to read/write to resume website S3 buckets"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "${aws_s3_bucket.resume_website.arn}",
          "${aws_s3_bucket.resume_website.arn}/*",
          "arn:aws:s3:::resume-website-*/resume-website-pipel/source_out/*.zip",
          "arn:aws:s3:::resume-website-*/1.1"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_s3_access.arn
}

# Allow CodePipeline to trigger CodeBuild projects
resource "aws_iam_role_policy" "codepipeline_codebuild_access" {
  name = "codepipeline-codebuild-access"
  role = aws_iam_role.codepipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetProjects"
        ],
        Resource = [
          aws_codebuild_project.resume_build.arn,
          aws_codebuild_project.resume_deploy.arn,
          aws_codebuild_project.resume_invalidate.arn, 
          aws_codebuild_project.resume_tests.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds"
        ],
        Resource = "*"
      }
    ]
  })
}

  # Allow CodePipeline to use CodeStar Connection
  resource "aws_iam_role_policy" "codepipeline_codestar_connection_access" {
    name = "codepipeline-codestar-connection-access"
    role = aws_iam_role.codepipeline_role.id
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "codestar-connections:UseConnection"
          ]
          Resource = "arn:aws:codestar-connections:eu-west-1:458879677191:connection/28ea39b0-67ac-4d0c-bf31-36abdab9d4c1"
        }
      ]
    })
  }

# CodeBuild service role for build stage
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Minimal permissions for CodeBuild: logs, SSM parameter read, S3 access to artifact bucket
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-inline-policy"
  role = aws_iam_role.codebuild_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "${aws_s3_bucket.resume_website.arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:AbortMultipartUpload"
        ],
        Resource = "${aws_s3_bucket.resume_website.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:CreateInvalidation"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_codebuild_project" "resume_build" {
  name         = "resume-website-build"
  description  = "Builds the static site and injects API base URL from SSM"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../buildspec.build.yml")

    }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_codebuild_project" "resume_invalidate" {
  name         = "resume-website-invalidate"
  description  = "Invalidates CloudFront index.html after deploy"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../buildspec.invalidate.yml")
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_codebuild_project" "resume_deploy" {
  name         = "resume-website-deploy"
  description  = "Uploads built files to S3 with proper Cache-Control headers"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../buildspec.deploy.yml")
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_codebuild_project" "resume_tests" {
  name         = "resume-website-tests"
  description  = "Runs Lambda unit tests with Jest"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../buildspec.test.yaml")
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_codepipeline" "resume_pipeline" {
  name     = "resume-website-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.resume_website.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName = var.github_branch
        DetectChanges = "true"
      }
    }
  }


  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.resume_build.name
      }
    }
  }

  stage {
    name = "Test"
    action {
      name             = "UnitTests"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["test_output"]

      configuration = {
        ProjectName = aws_codebuild_project.resume_tests.name
      }
    }
  }


  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.resume_deploy.name
        EnvironmentVariables = jsonencode([
          { name = "BUCKET", value = aws_s3_bucket.resume_website.bucket, type = "PLAINTEXT" }
        ])
      }
    }
  }

  stage {
    name = "Invalidate"
    action {
      name            = "InvalidateIndex"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.resume_invalidate.name
        EnvironmentVariables = jsonencode([
          { name = "DISTRIBUTION_ID", value = aws_cloudfront_distribution.resume_distribution.id, type = "PLAINTEXT" }
        ])
      }
    }
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}
