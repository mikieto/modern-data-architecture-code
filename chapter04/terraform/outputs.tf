# ------------------------------------------------------------------------------
# Output Definitions
# ------------------------------------------------------------------------------
output "bronze_bucket_name" {
  description = "Name of the Bronze S3 bucket"
  value       = aws_s3_bucket.bronze.id
}

output "silver_bucket_name" {
  description = "Name of the Silver S3 bucket"
  value       = aws_s3_bucket.silver.id
}

output "gold_bucket_name" {
  description = "Name of the Gold S3 bucket"
  value       = aws_s3_bucket.gold.id
}

output "ingestion_role_arn" {
  description = "ARN of the IAM role for data ingestion"
  value       = aws_iam_role.ingestion_role.arn
}

output "transformation_role_arn" {
  description = "ARN of the IAM role for data transformation"
  value       = aws_iam_role.transformation_role.arn
}

# output "analytics_role_arn" {
#   description = "ARN of the IAM role for data analytics"
#   value       = aws_iam_role.analytics_role.arn # If analytics_role is defined
# }