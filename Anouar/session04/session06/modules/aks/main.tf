# creating AKS cluster
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                    = "${var.fullname}-aks-${var.env}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.resource_group_name
  kubernetes_version      = var.cluster_version
  node_resource_group     = "${var.fullname}-aks-nodes-rg-${var.env}"
  private_cluster_enabled = var.private_cluster_enabled
  tags = {
    "environment" = var.env
    "created_by"  = var.fullname
  }
  default_node_pool {
    name                        = "defaultpool"
    vm_size                     = var.master_vm_size
    zones                       = var.master_availability_zones
    auto_scaling_enabled        = true
    max_count                   = var.master_max_count
    min_count                   = var.master_min_count
    vnet_subnet_id              = var.vnet_subnet_id
    os_disk_size_gb             = var.master_os_disk_size_gb
    temporary_name_for_rotation = "master"
    type                        = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.env
      "nodepoolos"    = "linux"
    }
    upgrade_settings {
      max_surge                     = "33%" # allow up to 33% extra nodes during upgrade
      drain_timeout_in_minutes      = 30    # timeout for draining a node
      node_soak_duration_in_minutes = 10    # wait time before node is considered stable
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = var.env
      "nodepoolos"    = "linux"
      "created_by"    = var.fullname
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
  }
  oidc_issuer_enabled = var.oidc_issuer_enabled

  lifecycle {
    ignore_changes = [
      default_node_pool[0].tags
    ]
  }
}

/*
resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  name                         = var.worker_node_name
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks-cluster.id
  vm_size                      = var.worker_vm_size
  mode                         = var.worker_mode
  zones                        = var.worker_availability_zones
  node_labels                  = var.worker_labels
  auto_scaling_enabled         = var.worker_enable_auto_scaling
  host_encryption_enabled      = var.worker_enable_host_encryption
  node_public_ip_enabled       = var.worker_enable_node_public_ip
  max_pods                     = var.worker_max_pods
  node_taints                  = var.worker_node_taints
  vnet_subnet_id               = var.vnet_subnet_id
  pod_subnet_id                = var.worker_pod_subnet_id
  orchestrator_version         = var.worker_orchestrator_version
  max_count                    = var.worker_max_count
  min_count                    = var.worker_min_count
  node_count                   = var.worker_desired_count
  os_type                      = var.worker_os_type
  priority                     = var.worker_priority
  tags                         = var.tags
  temporary_name_for_rotation = "worker"
  upgrade_settings {
    max_surge                     = "33%"   # allow up to 33% extra nodes during upgrade
    drain_timeout_in_minutes      = 30      # timeout for draining a node
    node_soak_duration_in_minutes = 10      # wait time before node is considered stable
  }
  lifecycle {
    ignore_changes = [
        tags
    ]
  }
  depends_on = [ azurerm_kubernetes_cluster.aks-cluster ]
}
*/

# role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "role_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  # skip_service_principal_aad_check = true
  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
}

# External DNS zone role assignment for AKS
data "azurerm_dns_zone" "dns_zone" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_rg_name
}

resource "azurerm_role_assignment" "dns_contrib" {
  scope                = data.azurerm_dns_zone.dns_zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.aks-cluster, data.azurerm_dns_zone.dns_zone]
}
