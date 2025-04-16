# ------------------------------------------------------------------------------
# Terraform and AWS Provider Configuration
# ------------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify the AWS provider version (update as needed)
    }
  }
  required_version = ">= 1.3" # Specify the Terraform version
}

provider "aws" {
  region = var.aws_region

  # Assumes AWS credentials are configured via environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY),
  # ~/.aws/credentials file, IAM role, etc., accessible from the Docker container.
  # You can also set common tags using the default_tags block.
  # default_tags {
  #   tags = local.common_tags
  # }
}