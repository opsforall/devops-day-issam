resource "azurerm_resource_group" "rg" {
  name     = "firstname-lastname-rg-${terraform.workspace}"
  location = "westeurope"
}
