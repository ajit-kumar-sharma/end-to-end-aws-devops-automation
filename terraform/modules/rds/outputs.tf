output "db_instance_address" {
  description = "The endpoint address of the RDS database"
  value       = aws_db_instance.main.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS database"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "Secrets Manager Secret ARN storing database credentials"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}
