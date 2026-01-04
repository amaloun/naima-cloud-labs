
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
    key            = "demo-app/terraform.tfstate"
    region         = "eu-west-3"
  }
}


# 1. Get auth token for the EKS cluster
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

# 2. Configure the Kubernetes Provider
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# 3. Configure the Helm Provider
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
