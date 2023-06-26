provider "aws" {
  region = "eu-north-1"
}
/*
module "vpc" {
  source   = "../modules/vpc"
  env_code = "prod"
}

module "rds" {
  source            = "../modules/rds"
  env_code          = "prod"
  restore_db        = true
  public_subnet_ids = module.vpc.public_subnets_id
  subnet_ids        = module.vpc.private_subnets_id
  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  depends_on        = [module.vpc]
}




module "ecs-cluster" {

  source            = "../modules/ecs-cluster"
  vpc_id            = module.vpc.vpc_id
  public_subnets_id = module.vpc.public_subnets_id
  env_code          = "prod"
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  s3_arn            = module.rds.s3_arn_out
  s3_key            = module.rds.s3_key_out
  depends_on        = [module.rds]

}


*/
resource "random_id" "this" {

  byte_length = 8

}
variable "env_code" {
  default = "prod"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.env_code}-bloodbank-${random_id.this.hex}"
  tags = {
    Name        = "bloodbank-bucket"
    Environment = "${var.env_code}"
  }
}
resource "local_file" "name" {
  content  = "DB_HOST="
  filename = "${path.module}/${var.env_filename}"
}

variable "env_filename" {
  description = "describe your variable"
  default     = ".env"
}
variable "s3_key" {
  description = "describe your variable"
  default     = ".env"
}

resource "aws_s3_object" "object" {

  bucket = aws_s3_bucket.this.id

  key = var.s3_key

  acl = "private" # or can be "public-read"

  source = "${path.module}/${var.env_filename}"


  depends_on = [local_file.name]
}
