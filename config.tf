# config.tf

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "jscharmen-terraform"
    key    = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}