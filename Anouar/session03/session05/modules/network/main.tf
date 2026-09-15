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
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

# NSG for aks subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = var.rg_name
  tags = var.tags
}

resource "azurerm_network_security_rule" "aks_nsg_inbound" {
  for_each = var.aks_nsg_inbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type
  access                      = each.value.access 
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix_cidr 
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on = [ azurerm_network_security_group.aks_nsg]
}

resource "azurerm_network_security_rule" "aks_nsg_outbound" {
  for_each = var.aks_nsg_outbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type 
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix_cidr 
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on = [ azurerm_network_security_group.aks_nsg]
}

resource "azurerm_subnet_network_security_group_association" "nsg_associate_aks_subnet" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
  depends_on = [ azurerm_network_security_group.aks_nsg, azurerm_subnet.aks_subnet ]
}
