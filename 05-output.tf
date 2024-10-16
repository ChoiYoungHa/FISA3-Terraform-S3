# 05-output.tf

output "website_endpoint" {
  value       = aws_s3_bucket.website_bucket.website_endpoint
  description = "The endpoint for the S3 bucket website."
}