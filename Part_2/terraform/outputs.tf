output "backend_public_ip" {
  value       = aws_instance.backend.public_ip
  description = "Public IP of backend EC2 instance"
}

output "backend_public_dns" {
  value       = aws_instance.backend.public_dns
  description = "Public DNS of backend EC2 instance"
}

output "frontend_public_ip" {
  value       = aws_instance.frontend.public_ip
  description = "Public IP of frontend EC2 instance"
}

output "frontend_public_dns" {
  value       = aws_instance.frontend.public_dns
  description = "Public DNS of frontend EC2 instance"
}

output "flask_url" {
  value       = "http://${aws_instance.backend.public_ip}:5000"
  description = "URL for Flask backend"
}

output "express_url" {
  value       = "http://${aws_instance.frontend.public_ip}:3000"
  description = "URL for Express frontend"
}