output "aks_id" {
    value = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
    value = azurerm_kubernetes_cluster.aks.fqdn
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.aks.kube_config_raw
}