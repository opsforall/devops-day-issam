resource "azurerm_resource_group" "rg" {
  name     = "${var.studentid}-rg-${local.env}"
  location = var.location
}

module "network" {
  source = "./modules/network"

  env                       = local.env
  rg_name                   = azurerm_resource_group.rg.name
  location                  = var.location
  fullname                  = var.fullname
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
  resource_group_name     = azurerm_resource_group.rg.name
  vnet_subnet_id          = module.network.aks_subnet_id
  private_cluster_enabled = var.private_cluster_enabled
  # master nodes
  master_max_count          = var.master_max_count
  master_min_count          = var.master_min_count
  master_vm_size            = var.master_vm_size
  master_os_disk_size_gb    = var.master_os_disk_size_gb
  master_availability_zones = var.master_availability_zones
  depends_on                 = [module.network]
}
