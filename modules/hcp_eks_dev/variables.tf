# EKS

variable "env_name" {
  description = "Name of the Environment"
  type = string
  default = ""
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type = string
  default = ""
}


# VPC info

variable "vpc_id" {
  description = "VPC ID"
  type = string
  default = ""
}

variable "private_subnets" {
  description = "VPC Private Subnet"
  type = list(string)
  default = [""]
}

variable "public_subnets" {
  description = "VPC Public Subnet"
  type = list(string)
  default = [""]
}


# HCP info

variable "hcp_cluster_id" {
  description = "HCP Consul Cluster ID"
  type = string
  default = ""
}

variable "hcp_consul_cluster_addr" {
  description = "VPC Public Subnet"
  type = string
  default = ""
}

variable "consul_datacenter" {
  description = "HCP Consul Datacenter"
  type = string
  default = ""
}

variable "consul_ca_file" {
  description = "HCP Consul CA File"
  type = string
  default = ""
}

variable "consul_config_file" {
  description = "HCP Consul Agent Configuration File"
  type = string
  default = ""
}

variable "boostrap_acl_token" {
  description = ""
  type = string
  default = ""
}

variable "consul_version" {
  description = ""
  type = string
  default = ""
}

variable "hvn_cidr" {
  description = ""
  type = string
  default = ""
}

