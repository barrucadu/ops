terraform {
  required_version = ">= 1.1.7"

  backend "s3" {
    key     = "infra/aws.tfstate"
    bucket  = "barrucadu-ops-terraform-remote-state"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
