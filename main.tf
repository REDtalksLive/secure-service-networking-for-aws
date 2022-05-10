# Util

resource "random_string" "rand_suffix" {
  length  = 6
  special = false
  lower   = true
  upper   = false
}


# HCP & HVN

resource "hcp_hvn" "hvn" {
  hvn_id         = "hvn-${random_string.rand_suffix.result}"
  cloud_provider = "aws"
  region         = var.region
}

resource "hcp_consul_cluster" "hcp_consul" {
  hvn_id          = hcp_hvn.hvn.hvn_id
  cluster_id      = "hcp-consul-${random_string.rand_suffix.result}"
  tier            = "development"
  public_endpoint = true
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.hcp_consul.id
}


# VPC Deployments

## HCP EKS Prod VPC
module "hcp_vpc_eks_prod" {
  source = "./modules/hcp_vpc"

  region             = var.region
  name               = var.env-eks-prod.name
  cidr               = var.env-eks-prod.cidr
  suffix             = random_string.rand_suffix.result
  availability_zones = var.availability_zones
  private_subnets    = var.env-eks-prod.private_subnets
  public_subnets     = var.env-eks-prod.public_subnets
  hcp_hvn_id         = hcp_hvn.hvn.hvn_id
  hvn_cidr_block     = hcp_hvn.hvn.cidr_block
  hcp_hvn_self_link  = hcp_hvn.hvn.self_link

  tags = {
    Terraform   = "true"
    Environment = var.env-eks-prod.name
  }

}



## HCP EKS Dev VPC
module "hcp_vpc_eks_dev" {
  source = "./modules/hcp_vpc"

  region             = var.region
  name               = var.env-eks-dev.name
  cidr               = var.env-eks-dev.cidr
  suffix             = random_string.rand_suffix.result
  availability_zones = var.availability_zones
  private_subnets    = var.env-eks-dev.private_subnets
  public_subnets     = var.env-eks-dev.public_subnets
  hcp_hvn_id         = hcp_hvn.hvn.hvn_id
  hvn_cidr_block     = hcp_hvn.hvn.cidr_block
  hcp_hvn_self_link  = hcp_hvn.hvn.self_link

  tags = {
    Terraform   = "true"
    Environment = var.env-eks-dev.name
  }

}



## HCP ECS Dev VPC
module "hcp_vpc_ecs_dev" {
  source = "./modules/hcp_vpc"

  region             = var.region
  name               = var.env-ecs-dev.name
  cidr               = var.env-ecs-dev.cidr
  suffix             = random_string.rand_suffix.result
  availability_zones = var.availability_zones
  private_subnets    = var.env-ecs-dev.private_subnets
  public_subnets     = var.env-ecs-dev.public_subnets
  hcp_hvn_id         = hcp_hvn.hvn.hvn_id
  hvn_cidr_block     = hcp_hvn.hvn.cidr_block
  hcp_hvn_self_link  = hcp_hvn.hvn.self_link

  tags = {
    Terraform   = "true"
    Environment = var.env-ecs-dev.name
  }

}


# EKS Module Deployments

## EKS Prod
module "hcp_eks_prod" {

  source = "./modules/hcp_eks_prod"

  env_name           = var.env-eks-prod.name
  cluster_name       = "${hcp_consul_cluster.hcp_consul.cluster_id}-${var.env-eks-prod.name}"
  public_subnets     = module.hcp_vpc_eks_prod.public_subnets
  vpc_id             = module.hcp_vpc_eks_prod.vpc_id
  consul_datacenter  = hcp_consul_cluster.hcp_consul.datacenter
  consul_ca_file     = hcp_consul_cluster.hcp_consul.consul_ca_file
  consul_config_file = hcp_consul_cluster.hcp_consul.consul_config_file
  hcp_cluster_id     = hcp_consul_cluster.hcp_consul.cluster_id
  boostrap_acl_token = hcp_consul_cluster_root_token.token.secret_id
  hvn_cidr           = hcp_hvn.hvn.cidr_block
  consul_version     = hcp_consul_cluster.hcp_consul.consul_version

}


## EKS Dev
module "hcp_eks_dev" {

  source = "./modules/hcp_eks_dev"

  env_name           = var.env-eks-dev.name
  cluster_name       = "${hcp_consul_cluster.hcp_consul.cluster_id}-${var.env-eks-dev.name}"
  public_subnets     = module.hcp_vpc_eks_dev.public_subnets
  vpc_id             = module.hcp_vpc_eks_dev.vpc_id
  consul_datacenter  = hcp_consul_cluster.hcp_consul.datacenter
  consul_ca_file     = hcp_consul_cluster.hcp_consul.consul_ca_file
  consul_config_file = hcp_consul_cluster.hcp_consul.consul_config_file
  hcp_cluster_id     = hcp_consul_cluster.hcp_consul.cluster_id
  boostrap_acl_token = hcp_consul_cluster_root_token.token.secret_id
  hvn_cidr           = hcp_hvn.hvn.cidr_block
  consul_version     = hcp_consul_cluster.hcp_consul.consul_version

}



# ECS Module Deployments

## ECS Dev
module "hcp_ecs_dev" {
  source = "./modules/hcp_ecs_dev"

  # VPC Settings
  ecs_dev_vpc_id          = module.hcp_vpc_ecs_dev.vpc_id
  ecs_dev_vpc_cidr_block  = module.hcp_vpc_ecs_dev.vpc_cidr_block
  ecs_dev_private_subnets = module.hcp_vpc_ecs_dev.private_subnets
  ecs_dev_public_subnets  = module.hcp_vpc_ecs_dev.public_subnets
  ecs_dev_route_table_ids = concat(module.hcp_vpc_ecs_dev.public_route_table_ids, module.hcp_vpc_ecs_dev.private_route_table_ids)

  # Variables for peering ECS to EKS Dev, for Mesh Gateway comm's
  eks_dev_aws_vpc_id                        = module.hcp_vpc_eks_dev.vpc_id
  eks_dev_vpc_owner_id                      = module.hcp_vpc_eks_dev.vpc_owner_id
  eks_dev_vpc_cidr_block                    = module.hcp_vpc_eks_dev.vpc_cidr_block
  eks_dev_route_table_ids                   = concat(module.hcp_vpc_eks_dev.public_route_table_ids, module.hcp_vpc_eks_dev.private_route_table_ids)
  eks_dev_cluster_primary_security_group_id = module.hcp_eks_dev.cluster_primary_security_group_id

  # HCP Consul data for bootstrapping ECS Cluster
  boostrap_acl_token              = hcp_consul_cluster_root_token.token.secret_id
  cluster_name                    = "${hcp_consul_cluster.hcp_consul.cluster_id}-${var.env-eks-dev.name}"
  consul_config_file              = hcp_consul_cluster.hcp_consul.consul_config_file
  consul_ca_file                  = hcp_consul_cluster.hcp_consul.consul_ca_file
  consul_version                  = hcp_consul_cluster.hcp_consul.consul_version
  hcp_consul_private_endpoint_url = hcp_consul_cluster.hcp_consul.consul_private_endpoint_url
  hcp_consul_public_endpoint_url  = hcp_consul_cluster.hcp_consul.consul_public_endpoint_url
  consul_datacenter               = hcp_consul_cluster.hcp_consul.datacenter
}