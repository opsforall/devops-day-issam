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
    node_provisioning_profile {
      mode = "Manual"
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
