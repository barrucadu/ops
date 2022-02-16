terraform {
  required_version = ">= 0.12"

  backend "s3" {
    key     = "infra/aws.tfstate"
    bucket  = "barrucadu-ops-terraform-remote-state"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
