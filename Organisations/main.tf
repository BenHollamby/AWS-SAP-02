terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  backend "s3" {
    bucket = "tf-backend-bjh15071985"
    key    = "terraform.tfstate"
    region = "us-east-1"
    profile = "iamadmin-general"
    encrypt = true
  }
}

provider "aws" {
  # Configuration options
  profile = "iamadmin-general"
}

resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}

resource "aws_organizations_account" "my_account" {
  name  = var.gen_account_name
  email = var.gen_account_email

  # Specify the parent OU for this account
  parent_id = aws_organizations_organizational_unit.gen_ou.id
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "prod_account" {
  name  = var.prod_account_name
  email = var.prod_account_email
  # Specify the parent OU for this account
  parent_id = aws_organizations_organizational_unit.prod_ou.id
}

resource "aws_organizations_account" "dev_account" {
  name  = var.dev_account_name
  email = var.dev_account_email

  # Specify the parent OU for this account
  parent_id = aws_organizations_organizational_unit.dev_ou.id
  role_name = "OrganizationAccountAccessRole"
}

output "devaccountid" {
  value = aws_organizations_account.dev_account.id
  
}

resource "aws_organizations_organizational_unit" "gen_ou" {
  name      = "General"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "prod_ou" {
  name      = "Production"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "dev_ou" {
  name      = "Development"  
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_iam_role" "assume_role" {
  name = "OrganisationAccountAccessRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


data "aws_iam_policy_document" "policy" {
  statement {
    sid = "AllowAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${aws_organizations_account.my_account.id}:role/OrganisationAccountAccessRole"
    ]
  }
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
  name    = "deny-s3"
  description = "Deny all S3 actions"
  content = data.aws_iam_policy_document.deny_s3.json
  type    = "SERVICE_CONTROL_POLICY"
}

// Attach the policy to the OU to prevent all S3 actions
# resource "aws_organizations_policy_attachment" "unit" {
#   policy_id = aws_organizations_policy.s3_policy.id
#   target_id = aws_organizations_organizational_unit.prod_ou.id
# }

