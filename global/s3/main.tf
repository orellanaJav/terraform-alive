provider "aws" {
  region = "us-east-2"

}

variable "aws_s3_bucket_state" {
  type        = string
  description = "The name of the S3 bucket to store Terraform state"
  default     = "terraform-state-510693472221"
}

variable "aws_dynamodb_table_state" {
  type        = string
  description = "The name of the DynamoDB table to store Terraform state locks"
  default     = "terraform-locks-510693472221"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.aws_s3_bucket_state

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so you can see the full revision history of your state files.
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable servier-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.aws_dynamodb_table_state
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-state-510693472221"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-locks-510693472221"
    encrypt        = true
  }
}
