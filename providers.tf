// Pin the versions

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.43.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.26.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }
  }
  provider_meta "hcp" {
    module_name = "hcp-consul"
  }
}


provider "aws" {
  region = var.region
}

// Configure the providers

#provider "hcp" {
#  client_id     = var.hcp_client_id
#  client_secret = var.hcp_client_secret
#}

