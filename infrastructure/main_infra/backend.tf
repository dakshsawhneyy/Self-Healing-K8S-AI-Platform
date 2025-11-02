terraform {
  backend "s3" {
    bucket = "self-healing-k8s-platform-sf"
    region = "ap-south-1"
    key = "daksh/terraform.tfstate"
    dynamodb_table = "terraform_lock"
  }
}