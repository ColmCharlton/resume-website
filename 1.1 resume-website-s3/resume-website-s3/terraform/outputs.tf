output "s3_bucket_name" {
  value = aws_s3_bucket.website_bucket.id
}

output "lambda_contact_arn" {
  value = aws_lambda_function.contact_form.arn
}

output "ses_verification_status" {
  value = aws_ses_email_identity.contact.verification_status
}