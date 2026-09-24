# AKS Tools - Session 01: Configure providers and backend


## Obtain a Client ID

### Step 1: Go to App registration

In the search bar of the Azure portal type `App registrations` and click on the one that you have created in the other project.  

### Step 2: Create Federated Credentials

1. Inside the `App Registration` that we have created in the previous step, click on `Manage` then click on `Certificates & secrets` in the left panel.

2. Click on Federated credentials

3. Click Add credential

4. fill it as the following:

- In `Federated credential` scenario, choose `GitHub Actions deploying Azure resources`
 
- In the section that will showup, fill it with:
* Organization: `your-org`, example: `karimarous` is the name of my Organization
* Organization ID: `your-org`, example: `45014080` is the name of my Organization

In order to get your Organization ID value, copy these commands in your `VS Code` CLI:

```bash
gh auth login
```
```bash
gh api user --jq '.id'
```

* Repository: `aks-tools`
* Repository ID: ``
To get this value, copy this command in your `VS Code` CLI and don't forget to replace `username` with your `Github` user:

```bash
gh api repos/karimarous/aks-tools --jq '.id'
```
* Entity type: `Branch`
* GitHub branch name: `main`

- In the section `Credential details`, go to `Name` and put `aks-tools`

- Click `Add`

## Configure CICD

### Step 1: Configure Github Actions secrets

1. Go to your github repository `aks-tools` and click on `Settings`

2. Click on `Secrets and variables` in the left section then click on `Actions`

3. Click on `New repository secret`
Create the following secrets:
- AZURE_CLIENT_ID 
Fill it with the value of Application (client) ID
- AZURE_TENANT_ID
Fill it with the value of Directory (tenant) ID that exist in the App registration created in the section `Obtain a Client ID`
- AZURE_SUBSCRIPTION_ID
Fill it with the value of your Subscription
You can get the subscription value using this command
```
az account show --query id -o tsv
```
- TF_BACKEND_RG
Ask the instructor if needed
- TF_BACKEND_STORAGE_ACCOUNT
Ask the instructor if needed
- TF_BACKEND_CONTAINER
Ask the instructor if needed
- TF_BACKEND_KEY
Ask the instructor if needed

### Step 2: Create workflows

1. Create a folder in the root directory named `.github`.

2. Inside the folder `.github`, create a folder named `workflows`.

3. Create a file named `install-tools.yaml` inside `workflows` and copy the following code

```bash
name: Install tools

on:
  workflow_dispatch:
    inputs:
      workspace:
        description: "Select our Terraform workspace to use"
        required: true
        default: "dev"
        type: choice
        options:
          - dev
      rg_name:
        description: "Put the name of the resource group to use"
        required: true
        default: "studentid-rg-dev"
        type: string
      cluster_name:
        description: "Put the name of the AKS cluster to use"
        required: true
        default: "studentid-aks-dev"
        type: string

permissions:
  id-token: write
  contents: read
jobs:
  intall-tools:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          enable-AzPSSession: true

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.0
      - name: Init
        working-directory: ./
        run:  terraform init -backend-config="resource_group_name=${{ secrets.TF_BACKEND_RG }}" -backend-config="storage_account_name=${{ secrets.TF_BACKEND_STORAGE_ACCOUNT }}" -backend-config="container_name=${{ secrets.TF_BACKEND_CONTAINER }}" -backend-config="key=${{ secrets.TF_BACKEND_KEY }}"
      - name: Terraform workspace select
        working-directory: ./
        run: terraform workspace select ${{ github.event.inputs.workspace }} || terraform workspace new ${{ github.event.inputs.workspace }}
      - name: Terraform Plan
        working-directory: ./
        run: terraform plan -var="rg_name=${{ github.event.inputs.rg_name }}" -var="cluster_name=${{ github.event.inputs.cluster_name }}"
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - name: Terraform Apply
        working-directory: ./
        run: terraform apply -var="rg_name=${{ github.event.inputs.rg_name }}" -var="cluster_name=${{ github.event.inputs.cluster_name }}" -auto-approve
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

Update `studentid`, for example `student1`

4. Create a file named `desinstall-tools.yaml` inside `workflows` and copy the following code

```bash
name: Desinstall tools

on:
  workflow_dispatch:
    inputs:
      workspace:
        description: "Select our Terraform workspace to use"
        required: true
        default: "dev"
        type: choice
        options:
          - dev
      rg_name:
        description: "Put the name of the resource group to use"
        required: true
        default: "karim-arous-rg-dev"
        type: string
      cluster_name:
        description: "Put the name of the AKS cluster to use"
        required: true
        default: "karim-arous-aks-dev"
        type: string

permissions:
  id-token: write
  contents: read
jobs:
  desintall-tools:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          enable-AzPSSession: true

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.0
      - name: Init
        working-directory: ./
        run:  terraform init  -backend-config="resource_group_name=${{ secrets.TF_BACKEND_RG }}" -backend-config="storage_account_name=${{ secrets.TF_BACKEND_STORAGE_ACCOUNT }}" -backend-config="container_name=${{ secrets.TF_BACKEND_CONTAINER }}" -backend-config="key=${{ secrets.TF_BACKEND_KEY }}"
      - name: Terraform workspace select
        working-directory: ./
        run: terraform workspace select ${{ github.event.inputs.workspace }} 
      - name: Terraform Plan destroy
        working-directory: ./
        run: terraform plan -destroy
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - name: Terraform Destroy
        working-directory: ./
        run: terraform destroy -auto-approve
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

```

Update `studentid`, for example `student1`


## Configure Terraform backend

1. Create a file named `backend.tf` in the root directory of the project and copy the following content

```bash
terraform {
  backend "azurerm" {
  }
}
```

## Configure providers

1. Create a file named `providers.tf` in the root directory of the project and copy the following content

```bash
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.59.0"
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
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

data "azurerm_kubernetes_cluster" "my_cluster" {
  name                = var.cluster_name
  resource_group_name = var.rg_name
}

# kubernetes Provider configuration
provider "kubernetes" {
  host                   = local.kube_host
  client_certificate     = local.kube_client_certificate
  client_key             = local.kube_client_key
  cluster_ca_certificate = local.kube_cluster_ca_certificate
}

# kubectl Provider configuration
provider "kubectl" {
  host                   = local.kube_host
  client_certificate     = local.kube_client_certificate
  client_key             = local.kube_client_key
  cluster_ca_certificate = local.kube_cluster_ca_certificate

  load_config_file = false
}

# helm Provider configuration
provider "helm" {
  kubernetes {
    host                   = local.kube_host
    client_certificate     = local.kube_client_certificate
    client_key             = local.kube_client_key
    cluster_ca_certificate = local.kube_cluster_ca_certificate
  }
}

```

2. Create a file named `locals.tf` in the root directory of the project and copy the following content

```bash
locals {
  kube_host                   = data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].host
  kube_client_certificate     = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].client_certificate)
  kube_client_key             = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].client_key)
  kube_cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.my_cluster.kube_admin_config[0].cluster_ca_certificate)
}
```

3. Create a file named `variables.tf` in the root directory of the project and copy the following content

```bash
variable "cluster_name" {
  type = string
}
```

## Provision infrastructure
1. Push to Github repo `azure-aks-project`

2. In your github repository, click on `Actions`

3. In the left panel, click on `Provision Infrastructure`, click on `Run workflow` and click on `Run workflow` that apears.
