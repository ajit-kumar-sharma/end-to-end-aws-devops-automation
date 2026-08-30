variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "staging"
}

variable "vpc_cidr" {
  description = "CIDR block for staging VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_port" {
  description = "Application port"
  type        = number
  default     = 3000
}

variable "container_cpu" {
  description = "ECS Task CPU unit"
  type        = string
  default     = "256"
}

variable "container_memory" {
  description = "ECS Task Memory MB"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks running in staging"
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Application container image URI"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "PostgreSQL Database Name"
  type        = string
  default     = "octabyte_staging_db"
}

variable "db_username" {
  description = "PostgreSQL Database Username"
  type        = string
  default     = "octabyte_admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "StagingSecretPassword123!"
}

variable "db_instance_class" {
  description = "RDS DB Instance Class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}
