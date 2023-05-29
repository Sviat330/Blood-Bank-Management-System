data "aws_availability_zones" "available" {
  state = "available"
}

variable "region" {
  description = "Region in which resources will be deployed"
  default     = "eu-north-1"
}

variable "vpc_cidr_block" {
  description = "VPC cidr block "
  default     = "10.0.0.0/16"
}

variable "env_code" {
  description = "Environment Code (dev|test|stg|prod) For development, test, staging, production."
  default     = "test"
}

variable "public_cidr_blocks" {
  type        = list(string)
  description = "Public subnet cidr blocks "
  default = [
    "10.0.11.0/24",
    "10.0.21.0/24"
  ]
}

variable "private_cidr_blocks" {
  type        = list(string)
  description = "Public subnet cidr blocks "
  default = [
    "10.0.12.0/24",
    "10.0.22.0/24"
  ]
}


