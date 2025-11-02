variable "bucket_name" {
  type = string
  default = "Self-Healing-K8S-AI-Platform"
}

variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "project_name" {
  type = string
  default = "Self-Healing-K8S-Platform"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  type = bool
  default = true
}

variable "kubernetes_version" {
  type        = string
  default     = "1.29"
}