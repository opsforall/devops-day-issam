# Azure AKS - Session 04: Add network

This session covers the creation of the network of the AKS cluster

## Create AKS network

1. Create a file named `network.tf` in the root directory of the project and copy the following content

```bash
# virtual network 
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.fullname}-${local.env}-virtual-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# aks subnets
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.fullname}-${local.env}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.aks_subnet_address_prefix
  depends_on = [ azurerm_virtual_network.virtual_network, azurerm_resource_group.rg ]
}

# NSG for aks subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.tags
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_network_security_rule" "aks_nsg_inbound" {
  for_each = local.aks_nsg_inbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type 
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on = [ azurerm_network_security_group.aks_nsg, azurerm_resource_group.rg ]
}

resource "azurerm_network_security_rule" "aks_nsg_outbound" {
  for_each = local.aks_nsg_outbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type 
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on = [ azurerm_network_security_group.aks_nsg, azurerm_resource_group.rg ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_associate_aks_subnet" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
  depends_on = [ azurerm_network_security_group.aks_nsg, azurerm_subnet.aks_subnet ]
}

```

2. Create a file named `locals.tf` in the root directory of the project and copy the following content

```bash
locals {
  env = terraform.workspace
  aks_nsg_inbound_rules =  {
    for id, rule in csvdecode(file("./nsg_rules.csv")) :
    id => {
      name    = rule["rule_name"]
      rule_type = rule["rule_type"]
      protocol = rule["protocol"]
      priority = rule["priority"]
      access = rule["access"]
      source_port_range = rule["source_port_range"]
      destination_port_range = rule["destination_port_range"]
      source_address_prefix_cidr = rule["source_address_prefix_cidr"]
      destination_address_prefix = rule["destination_address_prefix"]
    }
    if rule["sg_name"] == "aks-nsg" && rule["rule_type"] == "Inbound"
  }
  aks_nsg_outbound_rules =  {
    for id, rule in csvdecode(file("./nsg_rules.csv")) :
    id => {
      name    = rule["rule_name"]
      rule_type = rule["rule_type"]
      protocol = rule["protocol"]
      priority = rule["priority"]
      access = rule["access"]
      source_port_range = rule["source_port_range"]
      destination_port_range = rule["destination_port_range"]
      source_address_prefix_cidr = rule["source_address_prefix_cidr"]
      destination_address_prefix = rule["destination_address_prefix"]
    }
    if rule["sg_name"] == "aks-nsg" && rule["rule_type"] == "Outbound"
  }
}

```

3. Create a file named `variables.tf` in the root directory of the project and copy the following content

```bash
variable "location" {
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


```

4. Create a file named `terraform.tfvars` in the root directory of the project and copy the following content

```bash
location = "westeurope"
fullname = "firstname-lastname"
tags = {
  "project" : "azure-aks-project",
  "owner"   : "firstname-lastname"
}
vnet_address_space = ["10.10.0.0/16"]
aks_subnet_address_prefix = ["10.10.0.0/21"]

```

Don't forget to update your `firstname-lastname`

5. Create a file named `nsg_rules.csv` in the root directory of the project and copy the following content

```bash
sg_name,rule_name,rule_type,protocol,priority,access,source_port_range,destination_port_range,source_address_prefix_cidr,destination_address_prefix
aks-nsg,AllowHTTP,Inbound,Tcp,100,Allow,*,80,*,*
aks-nsg,AllowHTTPS,Inbound,Tcp,110,Allow,*,443,*,*
aks-nsg,AllowInternetOutbound,Outbound,*,100,Allow,*,*,*,Internet

```

1. Go to the file named `main.tf` in the root directory of the project and add the following content

```bash
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.fullname, "-", "")}acr${terraform.workspace}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
}
```

6. Push to Github repo `azure-aks-project`

7. Run workflow `Provision Infrastructure`

8. Run workflow `Destroy Infrastructure`
