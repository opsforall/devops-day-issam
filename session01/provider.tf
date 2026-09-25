#Terraform configuration for Azure provider.
terraform {
  required_providers {
    # Required Azure Provider
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.6.0"
    }
  }
  # Required Terraform version
  required_version = ">= 1.16.0"
}

# Azure Provider configuration
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}