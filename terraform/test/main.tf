# プロバイダーの設定
resource "aws_security_group" "instance_sg" {
  name = "terraform-ec2-sg"
  description = "Allow SSH and ICMP"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["60.71.16.38/32"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["60.71.16.38/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPCのデフォルトサブネットでEC2インスタンスを作成
resource "aws_instance" "example" {
  ami           = "ami-0cab37bd176bb80d3"
  instance_type = "t2.micro"

  key_name = "terraform-test-key"
  security_groups = [aws_security_group.instance_sg.name]
}

# アウトプット
output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}