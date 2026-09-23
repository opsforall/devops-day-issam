resource "azurerm_resource_group" "rg" {
  name     = "${var.studentid}-rg-${local.env}"
  location = "francecentral"
}