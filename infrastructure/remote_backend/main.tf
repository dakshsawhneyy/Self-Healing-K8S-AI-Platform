resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# Locking mechanism using DynamoDB
resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}