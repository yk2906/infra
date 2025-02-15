terraform {
  required_version = "~> 1.9.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.53"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      created_by_terraform = "true"
    }
  }
}
