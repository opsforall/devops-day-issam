terraform {
  backend "azurerm" {
    resource_group_name  = "backend-tf-rg"
    storage_account_name = "backendterraformproject"
    container_name       = "terraformstate"
    key                  = "aks/studentnumber/terraform.tfstate"
  }
}