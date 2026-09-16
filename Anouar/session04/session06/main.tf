resource "azurerm_resource_group" "rg" {
  name     = "${var.fullname}-rg-${terraform.workspace}"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.fullname, "-", "")}acr${terraform.workspace}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Premium"
  depends_on          = [azurerm_resource_group.rg]
}

module "network" {
  source = "./modules/network"

  env                       = local.env
  rg_name                   = azurerm_resource_group.rg.name
  location                  = var.location
  fullname                  = var.fullname
  tags                      = var.tags
  vnet_address_space        = var.vnet_address_space
  aks_subnet_address_prefix = var.aks_subnet_address_prefix
  aks_nsg_inbound_rules     = local.aks_nsg_inbound_rules
  aks_nsg_outbound_rules    = local.aks_nsg_outbound_rules
}

module "aks" {
  source = "./modules/aks"

  env                     = local.env
  location                = var.location
  acr_id                  = azurerm_container_registry.acr.id
  fullname                = var.fullname
  cluster_version         = var.cluster_version
  tags                    = var.tags
  resource_group_name     = azurerm_resource_group.rg.name
  vnet_subnet_id          = module.network.aks_subnet_id
  private_cluster_enabled = var.private_cluster_enabled
  # master nodes
  master_max_count          = var.master_max_count
  master_min_count          = var.master_min_count
  master_vm_size            = var.master_vm_size
  master_os_disk_size_gb    = var.master_os_disk_size_gb
  master_availability_zones = var.master_availability_zones
  # worker nodes
  worker_node_name           = var.worker_node_name
  worker_vm_size             = var.worker_vm_size
  worker_mode                = var.worker_mode
  worker_availability_zones  = var.worker_availability_zones
  worker_labels              = var.worker_labels
  worker_enable_auto_scaling = var.worker_enable_auto_scaling
  worker_max_count           = var.worker_max_count
  worker_min_count           = var.worker_min_count
  worker_desired_count       = var.worker_desired_count
  worker_max_pods            = var.worker_max_pods
  worker_node_taints         = var.worker_node_taints
  dns_zone_name              = var.dns_zone_name
  dns_zone_rg_name           = var.dns_zone_rg_name
  depends_on                 = [module.network, azurerm_container_registry.acr]
}
