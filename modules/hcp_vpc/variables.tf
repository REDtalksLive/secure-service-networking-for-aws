# General

variable "region" {
  description = "Default AWS Region to deploy in."
  type        = string
  default     = ""
}

variable "name" {
  description = "VPC Name"
  type        = string
  default     = ""
}

variable "suffix" {
  description = "Random for resoure naming"
  type        = string
  default     = ""
}


# VPC

variable "availability_zones" {
  description = "AWS Availabily Zones"
  type        = list(string)
  default     = []
}

variable "cidr" {
  description = "VPC cidr"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "VPC Private Subnets"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "VPC public Subnets"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "VPC tags"
  type        = map
  default     = {}
}


# HCP / HVN

variable "hcp_hvn_id" {
  description = "HCP Virtual Network (HVN) ID"
  type        = string
  default     = ""
}

variable "hvn_cidr_block" {
  description = "HCP Virtual Network (HVN) CIDR block"
  type        = string
  default     = ""
}

variable "hcp_hvn_self_link" {
  description = "HCP Virtual Network (HVN) Self Link"
  type        = string
  default     = ""
}

