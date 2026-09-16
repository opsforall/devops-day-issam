# EKS Tools - Session 01: Configure providers and backend

## Configure Terraform backend

1. Create a file named `backend.tf` in the root directory of the project and copy the following content

```bash
terraform {
  # Terraform configuration for Azure backend.
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "eks-tools/firstname_lastname/terraform.tfstate"
    region       = "bucket-region"
    encrypt      = true
    use_lockfile = true
  }
}
```
Update `firstname_lastname` with you name, example `karim_arous` 

2. Update the values of the backend attributes with AWS S3 backend config (bucket,region)

## Configure providers

1. Create a file named `providers.tf` in the root directory of the project and copy the following content

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.32.0"
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
provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "eks_cluster" {
  name                = var.cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.cluster_name
}

# kubernetes Provider configuration
provider "kubernetes" {
  host                   = local.kube_host
  cluster_ca_certificate = local.kube_cluster_ca_certificate
  token                  = local.token
}

# kubectl Provider configuration
provider "kubectl" {
  host                   = local.kube_host
  cluster_ca_certificate = local.kube_cluster_ca_certificate
  token                  = local.token

  load_config_file = false
}

# helm Provider configuration
provider "helm" {
  kubernetes {
    host                   = local.kube_host
    cluster_ca_certificate = local.kube_cluster_ca_certificate
    token                  = local.token
  }
}
```

2. Create a file named `locals.tf` in the root directory of the project and copy the following content

```bash
locals {
  kube_host                   = data.aws_eks_cluster.eks_cluster.endpoint
  kube_cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.eks_cluster_auth.token
}
```

3. Create a file named `variables.tf` in the root directory of the project and copy the following content

```bash
variable "cluster_name" {
  type = string
}
```

4. Create a file named `terraform.tfvars` in the root directory of the project and copy the following content

```bash
cluster_name = "youreksname"
```

5. Update `cluster_name` value with your real eks cluster name

## Test configuration

1. Run `terraform init`

2. Run `terraform apply -auto-approve` 

3. Run `terraform destroy -auto-approve` 
