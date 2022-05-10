output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "kubeconfig_filename" {
  value = abspath(module.eks.kubeconfig_filename)
}

output "hashicups_url" {
  value = module.demo_app.hashicups_url
}