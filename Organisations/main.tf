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
  # No configuration options are needed
}

resource "aws_organizations_account" "my_account" {
  name  = var.gen_account_name
  email = var.gen_account_email

  # Specify the parent OU for this account
  parent_id = aws_organizations_organizational_unit.gen_ou.id
  
  # Optional: Parent root or organizational unit for this account
  # parent_id = aws_organizations_organization.org.roots[0].id
  
  # Optional: IAM user access to the new account
  # role_name = "OrganizationAccountAccessRole"
  
  # Prevent destroying the account when running terraform destroy
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "prod_account" {
  name  = var.prod_account_name
  email = var.prod_account_email

  # Specify the parent OU for this account
  parent_id = aws_organizations_organizational_unit.prod_ou.id
  
  # Optional: Parent root or organizational unit for this account
  # parent_id = aws_organizations_organization.org.roots[0].id
  
  # Optional: IAM user access to the new account
  # role_name = "OrganizationAccountAccessRole"
  
  # Prevent destroying the account when running terraform destroy
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_organizational_unit" "gen_ou" {
  name      = "General"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "prod_ou" {
  name      = "Production"
  parent_id = aws_organizations_organization.org.roots[0].id
}
