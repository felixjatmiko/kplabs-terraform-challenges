terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  admin_user_name = "admin-user-${data.aws_caller_identity.current.account_id}"
}

resource "aws_iam_user" "admin" {
  name = local.admin_user_name
}

resource "aws_iam_user_policy_attachment" "admin_access" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_users" "all" {}

output "iam_user_names" {
  description = "Names of all IAM users in this AWS account."
  value       = sort(tolist(data.aws_iam_users.all.names))
}

output "iam_user_total" {
  description = "Total number of IAM users in this AWS account."
  value       = length(data.aws_iam_users.all.names)
}

output "created_admin_user_name" {
  description = "The IAM user name created by this configuration."
  value       = aws_iam_user.admin.name
}