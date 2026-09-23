terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.61.0"
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