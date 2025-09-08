output "instance_public_ip" {
  value       = aws_instance.app.public_ip
  description = "Public IP of EC2 instance"
}

output "instance_public_dns" {
  value       = aws_instance.app.public_dns
  description = "Public DNS of EC2 instance"
}
output "flask_url" {
  value       = "http://${aws_instance.app.public_ip}:5000"
  description = "URL for Flask backend"
}
output "express_url" {
  value       = "http://${aws_instance.app.public_ip}:3000"
  description = "URL for Express frontend"
}