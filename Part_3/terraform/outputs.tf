output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = aws_lb.app.dns_name
}
output "backend_alb_dns_name" {
  description = "DNS name of backend-only ALB"
  value       = aws_lb.backend_alb.dns_name
}

output "backend_api_url" {
  description = "Backend API direct URL"
  value       = "http://${aws_lb.backend_alb.dns_name}/api"
}

output "frontend_url" {
  description = "Frontend Root URL"
  value       = "http://${aws_lb.app.dns_name}/"
}

output "ecr_backend_repo" {
  value       = aws_ecr_repository.backend_repo.repository_url
  description = "Backend ECR repo URI"
}
output "ecr_frontend_repo" {
  value       = aws_ecr_repository.frontend_repo.repository_url
  description = "Frontend ECR repo URI"
}

output "backend_ecs_cluster_name" { value = aws_ecs_cluster.this.name }
output "frontend_ecs_cluster_name" { value = aws_ecs_cluster.frontend_cluster.name }
output "backend_service_name" { value = aws_ecs_service.backend.name }
output "frontend_service_name" { value = aws_ecs_service.frontend.name }