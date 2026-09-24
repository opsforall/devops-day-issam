# Azure AKS - Session 03: Configure CICD

This session covers configuration of CICD that will provision and destroy the infrastructure

## Obtain a Client ID

### Step 1: Go to App registration

In the search bar of the Azure portal type `App registrations` and click on it. Now click on `New Registration`

### Step 2: Create an App registration

1. Click on `New Registration` 
2. fill it as the following:
- In the `name` section put `studentid-terraform` example `student1-terraform` 
- in the `Supported account types` choose `Single tenant Only - KA Dir`
3. Click on `Register`
4. Copy The `Application (client) ID` and `Directory (tenant) ID` values and save them in a safe place. We wil use them in the next steps.

### Step 3: Create Federated Credentials

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

* Repository: `azure-aks-project`
* Repository ID: ``
To get this value, copy this command in your `VS Code` CLI and don't forget to replace `username` with your `Github` user:

```bash
gh api repos/username/azure-aks-project --jq '.id'
```
* Entity type: `Branch`
* GitHub branch name: `main`

- In the section `Credential details`, go to `Name` and put `azure-aks-project`

- Click `Add`

### Step 4: Create role binding for service principale

1. Go to your subscription and click on `Access control (IAM)`

2. Click on `Add` and choose `Add Role Assignment` 

3. Go to `Privileged administrator roles`, choose `Owner` and click `Next`

4. Ensure you have choosed `User, group, or service principal` in `Assign access to` section, click `Select members` in Members section. Search for your App registration that you created it in `step 2`, choose it, click `select` and click `Next`

5. In the `What user can do` choose `Allow user to assign all roles (highly privileged)` and then click `Next`

6. Click `Review + assign`

## Configure CICD

### Step 1: Configure Github Actions secrets

1. Go to your github repository `azure-aks-project` and click on `Settings`

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

3. Create a file named `provision-infra.yml` inside `workflows` and copy the following code

```bash
name: Provision Infrastructure

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

permissions:
  id-token: write
  contents: read
jobs:
  terraform-apply:
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
          terraform_version: 1.16.3
      - name: Init
        working-directory: ./
        run:  terraform init -backend-config="resource_group_name=${{ secrets.TF_BACKEND_RG }}" -backend-config="storage_account_name=${{ secrets.TF_BACKEND_STORAGE_ACCOUNT }}" -backend-config="container_name=${{ secrets.TF_BACKEND_CONTAINER }}" -backend-config="key=${{ secrets.TF_BACKEND_KEY }}"
      - name: Terraform workspace select
        working-directory: ./
        run: terraform workspace select ${{ github.event.inputs.workspace }} || terraform workspace new ${{ github.event.inputs.workspace }}
      - name: Terraform Plan
        working-directory: ./
        run: terraform plan
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - name: Terraform Apply
        working-directory: ./
        run: terraform apply -auto-approve
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

4. Create a file named `destroy-infra.yml` inside `workflows` and copy the following code

```bash
name: Destroy Infrastructure

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
          
permissions:
  id-token: write
  contents: read
jobs:
  terraform-destroy:
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

## Update Terraform

1. Replace all the code that exist in the in `backend.tf` file with the following code

```bash
terraform {
  backend "azurerm" {
  }
}
```

2. Delete unwanted files and folders

In the root directory, delete `.terraform` folder and `.terraform.lock.hcl`


## Provision infrastructure
1. Push to Github repo `azure-aks-project`

2. In your github repository, click on `Actions`

3. In the left panel, click on `Provision Infrastructure`, click on `Run workflow` and click on `Run workflow` that apears.
