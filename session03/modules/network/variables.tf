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
