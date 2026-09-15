# Azure AKS - Session 02: Terraform Backend & Workspace

This session covers configuration of backend and workspace

## Configure backend

### Step 1: Add backend block

To configure `backend` you need to create a file named `backend.tf` in the root directory of the project and copy the following content 

```bash
terraform {
  # Terraform configuration for Azure backend.
  backend "azurerm" {
    resource_group_name  = "firstname-lastname-backend-tf-rg"
    storage_account_name = "terrformst"
    container_name       = "terrformstate"
    key                  = "aks/terraform.tfstate"
  }
}


```

2. Update the values of the backend attributes with Azure backend config (ask the instructor if needed)

### Step 2: Initialize Terraform

Open the terminal inside the folder
```bash
terraform init
```

## Configure workspace

### Step 1: Create a workspace
Create a namespace named `dev`
```bash
terraform workspace new dev
```

### Step 2: Use workspace inside the code 
Go to `main.tf` and update the `value` of the attribute `name` in the resource `azurerm_resource_group` with `firstname-lastname-rg-${terraform.workspace}`

## Testing Your Configuration

### Step 1: Validate Configuration
```bash
terraform validate
```

### Step 2: Preview Changes
```bash
terraform plan
```

### Step 3: Apply Configuration (when ready)
```bash
terraform apply
```

Type `yes`

### Destroy Resources
```bash
terraform destroy
```

Type `yes`
