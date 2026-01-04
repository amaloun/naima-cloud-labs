module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "main-cluster"
  cluster_version = "1.31"

  # Networking - Linking to your raw VPC
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets

  authentication_mode = "API_AND_CONFIG_MAP"

  eks_managed_node_groups = {
    spot_nodes = {
      instance_types = ["t3.small", "t3a.small"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }
  }

  # Enable the OIDC Provider for the Load Balancer Controller
  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = ["YOUR_IP_ADDRESS/32"] # Replace YOUR_IP_ADDRESS with your actual IP address

  tags = {
    Environment = "training"
    GithubRepo  = "naima-cloud-labs"
  }
}
