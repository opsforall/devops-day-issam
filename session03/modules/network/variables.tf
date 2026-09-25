variable "location" {
  type = string
}

variable "env" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "fullname" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_address_prefix" {
  type = list(string)
}
