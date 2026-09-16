variable "location" {
  type = string
}

variable "fullname" {
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
  type = string
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

# External DNS zone role assignment for AKS
variable "dns_zone_name" {
  type = string
}

variable "dns_zone_rg_name" {
  type = string
}
