output "aws_s3_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "aws_dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock.name
}

output "aws_dynamodb_table_billing_mode" {
  value = aws_dynamodb_table.terraform_lock.billing_mode
}

output "aws_dynamodb_table_hash_key" {
  value = aws_dynamodb_table.terraform_lock.hash_key
}