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
  tags                = var.tags
}

# aks subnets
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.studentid}-aks-subnet-${var.env}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.aks_subnet_address_prefix
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

# NSG for aks subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = var.rg_name
  tags = var.tags
}

resource "azurerm_network_security_rule" "aks_nsg_inbound" {
  for_each = var.aks_nsg_inbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type 
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix_cidr 
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on = [ azurerm_network_security_group.aks_nsg]
}

resource "azurerm_network_security_rule" "aks_nsg_outbound" {
  for_each = var.aks_nsg_outbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type 
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix_cidr 
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on = [ azurerm_network_security_group.aks_nsg]
}

resource "azurerm_subnet_network_security_group_association" "nsg_associate_aks_subnet" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
  depends_on = [ azurerm_network_security_group.aks_nsg, azurerm_subnet.aks_subnet ]
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

variable "tags" {
  type = map(string)
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_address_prefix" {
  type = list(string)
}

variable "aks_nsg_inbound_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    rule_type                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix_cidr = string
    destination_address_prefix = string
  }))
}

variable "aks_nsg_outbound_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    rule_type                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix_cidr = string
    destination_address_prefix = string
  }))
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
  tags = {
    "environment" = var.env
    "created_by"  = var.studentid
  }
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
/*
resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  name                         = var.worker_node_name
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks-cluster.id
  vm_size                      = var.worker_vm_size
  mode                         = var.worker_mode
  zones                        = var.worker_availability_zones
  node_labels                  = var.worker_labels
  auto_scaling_enabled         = var.worker_enable_auto_scaling
  host_encryption_enabled      = var.worker_enable_host_encryption
  node_public_ip_enabled       = var.worker_enable_node_public_ip
  max_pods                     = var.worker_max_pods
  node_taints                  = var.worker_node_taints
  vnet_subnet_id               = var.vnet_subnet_id
  pod_subnet_id                = var.worker_pod_subnet_id
  orchestrator_version         = var.worker_orchestrator_version
  max_count                    = var.worker_max_count
  min_count                    = var.worker_min_count
  node_count                   = var.worker_desired_count
  os_type                      = var.worker_os_type
  priority                     = var.worker_priority
  tags                         = var.tags
  temporary_name_for_rotation = "worker"
  upgrade_settings {
    max_surge                     = "33%"   # allow up to 33% extra nodes during upgrade
    drain_timeout_in_minutes      = 30      # timeout for draining a node
    node_soak_duration_in_minutes = 10      # wait time before node is considered stable
  }
  lifecycle {
    ignore_changes = [
        tags
    ]
  }
  depends_on = [ azurerm_kubernetes_cluster.aks-cluster ]
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

variable "tags" {
  description = "(Optional) Specifies the tags of the network security group"
  default     = {}
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

# Size of worker nodes
variable "worker_node_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
}

variable "worker_vm_size" {
  description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string
}

variable "worker_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type          = string
  default       = "User"
} 

variable "worker_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1"]
}

variable "worker_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type          = map(any)
  default       = {}
} 

variable "worker_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type          = bool
  default       = true
}

variable "worker_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type          = bool
  default       = false
} 

variable "worker_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type          = bool
  default       = false
} 

variable "worker_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type          = number
  default       = 130
}

variable "worker_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type          = list(string)
  default       = []
} 

variable "worker_pod_subnet_id" {
  description = "(Optional) The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created."
  type          = string
  default       = null
}

variable "worker_orchestrator_version" {
  description = "(Optional) Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)"
  type          = string
  default       = null
} 

variable "worker_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type          = number
  default       = 2
}

variable "worker_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type          = number
  default       = 1
}

variable "worker_desired_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type          = number
  default       = 1
}

variable "worker_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type          = string
  default       = "Linux"
} 

variable "worker_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type          = string
  default       = "Regular"
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
  tags = var.tags
  vnet_address_space = var.vnet_address_space
  aks_subnet_address_prefix = var.aks_subnet_address_prefix
  aks_nsg_inbound_rules = local.aks_nsg_inbound_rules
  aks_nsg_outbound_rules = local.aks_nsg_outbound_rules
}

module "aks" {
  source = "./modules/aks"

  env = local.env
  location = var.location
  studentid = var.studentid
  cluster_version = var.cluster_version
  tags = var.tags
  resource_group_name = azurerm_resource_group.rg.name
  vnet_subnet_id = module.network.aks_subnet_id
  private_cluster_enabled = var.private_cluster_enabled
  # master nodes
  master_max_count = var.master_max_count
  master_min_count = var.master_min_count
  master_vm_size = var.master_vm_size
  master_os_disk_size_gb = var.master_os_disk_size_gb
  master_availability_zones = var.master_availability_zones
  # worker nodes
  worker_node_name = var.worker_node_name
  worker_vm_size = var.worker_vm_size
  worker_mode = var.worker_mode
  worker_availability_zones = var.worker_availability_zones
  worker_labels = var.worker_labels
  worker_enable_auto_scaling = var.worker_enable_auto_scaling
  worker_max_count = var.worker_max_count
  worker_min_count = var.worker_min_count
  worker_desired_count = var.worker_desired_count
  worker_max_pods = var.worker_max_pods
  worker_node_taints = var.worker_node_taints
  dns_zone_name = var.dns_zone_name
  dns_zone_rg_name = var.dns_zone_rg_name
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

variable "tags" {
  type = map(string)
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

# worker nodes
variable "worker_node_name" {
  type = string
}

variable "worker_vm_size" {
  type = string
}

variable "worker_mode" {
  type        = string
}

variable "worker_availability_zones" {
  type = list(string)
}

variable "worker_labels" {
  type = map(any)
}

variable "worker_enable_auto_scaling" {
  type = bool
}

variable "worker_max_count" {
  type = number
}

variable "worker_min_count" {
  type = number
}

variable "worker_desired_count" {
  type = number
}

variable "worker_max_pods" {
  type = number
}

variable "worker_node_taints" {
  type = list(string)
}

```

8. Replace the content of the file named `terraform.tfvars` in the root directory of the project with the following content

```bash
location = "westeurope"
studentid = "studentid"
vnet_address_space = ["10.10.0.0/16"]
aks_subnet_address_prefix = ["10.10.0.0/21"]
cluster_version = "1.33.3"
private_cluster_enabled = false

# master nodes
master_max_count = 3
master_min_count = 1
master_vm_size = "Standard_B8s_v2"
master_os_disk_size_gb = 30
master_availability_zones = ["2"]

# worker nodes
worker_node_name = "usernodepool"
worker_vm_size = "Standard_A8_v2"
worker_mode = "System"
worker_availability_zones = ["1"]
worker_labels = {}
worker_enable_auto_scaling = true
worker_max_count = 3
worker_min_count = 1
worker_desired_count = 2
worker_max_pods = 110
worker_node_taints = []

```

Update `studentid` value, example `student1`
9. Push to Github repo `azure-aks-project`

10. Run workflow `Provision Infrastructure`

11. Run workflow `Destroy Infrastructure`

