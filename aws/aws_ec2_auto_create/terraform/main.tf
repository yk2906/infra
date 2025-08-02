provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "test_instance" {
  ami                    = var.aws_ami
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.test_instance_sg.id]
  key_name               = "aws-ec2-auto-create"

  tags = {
    Name = "TestInstance"
  }
}

resource "aws_security_group" "test_instance_sg" {
  name        = "test_instance_sg"
  description = "Security group for test instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["60.71.16.38/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
