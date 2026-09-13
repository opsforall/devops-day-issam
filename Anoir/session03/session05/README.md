# Azure AKS - Session 05: Add modules

This session covers the creation of modules

## Create network module

1. Create a folder named `modules` in the root directory of the project and create inside it another folder named `network`
2. Create a file named `main.tf` inside the folder `network` and copy the following content

```bash
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

```

3. Create a file named `variables.tf` inside the folder `networking` and copy the following content

```bash
variable "location" {
  type = string
}

variable "env" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "fullname" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_address_prefix" {
  type = list(string)
}

variable "aks_nsg_inbound_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    rule_type                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix_cidr = string
    destination_address_prefix = string
  }))
}

variable "aks_nsg_outbound_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    rule_type                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix_cidr = string
    destination_address_prefix = string
  }))
}

```

4. Create a file named `outputs.tf` inside the folder `networking` and copy the following content

```bash
# virtual network ID
output "vnetID" {
  value       = azurerm_virtual_network.virtual_network.id
  description = "ID of virtual network"
}

# vnet aks subnet
output "aks_subnet_id" {
  value       = azurerm_subnet.aks_subnet.id
  description = "AKS Subnet ID"
}

```

5. Replace the content of the file named `main.tf` in the root directory of the project with the following content

```bash
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

```

6. delete the file named `network.tf` in the root directory

7. Push to Github repo `azure-aks-project`

8. Run workflow `Provision Infrastructure`

9. Run workflow `Destroy Infrastructure`

