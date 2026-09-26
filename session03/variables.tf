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
