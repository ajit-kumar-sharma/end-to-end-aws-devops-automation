terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "../../modules/vpc"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  single_nat_gateway   = true
}

module "security_groups" {
  source         = "../../modules/security_groups"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
  db_port        = 5432
}

module "alb" {
  source                = "../../modules/alb"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  container_port        = var.container_port
}

module "ecr" {
  source               = "../../modules/ecr"
  environment          = var.environment
  image_tag_mutability = "MUTABLE"
}

module "rds" {
  source                  = "../../modules/rds"
  environment             = var.environment
  private_subnet_ids      = module.vpc.private_subnet_ids
  rds_security_group_id   = module.security_groups.rds_security_group_id
  db_name                 = var.db_name
  db_user                 = var.db_username
  db_password             = var.db_password
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  multi_az                = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = var.backup_retention_period
}

module "ecs" {
  source                = "../../modules/ecs"
  environment           = var.environment
  aws_region            = var.aws_region
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  container_image       = var.container_image != "" ? var.container_image : "${module.ecr.repository_url}:latest"
  container_port        = var.container_port
  cpu                   = var.container_cpu
  memory                = var.container_memory
  desired_count         = var.ecs_desired_count
  db_host               = module.rds.db_instance_address
  db_name               = module.rds.db_name
  db_user               = var.db_username
  db_secret_arn         = module.rds.db_secret_arn
}
