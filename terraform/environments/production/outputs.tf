output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "vpc_id" {
  description = "Production VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "Production Application Load Balancer DNS Name"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "Amazon ECR Repository URL"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Production ECS Cluster Name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Production ECS Service Name"
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Production RDS Endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "Production RDS Port"
  value       = module.rds.db_port
}

output "rds_secret_arn" {
  description = "AWS Secrets Manager Secret ARN for Production DB"
  value       = module.rds.db_secret_arn
}
