variable "aws_region" {
  description = "The AWS region where the EC2 instances will be created."
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_access_key" {
  description = "The AWS access key for authentication."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret key for authentication."
  type        = string
  sensitive   = true
}

variable "aws_ami" {
  description = "ubuntu 24.04 LTS AMI ID."
  type        = string
  default = "ami-054400ced365b82a0"
}

variable "aws_instance_type" {
  description = "The type of the EC2 instance to create."
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instance will be created."
  type        = string
  default     = "vpc-02c52fb2007a38643"
}