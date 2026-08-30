output "repository_url" {
  description = "The URL of the created ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  description = "The ARN of the created ECR repository"
  value       = aws_ecr_repository.app.arn
}

output "repository_name" {
  description = "The name of the created ECR repository"
  value       = aws_ecr_repository.app.name
}
