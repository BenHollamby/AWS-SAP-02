terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  backend "s3" {
    bucket = "productiontfstatebucket15071985"
    key    = "terraform.tfstate"
    region = "us-east-1"
    profile = "iamadmin-production"
    encrypt = true
  }
}

provider "aws" {
  # Configuration options
  profile = "iamadmin-production"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "scp_bucket" {
  bucket = "scp-bucket-${random_string.bucket_suffix.result}"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.scp_bucket.id
  key    = "rom.png"
  source = "image/rom.png"
  etag = filemd5("image/rom.png")
}