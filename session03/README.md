# Azure AKS - Session 03: Add Terraform modules and use them

This session covers the creation of Terraform modules and how to use them

## Create network module

1. Create a folder named `modules` in the root directory of the project and create inside it another folder named `network`
2. Create a file named `main.tf` inside the folder `network` and copy the following content

```bash
# virtual network 
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.studentid}-${var.env}-virtual-network"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_address_space
}

# aks subnets
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.studentid}-aks-subnet-${var.env}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.aks_subnet_address_prefix
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

```

3. Create a file named `variables.tf` inside the folder `network` and copy the following content

```bash
variable "location" {
  type = string
}

variable "env" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "studentid" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_address_prefix" {
  type = list(string)
}

```

4. Create a file named `outputs.tf` inside the folder `network` and copy the following content

```bash
# virtual network ID
output "vnetID" {
  value       = azurerm_virtual_network.virtual_network.id
  description = "ID of virtual network"
}

# vnet aks subnet
output "aks_subnet_id" {
  value       = azurerm_subnet.aks_subnet.id
  description = "AKS Subnet ID"
}
```

## Create AKS module

1. Inside the folder `modules`, create a folder named `aks`
2. Create a file named `main.tf` inside the folder `aks` and copy the following content

```bash
# creating AKS cluster
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "${var.studentid}-aks-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.resource_group_name
  kubernetes_version  = var.cluster_version
  node_resource_group = "${var.studentid}-aks-nodes-rg-${var.env}"
  private_cluster_enabled = var.private_cluster_enabled
  default_node_pool {
    name                = "defaultpool"
    vm_size             = var.master_vm_size
    zones               = var.master_availability_zones
    auto_scaling_enabled = true
    max_count           = var.master_max_count
    min_count           = var.master_min_count
    vnet_subnet_id      = var.vnet_subnet_id
    os_disk_size_gb     = var.master_os_disk_size_gb
    temporary_name_for_rotation = "master"
    type                = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.env
      "nodepoolos"    = "linux"
    }
    upgrade_settings {
      max_surge                     = "33%"   # allow up to 33% extra nodes during upgrade
      drain_timeout_in_minutes      = 30      # timeout for draining a node
      node_soak_duration_in_minutes = 10      # wait time before node is considered stable
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = var.env
      "nodepoolos"    = "linux"
      "created_by"  = var.studentid
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_plugin_mode = "overlay"
    network_data_plane = "cilium"
    pod_cidr = "10.244.0.0/16"
    service_cidr = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
  }
  oidc_issuer_enabled = var.oidc_issuer_enabled

  lifecycle {
    ignore_changes = [
      default_node_pool[0].tags
    ]
  }
}

```

3. Create a file named `variables.tf` inside the folder `aks` and copy the following content

```bash
# location
variable "location" {
  type        = string
  description = "location of the resource group"
}

# resource group name
variable "resource_group_name" {
  type        = string
  description = "name of the resource group"
}

# environment
variable "env" {
  type        = string
  description = "environment"
}

variable "cluster_version" {
  type        = string
  description = "AKS cluster version"
}

variable "oidc_issuer_enabled" {
  description = " (Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
  default     = true
}

variable "studentid" {
  type = string
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

# subnet ID
variable "vnet_subnet_id" {
  type        = string
  description = "Subnet ID for worker node"
}

# Master nodes 
variable "master_max_count" {
  type        = number
  description = "Maximum node count for master node"
}

variable "master_min_count" {
  type        = number
  description = "Minimum node count for master node"
}

variable "master_vm_size" {
  type        = string
  description = "Master nodes size"
}

variable "master_os_disk_size_gb" {
  description = "(Optional) The Agent Operating System disk size in GB. Changing this forces a new resource to be created."
  type          = number
  default       = null
} 

variable "master_availability_zones" {
  type = list(string)
}

```

4. Create a file named `outputs.tf` inside the folder `aks` and copy the following content

```bash
# AKS cluster name 
output "kubernetes_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks-cluster.name
  description = "Name of the AKS Cluster"
}

# AKS Cluster ID
output "kubernetes_cluster_id" {
  value       = azurerm_kubernetes_cluster.aks-cluster.id
  description = "ID of the AKS Cluster"
}

# FQDN of nodes
output "kubernetes_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.aks-cluster.fqdn
}

```

5. Replace the content of the file named `main.tf` in the root directory of the project with the following content

```bash
resource "azurerm_resource_group" "rg" {
  name     = "${var.studentid}-rg-${local.env}"
  location = var.location
}

module "network" {
  source = "./modules/network"

  env = local.env
  rg_name = azurerm_resource_group.rg.name
  location = var.location
  studentid = var.studentid
  vnet_address_space = var.vnet_address_space
  aks_subnet_address_prefix = var.aks_subnet_address_prefix
}

module "aks" {
  source = "./modules/aks"

  env = local.env
  location = var.location
  studentid = var.studentid
  cluster_version = var.cluster_version
  resource_group_name = azurerm_resource_group.rg.name
  vnet_subnet_id = module.network.aks_subnet_id
  private_cluster_enabled = var.private_cluster_enabled
  # master nodes
  master_max_count = var.master_max_count
  master_min_count = var.master_min_count
  master_vm_size = var.master_vm_size
  master_os_disk_size_gb = var.master_os_disk_size_gb
  depends_on = [ module.network ]
}


```

6. Replace the content of the file named `variables.tf` in the root directory of the project with the following content

```bash
variable "location" {
  type = string
}

variable "studentid" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_address_prefix" {
  type = list(string)
}

variable "cluster_version" {
  type = string
}

variable "private_cluster_enabled" {
  type = string
}

# master nodes
variable "master_max_count" {
  type = number
}

variable "master_min_count" {
  type = number
}

variable "master_vm_size" {
  type = string
}

variable "master_os_disk_size_gb" {
  type = number 
}

variable "master_availability_zones" {
  type = list(string)
}

```

8. Replace the content of the file named `terraform.tfvars` in the root directory of the project with the following content

```bash
location = "westeurope"
studentid = "studentid"
vnet_address_space = ["10.10.0.0/16"]
aks_subnet_address_prefix = ["10.10.0.0/21"]
cluster_version = "1.35.7"
private_cluster_enabled = false

# master nodes
master_max_count = 3
master_min_count = 1
master_vm_size = "Standard_B8s_v2"
master_os_disk_size_gb = 30
master_availability_zones = ["3"]

```

Update `studentid` value, example `student1`
9. Push to Github repo `azure-aks-project`

10. Run workflow `Provision Infrastructure`

11. Run workflow `Destroy Infrastructure`

