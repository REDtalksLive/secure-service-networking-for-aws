output "eks_prod_kubeconfig_filename" {
  value = abspath(module.hcp_eks_prod.kubeconfig_filename)
}

output "eks_prod_hashicups_url" {
  value = module.hcp_eks_prod.hashicups_url
}

output "eks_dev_kubeconfig_filename" {
  value = abspath(module.hcp_eks_dev.kubeconfig_filename)
}

output "eks_dev_hashicups_url" {
  value = module.hcp_eks_dev.hashicups_url
}

output "ecs_dev_hashicups_url" {
  value = module.hcp_ecs_dev.client_lb_address
}

output "ecs_dev_tls_private_key" {
  value     = module.hcp_ecs_dev.tls_private_key
  sensitive = true
}
