output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "vpc_id" {
  description = "Staging VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "Staging Application Load Balancer DNS Name"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "Amazon ECR Repository URL"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Staging ECS Cluster Name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Staging ECS Service Name"
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Staging RDS Endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "Staging RDS Port"
  value       = module.rds.db_port
}

output "rds_secret_arn" {
  description = "AWS Secrets Manager Secret ARN for Staging DB"
  value       = module.rds.db_secret_arn
}
