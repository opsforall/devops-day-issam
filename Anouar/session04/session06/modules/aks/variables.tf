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

variable "acr_id" {
  type = string
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

variable "fullname" {
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
  type        = number
  default     = null
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
  type        = string
  default     = "User"
}

variable "worker_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1"]
}

variable "worker_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "worker_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "worker_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "worker_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "worker_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 130
}

variable "worker_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

variable "worker_pod_subnet_id" {
  description = "(Optional) The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "worker_orchestrator_version" {
  description = "(Optional) Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)"
  type        = string
  default     = null
}

variable "worker_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 2
}

variable "worker_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 1
}

variable "worker_desired_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 1
}

variable "worker_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type        = string
  default     = "Linux"
}

variable "worker_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type        = string
  default     = "Regular"
}

variable "dns_zone_name" {
  description = "(Optional) The name of the DNS Zone to which the AKS cluster should be granted permissions to create records. This is required if you want to use External DNS with this cluster."
  type        = string
}

variable "dns_zone_rg_name" {
  description = "(Optional) The name of the Resource Group in which the DNS Zone specified in dns_zone_name is located. This is required if you want to use External DNS with this cluster."
  type        = string
}
