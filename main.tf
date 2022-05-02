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


# HCP VPCs
module "hcp_vpc" {
  for_each = { for env in var.env : env.name => env }
  source = "./modules/hcp_vpc"

  region              = var.region
  name                = each.value.name
  cidr                = each.value.cidr
  suffix              = random_string.rand_suffix.result
  availability_zones  = var.availability_zones
  private_subnets     = each.value.private_subnets
  public_subnets      = each.value.public_subnets
  hcp_hvn_id          = hcp_hvn.hvn.hvn_id
  hvn_cidr_block      = hcp_hvn.hvn.cidr_block
  hcp_hvn_self_link   = hcp_hvn.hvn.self_link

  tags = {
    Terraform   = "true"
    Environment = each.value.name
  }

}



# EKS Module

module "hcp_eks" {
  for_each = { 
    for env in var.env : 
      env.name => env
      if env.platform == "eks"
  }

  source = "./modules/hcp_eks"

  cluster_name = "${hcp_consul_cluster.hcp_consul.cluster_id}-${each.value.name}"
  public_subnets      = module.hcp_vpc[each.value.name].public_subnets
  vpc_id = module.hcp_vpc[each.value.name].vpc_id
  datacenter = hcp_consul_cluster.hcp_consul.datacenter
  consul_ca_file = hcp_consul_cluster.hcp_consul.consul_ca_file
  consul_config_file = hcp_consul_cluster.hcp_consul.consul_config_file
  hcp_cluster_id = hcp_consul_cluster.hcp_consul.cluster_id
  hcp_acl_token_secret_id = hcp_consul_cluster_root_token.token.secret_id
  hvn_cidr = hcp_hvn.hvn.cidr_block
  consul_version = hcp_consul_cluster.hcp_consul.consul_version

}


# ECS Module

//TODO: use the EKS module pattern to add ECS to the lab.
//TODO: ./modules/hcp_ecs/data.tf > locals. Make them all variables
#module "hcp_eks" {
#  for_each = { 
#    for env in var.env : 
#      env.name => env
#      if env.platform == "ecs"
#  }
#  name                = each.value.name
#  region              = var.region

#
#  source = "./modules/hcp_ecs"
#
#}