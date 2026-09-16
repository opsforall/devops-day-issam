location = "westeurope"
fullname = "karim-arous"
tags = {
  "project" : "azure-aks-project",
  "owner" : "karim-arous"
}
vnet_address_space        = ["10.10.0.0/16"]
aks_subnet_address_prefix = ["10.10.0.0/21"]
cluster_version           = "1.33.3"
private_cluster_enabled   = false

# master nodes
master_max_count          = 3
master_min_count          = 1
master_vm_size            = "Standard_B8s_v2"
master_os_disk_size_gb    = 30
master_availability_zones = ["2"]

# worker nodes
worker_node_name           = "usernodepool"
worker_vm_size             = "Standard_A8_v2"
worker_mode                = "System"
worker_availability_zones  = ["1"]
worker_labels              = {}
worker_enable_auto_scaling = true
worker_max_count           = 3
worker_min_count           = 1
worker_desired_count       = 2
worker_max_pods            = 110
worker_node_taints         = []

# External DNS zone 
dns_zone_name    = "aks.karimarous.com"
dns_zone_rg_name = "azure-terraform"
