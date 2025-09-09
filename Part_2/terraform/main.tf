data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "backend_sg" {
  name        = "flask-backend-sg"
  description = "Allow SSH and Flask (5000)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data_backend.sh.tpl", {
    repo_url   = "https://github.com/PrajwalMalokar/flask-express-aws-terraform.git"
    branch     = "main"
    flask_path = "Part 1/backend"
  })
  tags = {
    Name = "FlaskBackendInstance"
  }
}

// Frontend Instance Configuration
resource "aws_security_group" "frontend_sg" {
  name        = "express-frontend-sg"
  description = "Allow SSH and Express (3000)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data_frontend.sh.tpl", {
    repo_url     = "https://github.com/PrajwalMalokar/flask-express-aws-terraform.git"
    branch       = "main"
    express_path = "Part 1/frontend"
    backend_url  = "http://${aws_instance.backend.private_ip}:5000/api"
  })
  tags = {
    Name = "ExpressFrontendInstance"
  }
}