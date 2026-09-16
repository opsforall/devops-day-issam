terraform {
  # Terraform configuration for AWS backend.
  backend "s3" {
    bucket       = "your-terraform-state-bucket"
    key          = "eks-tools/firstname_lastname/terraform.tfstate"
    region       = "bucket-region"
    encrypt      = true
    use_lockfile = true
  }
}