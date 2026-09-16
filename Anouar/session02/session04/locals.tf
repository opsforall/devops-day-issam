locals {
  env = terraform.workspace
  aks_nsg_inbound_rules = {
    for id, rule in csvdecode(file("./nsg_rules.csv")) :
    id => {
      name                       = rule["rule_name"]
      rule_type                  = rule["rule_type"]
      protocol                   = rule["protocol"]
      priority                   = rule["priority"]
      access                     = rule["access"]
      source_port_range          = rule["source_port_range"]
      destination_port_range     = rule["destination_port_range"]
      source_address_prefix_cidr = rule["source_address_prefix_cidr"]
      destination_address_prefix = rule["destination_address_prefix"]
    }
    if rule["sg_name"] == "aks-nsg" && rule["rule_type"] == "Inbound"
  }
  aks_nsg_outbound_rules = {
    for id, rule in csvdecode(file("./nsg_rules.csv")) :
    id => {
      name                       = rule["rule_name"]
      rule_type                  = rule["rule_type"]
      protocol                   = rule["protocol"]
      priority                   = rule["priority"]
      access                     = rule["access"]
      source_port_range          = rule["source_port_range"]
      destination_port_range     = rule["destination_port_range"]
      source_address_prefix_cidr = rule["source_address_prefix_cidr"]
      destination_address_prefix = rule["destination_address_prefix"]
    }
    if rule["sg_name"] == "aks-nsg" && rule["rule_type"] == "Outbound"
  }
}
