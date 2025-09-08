resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  user_data = templatefile("${path.module}/user_data.sh.tpl")
  tags = {
    Name = "SingleEC2Instance"
  }
}
