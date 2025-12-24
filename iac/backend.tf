terraform {
  backend "s3" {
        bucket         = "eudistack-dev-ew1-tfstate"
        key            = "global/certauth/terraform.tfstate"
        region         = "eu-west-1"
        encrypt        = true
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}
