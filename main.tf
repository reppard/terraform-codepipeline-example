// Configure remote state location here...
terraform {
  required_version = ">= 0.11.0"
  backend "s3" {
    bucket = "owner-terraform-state"
    key    = "project/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  version = "~> 1.0.0"
  region  = "us-east-1"
}

