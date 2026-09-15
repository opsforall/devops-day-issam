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
