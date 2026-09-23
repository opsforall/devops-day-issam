# AKS Tools - Session 01: Configure providers and backend

## Configure Terraform backend

1. Create a file named `backend.tf` in the root directory of the project and copy the following content

```bash
terraform {
  # Terraform configuration for Azure backend.
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "aks-tools/firstname_lastname/terraform.tfstate"
    region       = "bucket-region"
    encrypt      = true
    use_lockfile = true
  }
}
```
Update `firstname_lastname` with you name, example `karim_arous` 

2. Update the values of the backend attributes with AWS S3 backend config (bucket,region)

## Configure providers

1. Create a file named `providers.tf` in the root directory of the project and copy the following content

```bash
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.59.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }
  required_version = ">= 1.14.0"
}

# azurerm Provider configuration
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = ""
  tenant_id       = ""
}

data "azurerm_kubernetes_cluster" "example" {
  name                = var.cluster_name
  resource_group_name = var.rg_name
}

# kubernetes Provider configuration
provider "kubernetes" {
  host                   = local.kube_host
  client_certificate     = local.kube_client_certificate
  client_key             = local.kube_client_key
  cluster_ca_certificate = local.kube_cluster_ca_certificate
}

# kubectl Provider configuration
provider "kubectl" {
  host                   = local.kube_host
  client_certificate     = local.kube_client_certificate
  client_key             = local.kube_client_key
  cluster_ca_certificate = local.kube_cluster_ca_certificate

  load_config_file = false
}

# helm Provider configuration
provider "helm" {
  kubernetes {
    host                   = local.kube_host
    client_certificate     = local.kube_client_certificate
    client_key             = local.kube_client_key
    cluster_ca_certificate = local.kube_cluster_ca_certificate
  }
}

```

2. Create a file named `locals.tf` in the root directory of the project and copy the following content

```bash
locals {
  kube_host                   = data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].host
  kube_client_certificate     = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].client_certificate)
  kube_client_key             = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].client_key)
  kube_cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].cluster_ca_certificate)
}
```

3. Create a file named `variables.tf` in the root directory of the project and copy the following content

```bash
variable "cluster_name" {
  type = string
}
```

4. Create a file named `terraform.tfvars` in the root directory of the project and copy the following content

```bash
cluster_name = "youraksname"
```

5. Update `cluster_name` value with your real AKS cluster name

## Test configuration

1. Run `terraform init`

2. Run `terraform apply -auto-approve` 

3. Run `terraform destroy -auto-approve` 
