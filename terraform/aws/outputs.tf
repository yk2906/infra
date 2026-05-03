output "instance_id" {
  description = "The ID of the created EC2 instance."
  value       = aws_instance.test_instance.id
}

output "public_ip" {
  description = "The public IP address of the created EC2 instance."
  value       = aws_instance.test_instance.public_ip
}