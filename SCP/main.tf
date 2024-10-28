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
  alias   = "production"
  profile = "iamadmin-production"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "general"
  profile = "iamadmin-general"
  region  = "us-east-1"
}
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "scp_bucket" {
  provider = aws.production
  bucket = "scp-bucket-${random_string.bucket_suffix.result}"
}

resource "aws_s3_object" "object" {
  provider = aws.production
  bucket = aws_s3_bucket.scp_bucket.id
  key    = "rom.png"
  source = "image/rom.png"
  etag = filemd5("image/rom.png")
}


data "aws_iam_policy_document" "deny_s3" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "s3_policy" {
  provider = aws.general
  name    = "deny-s3"
  content = data.aws_iam_policy_document.deny_s3.json
}