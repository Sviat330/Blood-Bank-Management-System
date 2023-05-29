variable "env_code" {
  description = "Environment Code (dev|test|stg|prod) For development, test, staging, production."
  default     = "test"
}

variable "vpc_id" {
  description = "VPC id of target group "
}

variable "alb_port" {
  description = "port  security group for alb"
  default     = 80
}

variable "public_subnets_id" {
  description = "A list of subnet IDs to attach to the LB"
}
variable "ecs_name" {
  description = "Unique  name of ecs "
  default     = "bloodbank"
}
variable "ecs_family" {
  description = "Unique family name of task definition "
  default     = "bloodbank"
}

variable "app_name" {
  description = "Container name"
  default     = ["fpm", "nginx"]
}
variable "ecr_repo" {
  default = ["454340114714.dkr.ecr.eu-north-1.amazonaws.com/fpm", "454340114714.dkr.ecr.eu-north-1.amazonaws.com/nginx"]
}
/*
variable "s3_env_file" {
  description = "S3 arn that contains env file for container"

}
*/
variable "container_ports" {
  description = "Container ports on which containers running"
  default     = [9000, 80]
}

variable "ecs_cluster_name" {
  description = "Name of ecs cluster"
  default     = "bloodbank"
}

variable "instance_ami" {
  description = "AMI for launch template"
  default     = "ami-03cea695e051031be"
}

variable "conts_desired_count" {
  description = "Containers desired count to deploy in service"
  default     = 2

}
variable "ec2_min_size" {
  description = "autoscaling group min size of deployed ec2"
  default     = 1
}

variable "ec2_max_size" {
  description = "autoscaling group max size of deployed ec2"
  default     = 2
}

variable "ec2_des_cap" {
  description = "autoscaling group desired capacity of deployed ec2"
  default     = 1
}



variable "vpc_cidr_block" {
  description = "CIDR block of vpc"
}


data "aws_key_pair" "example" {
  key_pair_id        = "key-058b0539ccd636b81"
  include_public_key = true

}

variable "s3_arn" {
  description = "ARN of s3 object with env file"

}
variable "s3_key" {
  description = "Key name that take env file after upload"
}






