variable "region" {
  description = "Default AWS Region to deploy in."
  type        = string
  default     = "us-west-2"
}

variable "availability_zones" {
  description = "AWS Availabily Zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "env-eks-prod" {
  description = "EKS Prod Environment Settings for Modules"
  type = object({
    name            = string
    platform        = string
    cidr            = string
    private_subnets = list(string)
    public_subnets  = list(string)
  })
  default = {
    name            = "eks-prod"
    platform        = "eks"
    cidr            = "10.0.0.0/16"
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  }
}

variable "env-eks-dev" {
  description = "EKS Dev/Test Environment Settings for Modules"
  type = object({
    name            = string
    platform        = string
    cidr            = string
    private_subnets = list(string)
    public_subnets  = list(string)
  })
  default = {
    name            = "eks-dev"
    platform        = "eks"
    cidr            = "10.1.0.0/16"
    private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  }
}

variable "env-ecs-dev" {
  description = "ECS Dev Environment Settings for Modules"
  type = object({
    name            = string
    platform        = string
    cidr            = string
    private_subnets = list(string)
    public_subnets  = list(string)
  })
  default = {
    name            = "ecs-dev"
    platform        = "ecs"
    cidr            = "10.2.0.0/16"
    private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
    public_subnets  = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]
  }
}
