resource "aws_db_subnet_group" "main" {
  name       = "octabyte-${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "octabyte-${var.environment}-rds-subnet-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_parameter_group" "postgres15" {
  name   = "octabyte-${var.environment}-pg15-params"
  family = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

# AWS Secrets Manager Secret for Database Password
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "octabyte-${var.environment}-db-credentials"
  description             = "Master credentials for OctaByte PostgreSQL database in ${var.environment}"
  recovery_window_in_days = 0

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_secret_ver" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_user
    password = var.db_password
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = 5432
    dbname   = var.db_name
  })
}

resource "aws_db_instance" "main" {
  identifier             = "octabyte-${var.environment}-postgres"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = 100
  storage_type           = "gp3"
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  parameter_group_name   = aws_db_parameter_group.postgres15.name
  publicly_accessible    = false
  multi_az               = var.multi_az
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "octabyte-${var.environment}-postgres-final-snapshot"
  deletion_protection    = var.deletion_protection

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:30-Mon:05:30"

  tags = {
    Name        = "octabyte-${var.environment}-postgres"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
