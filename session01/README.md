# Azure AKS - Session 01: Configure Terraform and provision a resource group

This session covers the fundamentals of configuring Terraform and the provisioning of a resource group.

## 1. Terraform Configuration

### Step 0: Get Your Azure Subscription and Tenant IDs

Since you already opened the project in VS Code, open `Terminal` and run the following Azure CLI commands:

```bash
# Get your subscription ID
az account show --query id --output tsv

# Get your tenant ID
az account show --query tenantId --output tsv
```

### Step 1: Configure Terraform provider 

1. To configure `subscription_id` and `tenant_id`, you need to create a file named `provider.tf` in the root directory of the project and copy the following content

```bash
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
  required_version = ">= 1.15.0"
}

# Azure Provider configuration
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
```

2. Update the values of `subscription_id` and `tenant_id` with the results that you got in the previous step aka ("Step 1: Get Your Azure Subscription and Tenant IDs")

### Step 2: Configure backend

To configure `backend` you need to create a file named `backend.tf` in the root directory of the project and copy the following content 

```bash
terraform {
  backend "azurerm" {
    resource_group_name  = "backend-tf-rg"
    storage_account_name = "backendterraformproject"
    container_name       = "terraformstate"
    key                  = "aks-infra/studentid/terraform.tfstate"
  }
}
```

Since each one of you have access to an Azure account, use the user name for example `"student1"` that you have and replace `studentid` that exist in the attribute `key` in `backend.tf` with your `studentid`.
### Step 3: Add Terraform variables

To add the Azure resource group you need to create a file named `variables.tf` in the root directory and copy the following content

```bash
variable "location" {
  type = string
}

variable "studentid" {
  type = string
}

```

### Step 4: Fill Terraform variables

To add the Azure resource group you need to create a file named `terraform.tfvars` in the root directory and copy the following content

```bash
location = "westeurope"
studentid = "studentid" 
```

Since each one of you have access to an Azure account, use the user name for example `"student1"` that you have and replace the value of the variable named `studentid` that exit in `terraform.tfvars` with your user name.


### Step 5: Add locals

To add locals, you need to create a file named `locals.tf` in the root directory and copy the following content

```bash
locals {
  env = terraform.workspace
}

```

### Step 6: Add an Azure resource group Terraform configuration

To add the Azure resource group you need to create a file named `main.tf` in the root directory and copy the following content

```bash
resource "azurerm_resource_group" "rg" {
  name     = "${var.studentid}-rg-${local.env}"
  location = var.location
}
```

## 2. Provision infrastructure

### Step 1 : Initialize Terrafom Configuration
Copy the following command and run it inside `VS Code Terminal`

```bash
terraform init
```

### Step 2 : Create Terraform workspace
Copy the following command and run it inside `VS Code Terminal`

```bash
terraform workspace new dev
```

### Step 3 : Validate Configuration
```bash
terraform validate
```

### Step 4: Preview Changes
```bash
terraform plan
```

### Step 5: Apply Configuration (when ready)
```bash
terraform apply
```

Type `yes`

