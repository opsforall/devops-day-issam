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
