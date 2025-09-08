output "instance_public_ip" {
  value       = aws_instance.app.public_ip
  description = "Public IP of EC2 instance"
}

output "instance_public_dns" {
  value       = aws_instance.app.public_dns
  description = "Public DNS of EC2 instance"
}
