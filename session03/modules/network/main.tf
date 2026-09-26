# virtual network 
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.fullname}-${var.env}-virtual-network"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# aks subnets
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.fullname}-${var.env}-aks-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.aks_subnet_address_prefix
  depends_on           = [azurerm_virtual_network.virtual_network]
}
