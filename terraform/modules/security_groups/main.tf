# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "octabyte-${var.environment}-alb-sg"
  description = "Allow HTTP and HTTPS inbound traffic to Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP Ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "octabyte-${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ECS Container Tasks Security Group
resource "aws_security_group" "ecs" {
  name        = "octabyte-${var.environment}-ecs-sg"
  description = "Allow inbound application traffic ONLY from ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Inbound App Port from ALB Security Group"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound egress for container package/API updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "octabyte-${var.environment}-ecs-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# RDS PostgreSQL Database Security Group
resource "aws_security_group" "rds" {
  name        = "octabyte-${var.environment}-rds-sg"
  description = "Allow inbound PostgreSQL traffic ONLY from ECS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL port 5432 ingress from ECS SG only"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "Egress restricted within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "octabyte-${var.environment}-rds-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
