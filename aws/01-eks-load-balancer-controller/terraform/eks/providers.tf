provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    helm       = { source = "hashicorp/helm", version = "~> 2.10" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.20" }
  }
}

terraform {
  backend "s3" {
    bucket         = "default-terraform-state-storage-a9f3c2"
    key            = "eks/terraform.tfstate"
    region         = "eu-west-3"
  }
}
