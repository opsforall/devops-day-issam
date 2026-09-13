resource "azurerm_resource_group" "rg" {
  name     = "${var.fullname}-rg-${terraform.workspace}"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.fullname, "-", "")}acr${terraform.workspace}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
}

module "network" {
  source = "./modules/network"

  env = local.env
  rg_name = azurerm_resource_group.rg.name
  location = var.location
  fullname = var.fullname
  tags = var.tags
  vnet_address_space = var.vnet_address_space
  aks_subnet_address_prefix = var.aks_subnet_address_prefix
  aks_nsg_inbound_rules = local.aks_nsg_inbound_rules
  aks_nsg_outbound_rules = local.aks_nsg_outbound_rules
}