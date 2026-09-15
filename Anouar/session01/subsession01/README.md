# Azure AKS - Subsession 01: Terraform Configuration & Testing

This session covers the fundamentals of configuring and testing Terraform for Azure infrastructure with AKS.

## Configuration

### Step 1: Get Your Azure Subscription and Tenant IDs

Since you already opened the project in VS Code, open Terminal Run the following Azure CLI commands:

```bash
# Get your subscription ID
az account show --query id --output tsv

# Get your tenant ID
az account show --query tenantId --output tsv
```

### Step 2: Configure Terraform with Azure credential 

1. To configure `subscription_id` and `tenant_id`, you need to create a file named `provider.tf` in the root directory of the project and copy the following content

```bash
#Terraform configuration for Azure provider.
terraform {
  required_providers {
    # Required Azure Provider
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.59.0"
    }
  }
  # Required Terraform version
  required_version = ">= 1.14.0"
}

# Azure Provider configuration
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = ""
  tenant_id       = ""
}
```

2. Update the values of `subscription_id` and `tenant_id` with the results that you got in the previous step aka ("Step 1: Get Your Azure Subscription and Tenant IDs")

### Step 3: Initialize Terraform

Open the terminal inside the folder
```bash
terraform init
```

## Testing Your Configuration

To test the configuration, we're going to create an Azure resource group resource bloc and see if we can provision the resource group successfully.

### Step 1: Add an Azure resource group specification

To add the Azure resource group you need to create a file named `main.tf` in the root directory and copy the following content

```bash
resource "azurerm_resource_group" "rg" {
  name     = "firstname-lastname-rg"
  location = "francecentral"
}
```

Update the value of name with `firstname-lastname-rg`

### Step 2: Validate Configuration
```bash
terraform validate
```

### Step 3: Preview Changes
```bash
terraform plan
```

### Step 4: Apply Configuration (when ready)
```bash
terraform apply
```

Type `yes`

### Destroy Resources
```bash
terraform destroy
```

Type `yes`
