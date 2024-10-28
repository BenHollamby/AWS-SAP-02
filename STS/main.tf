terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  backend "s3" {
    bucket = "tf-backend-bjh15071985"
    key    = "sts/terraform.tfstate"
    region = "us-east-1"
    profile = "iamadmin-general"
    encrypt = true
  }
}

provider "aws" {
  # Configuration options
  profile = "iamadmin-general"
}

resource "aws_vpc" "a4l_vpc" {
  cidr_block = "10.16.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "a4l-vpc"
  }
}

resource "aws_subnet" "sub_a" {
  vpc_id     = aws_vpc.a4l_vpc.id
  cidr_block = "10.16.48.0/20"
  ipv6_cidr_block = "2600:1f18:3b22:ef03::/64"
  availability_zone = "us-east-1a"
  assign_ipv6_address_on_creation = true
  private_dns_hostname_type_on_launch = "ip-name"
  map_public_ip_on_launch = true
  

  tags = {
    Name = "sn-web-A"
  }
}

# resource "aws_subnet" "sub_b" {
#   vpc_id     = aws_vpc.a4l_vpc.id
#   cidr_block = "10.16.112.0/20"
#   availability_zone = "us-east-1b"

#   tags = {
#     Name = "sn-web-B"
#   }
# }

# resource "aws_subnet" "sub_c" {
#   vpc_id     = aws_vpc.a4l_vpc.id
#   cidr_block = "10.16.176.0/20"
#   availability_zone = "us-east-1c"

#   tags = {
#     Name = "sn-web-C"
#   }
# }