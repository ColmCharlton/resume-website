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

resource "aws_s3_bucket" "resume_website" {
  bucket = "resume-website-${random_id.bucket_suffix.hex}"
  acl    = "public-read" # Change to a fine grained policy
  policy = data.aws_iam_policy_document.s3_public_read.json

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
    enabled = true
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

data "aws_iam_policy_document" "s3_public_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::resume-website-${random_id.bucket_suffix.hex}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_cloudfront_distribution" "resume_distribution" {
  origin {
    domain_name = aws_s3_bucket.resume_website.website_endpoint
    origin_id   = "S3-resume-website"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
   
    tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
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
    cloudfront_default_certificate = true # Use ACM for custom domain 
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
  filename      = "lambda/visitor-counter.zip"
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

resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

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

resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_least_privilege.arn
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

resource "aws_api_gateway_method" "visitor_get" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.visitor.id
  http_method   = "GET"
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

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "resume_api_deployment" {
  depends_on = [aws_api_gateway_integration.visitor_integration]

  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  stage_name  = "prod"
}

resource "aws_ses_domain_identity" "resume_domain" {
  domain = var.domain_name

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

resource "aws_lambda_function" "contact_form" {
  filename      = "lambda/contact-form.zip"
  function_name = "resume_contact_form"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

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

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}

data "aws_ssm_parameter" "github_token" {
  name            = "/resume/github_token"
  with_decryption = true
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
      owner            = "ThirdParty"
      provider         = "GitHub"
      version         = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.branch
        # OAuthToken = var.github_token
        OAuthToken = data.aws_ssm_parameter.github_token.value

        # aws ssm put-parameter --name "/resume/github_token" --value "ghp_YourGitHubTokenHere" --type "SecureString"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        BucketName = aws_s3_bucket.resume_website.bucket
        Extract    = "true"
      }
    }
  }

  tags = {
    Project     = "ResumeWebsite"
    Environment = "Production"
  }
}
