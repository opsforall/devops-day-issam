resource "azurerm_resource_group" "rg" {
  name     = "${var.fullname}-rg-${terraform.workspace}"
  location = var.location
}
