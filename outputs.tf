output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = module.aks.aks_name
}

output "client_certificate" {
  value     = module.aks.client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.aks.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.aks.cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = module.aks.password
  sensitive = true
}

output "cluster_username" {
  value     = module.aks.username
  sensitive = true
}

output "host" {
  value     = module.aks.admin_host
  sensitive = true
}

output "kube_config" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "sftp_password" {
  value     = azurerm_storage_account_local_user.example.password
  sensitive = true
}