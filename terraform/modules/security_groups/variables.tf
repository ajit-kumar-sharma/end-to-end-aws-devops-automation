variable "environment" {
  description = "Environment name (staging/production)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Security Groups will be created"
  type        = string
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}
