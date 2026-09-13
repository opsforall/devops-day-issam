# Azure AKS Terraform Workshop

This repository contains a step-by-step Terraform workshop for provisioning an
[Azure AKS](https://azure.microsoft.com/fr-fr/products/kubernetes-service) cluster on Azure. Each
`sessionXX` directory builds on the previous one, gradually introducing new
Terraform features and best practices.

---

## Repository Structure

- `session00/` – Initial setup with only a README.
- `session01/` through `session06/` – Incremental sessions demonstrating:
  - Basic Terraform configuration and AWS provider setup
  - Remote state backend using storage account and workspace configuration
  - GitHub Actions workflows for provisioning and destruction
  - Network infrastructure configuration (variables, locals and .tfvars) 
  - Network module configuration
  - AKS module configuration

## Getting Started

1. **Set up AWS credentials**: Ensure your AWS CLI or environment variables are
configured (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.).
2. **Choose a session**: Start at `session00` if you want to follow along from
the beginning. Later sessions depend on earlier ones but are independent in
terms of working Terraform code.


## GitHub Actions

A pair of workflows (`provision-infra.yml` and `destroy-infra.yml`) located in
`session03` and onward demonstrate how to automate Terraform operations with
GitHub Actions. Adjust your secrets and AWS credentials accordingly.

## Notes

- The repository is not production-ready; it is educational and intended for
  learning Terraform concepts.
- Clean up your AWS resources (`terraform destroy`) after each session to avoid
  unnecessary charges.

---

Happy provisioning! :rocket:
