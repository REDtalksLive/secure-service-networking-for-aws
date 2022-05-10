# ECS
variable "name" {
  description = "Name to be used on all the resources as identifier."
  type        = string
  default     = "consul-ecs"
}

# VPC
variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-west-2"
}

variable "ecs_dev_vpc_id" {
  description = ""
  type = string
  default = ""
}

variable "ecs_dev_vpc_cidr_block" {
  description = ""
  type = string
  default = ""
}

variable "ecs_dev_route_table_ids" {
  description = ""
  type = list
  default = [""]
}

variable "ecs_dev_private_subnets" {
  description = ""
  type = list
  default = [""]
}

variable "ecs_dev_public_subnets" {
  description = ""
  type = list
  default = [""]
}


# EKS Prod variables for peering

variable "eks_dev_aws_vpc_id" {
  description = ""
  type = string
  default = ""
}

variable "eks_dev_vpc_owner_id" {
  description = ""
  type = string
  default = ""
}

variable "eks_dev_vpc_cidr_block" {
  description = ""
  type = string
  default = ""
}

variable "eks_dev_route_table_ids" {
  description = ""
  type = list
  default = [""]
}

variable "eks_dev_cluster_primary_security_group_id" {
  description = ""
  type = string
  default = ""
}


# HCP
variable "cluster_name" {
  description = ""
  type = string
  default = ""
}

variable "env_name" {
  description = "Name of the Environment"
  type = string
  default = ""
}

variable "consul_version" {
  description = ""
  type = string
  default = ""
}

variable "consul_ca_file" {
  type        = string
  description = "The Consul CA certificate bundle used to validate TLS connections"
}

variable "consul_config_file" {
  description = ""
  type = string
  default = ""
}

variable "boostrap_acl_token" {
  description = ""
  type = string
  default = ""
}

variable "hcp_consul_private_endpoint_url" {
  description = ""
  type = string
  default = ""
}

variable "hcp_consul_public_endpoint_url" {
  description = ""
  type = string
  default = ""
}

variable "consul_datacenter" {
  description = ""
  type = string
  default = ""
}


//TODO: Finish vars

variable "user_public_ip" {
  description = "Your Public IP. This is used in the load balancer security groups to ensure only you can access the Consul UI and example application."
  type        = string
  default     = "0.0.0.0/0"
}

variable "default_tags" {
  description = "Default Tags for AWS"
  type        = map(string)
  default = {
    Environment = "dev"
    Team        = "Education-Consul"
    tutorial    = "Serverless Consul service mesh with ECS and HCP"
  }
}

# Security - Ingress
variable "target_group_settings" {
  default = {
    elb = {
      services = [
        {
          name                 = "frontend"
          service_type         = "http"
          protocol             = "HTTP"
          target_group_type    = "ip"
          port                 = "80"
          deregistration_delay = 30
          health = {
            healthy_threshold   = 2
            unhealthy_threshold = 2
            interval            = 30
            timeout             = 29
            path                = "/"
          }
        },
        {
          name                 = "public-api"
          service_type         = "http"
          protocol             = "HTTP"
          target_group_type    = "ip"
          port                 = "8081"
          deregistration_delay = 30
          health = {
            healthy_threshold   = 2
            unhealthy_threshold = 2
            interval            = 30
            timeout             = 29
            path                = "/"
            port                = "8081"
          },
        },
      ]
    }
  }
}