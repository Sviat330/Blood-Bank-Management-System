provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source   = "../modules/vpc"
  env_code = "prod"
}

module "rds" {
  source         = "../modules/rds"
  env_code       = "prod"
  subnet_ids     = module.vpc.private_subnets_id
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
}

output "private_subnets_id" {
  value = module.vpc.private_subnets_id
}

output "public_subnets_id" {
  value = module.vpc.public_subnets_id
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

