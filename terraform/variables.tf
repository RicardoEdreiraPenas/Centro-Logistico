variable "region" {
  description = "AWS region for EC2 and RDS"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for EC2 instances"
  type        = string
}
