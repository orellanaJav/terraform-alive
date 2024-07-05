output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "value of the S3 bucket ARN"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.terraform_locks.arn
  description = "value of the DynamoDB table ARN"
}
