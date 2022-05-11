module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name             = var.cluster_name
  cluster_version          = "1.21"
  subnets               = var.public_subnets
  vpc_id                   = var.vpc_id
  wait_for_cluster_timeout = 900

  node_groups = {
    application = {
      name_prefix      = "hashicups"
      instance_types   = ["t3a.medium"]
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3
    }
  }
}

module "eks_consul_client" {
  source  = "./modules/hcp-eks-client"

  env_name         = var.env_name
  cluster_id       = var.hcp_cluster_id
  consul_hosts     = jsondecode(base64decode(var.consul_config_file))["retry_join"]
  k8s_api_endpoint = module.eks.cluster_endpoint
  consul_version   = var.consul_version

  boostrap_acl_token    = var.boostrap_acl_token
  consul_ca_file        = base64decode(var.consul_ca_file)
  consul_datacenter     = var.consul_datacenter
  gossip_encryption_key = jsondecode(base64decode(var.consul_config_file))["encrypt"]

  # The EKS node group will fail to create if the clients are
  # created at the same time. This forces the client to wait until
  # the node group is successfully created.
  depends_on = [module.eks]
}

module "demo_app" {
  source  = "./modules/k8s-demo-app"

  depends_on = [module.eks_consul_client]
}
