locals {
  kube_host                   = data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].host
  kube_client_certificate     = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].client_certificate)
  kube_client_key             = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].client_key)
  kube_cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].cluster_ca_certificate)
}