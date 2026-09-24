location = "westeurope"
fullname = "karim-arous"
vnet_address_space        = ["10.10.0.0/16"]
aks_subnet_address_prefix = ["10.10.0.0/21"]
cluster_version = "1.35.7"
private_cluster_enabled   = false

# master nodes
master_max_count          = 3
master_min_count          = 1
master_vm_size            = "Standard_B8s_v2"
master_os_disk_size_gb    = 30
master_availability_zones = ["3"]
