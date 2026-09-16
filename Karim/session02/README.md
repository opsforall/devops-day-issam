# AKS tools - Session 02: Configure CICD and workspace

This session covers configuration of CICD that will provision and destroy the infrastructure

## Update Terraform
Update the block `backend` in `backend.tf` file with the following code

```bash
  backend "s3" {
    bucket       = ""
    key          = ""
    region       = ""
    encrypt      = true
    use_lockfile = true
  }
```

## Configure CICD

### Step 1: Create provision workflow

1. Create a folder in the root directory named `.github`.

2. Inside the folder `.github`, create a folder named `workflows`.

3. Create a file named `install-tools.yml` inside `workflows` and copy the following code

```bash
name: Provision tools

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
      cluster_name:
        description: "Put the name of the EKS cluster to use"
        required: true
        default: "fullname-dev-eks"
        type: string

permissions:
  id-token: write
  contents: read
jobs:
  terraform-apply:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.0
      - name: Init
        working-directory: ./
        run: terraform init -backend-config="bucket=${{ secrets.TF_BACKEND_S3_BUCKET_NAME }}" -backend-config="key=${{ secrets.TF_BACKEND_S3_BUCKET_KEY }}" -backend-config="region=${{ secrets.TF_BACKEND_S3_BUCKET_REGION }}" 
      - name: Terraform workspace select
        working-directory: ./
        run: terraform workspace select ${{ github.event.inputs.workspace }} || terraform workspace new ${{ github.event.inputs.workspace }}
      - name: Terraform plan
        working-directory: ./
        run: terraform plan -var cluster_name=${{ github.event.inputs.cluster_name }}
      - name: Terraform Apply
        working-directory: ./
        run: terraform apply -var cluster_name=${{ github.event.inputs.cluster_name }} -auto-approve
```

4. Create a file named `desinstall-tools.yml` inside `workflows` and copy the following code

```bash
name: Destroy tools

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
      cluster_name:
        description: "Put the name of the AKS cluster to use"
        required: true
        default: "fullname-dev-eks"
        type: string

permissions:
  id-token: write
  contents: read
jobs:
  terraform-destroy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.0
      - name: Init
        working-directory: ./
        run: terraform init -backend-config="bucket=${{ secrets.TF_BACKEND_S3_BUCKET_NAME }}" -backend-config="key=${{ secrets.TF_BACKEND_S3_BUCKET_KEY }}" -backend-config="region=${{ secrets.TF_BACKEND_S3_BUCKET_REGION }}" 
      - name: Terraform workspace select
        working-directory: ./
        run: terraform workspace select ${{ github.event.inputs.workspace }} || terraform workspace new ${{ github.event.inputs.workspace }}
      - name: Terraform plan destroy
        run: terraform plan -destroy -var cluster_name=${{ github.event.inputs.cluster_name }}
        working-directory: ./      
      - name: Terraform Apply
        run: terraform destroy -var cluster_name=${{ github.event.inputs.cluster_name }} -auto-approve
        working-directory: ./
```

5. Delete `terraform.tfvars`

6. Go to your github repository and click on `Settings`

7. Click on `Secrets and variables` in the left section then click on `Actions`

8. Click on `New repository secret`. Create the following secrets:

- Secret 1: (Name: AWS_ACCESS_KEY_ID, Secret: Fill it with the value of aws acces key id)
- Secret 2: (Name: AWS_SECRET_ACCESS_KEY, Secret: Fill it with the value of aws secret access key id)
- Secret 3: (Name: AWS_REGION, Secret: Fill it with the value of your aws region)
- Secret 4: (Name: TF_BACKEND_S3_BUCKET_NAME, Secret: Ask the instructor if needed)
- Secret 5: (Name: TF_BACKEND_S3_BUCKET_KEY, Secret: eks-tools/terraform.tfvars)
- Secret 6: (Name: TF_BACKEND_S3_BUCKET_REGION, Secret: Ask the instructor if needed)

9. Push to Github repo `eks-tools`

## Install tools

1. In your github repository, click on `Actions`

2. In the left panel, click on `Install tools`, click on `Run workflow`, choose `dev` workspace fill the fields `rg_name` and `cluster_name` with your own cluster details. Click on `Run workflow` under them.

### Step 3: desinstall tools 

1. In your github repository, click on `Actions`

2. In the left panel, click on `Desinstall tools`, click on `Run workflow`, choose `dev` workspace fill the fields `rg_name` and `cluster_name` with your own cluster details. Click on `Run workflow` under them.