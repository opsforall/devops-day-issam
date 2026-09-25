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
