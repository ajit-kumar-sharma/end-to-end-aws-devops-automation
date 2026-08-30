variable "environment" {
  description = "Environment name (staging/production)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS Security Group ID"
  type        = string
}

variable "target_group_arn" {
  description = "ALB Target Group ARN"
  type        = string
}

variable "container_image" {
  description = "ECR Container Image URI (including tag)"
  type        = string
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "Fargate Task CPU units (e.g. 256, 512)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Fargate Task Memory in MB (e.g. 512, 1024)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of ECS tasks to maintain"
  type        = number
  default     = 1
}

variable "db_host" {
  description = "PostgreSQL Database endpoint address"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL Database name"
  type        = string
}

variable "db_user" {
  description = "PostgreSQL Database username"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager Secret ARN storing database password"
  type        = string
}
