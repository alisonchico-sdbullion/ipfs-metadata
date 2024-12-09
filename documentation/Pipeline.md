This GitHub Actions pipeline automates the process of building a Docker image, pushing it to Amazon ECR, and provisioning the required AWS infrastructure using Terraform. The pipeline is structured into two primary jobs:

Build and Push Docker Image
Terraform Infrastructure Management
Pipeline Triggers
The pipeline triggers on:

Pushes to the main branch.
Pull requests to any branch.
Manual workflow dispatch.
Environment Variables
yaml
Copy code
env:
  AWS_REGION: us-east-1
  ENV_PREFIX: prd
  ECR: ipfs
AWS_REGION: Specifies the region where AWS resources will be managed.
ENV_PREFIX: Defines the environment prefix (e.g., production).
ECR: Name of the Elastic Container Registry repository.
Jobs
1. Build and Push Docker Image
Purpose:
To build the Docker image for the Go application and push it to Amazon ECR.

Steps:
Checkout Source Code:

Pulls the repository code.
Configure AWS Credentials:

Uses GitHub secrets to authenticate AWS CLI actions.
Login to Amazon ECR:

Authenticates with ECR for Docker operations.
Build, Tag, and Push Docker Image:

Builds the image using the Dockerfile.
Tags the image with the Git commit hash.
Pushes the image to ECR.
Key Commands:
bash
Copy code
IMAGE_TAG=$(git rev-parse --short HEAD)
export DOCKER_DEFAULT_PLATFORM=linux/amd64
docker build -t $ECR_REGISTRY/$ECR:$IMAGE_TAG .
docker push $ECR_REGISTRY/$ECR:$IMAGE_TAG
echo "image=$ECR_REGISTRY/$ECR:$IMAGE_TAG" >> $GITHUB_OUTPUT
2. Terraform Infrastructure Management
Purpose:
To provision and manage the required AWS infrastructure, such as S3 buckets, DynamoDB tables, and ECR repositories.

Steps:
Checkout Source Code:

Pulls the repository code.
Configure AWS Credentials:

Authenticates AWS CLI actions.
Setup Terraform:

Installs and configures Terraform.
Initialize Terraform:

Prepares the Terraform environment and downloads necessary providers.
Check Existing Resources:

Verifies if the required AWS resources (S3, ECR, DynamoDB) already exist.
Provision Missing Resources:

Applies targeted Terraform configurations to create any missing initial resources.
Backend Configuration:

Configures Terraform backend to store the state in an S3 bucket.
Format Terraform Files:

Ensures Terraform files adhere to formatting standards.
Plan Infrastructure Changes:

Generates a plan for infrastructure changes.
Apply Infrastructure Changes:

Deploys the planned infrastructure changes.
Key Commands:
Check Resources:
bash
Copy code
aws s3 ls s3://iac-tfstate-blockparty-exam-alison || echo "S3 bucket does not exist"
aws ecr describe-repositories --repository-names ipfs || echo "ECR repository does not exist"
aws dynamodb describe-table --table-name terraform_ipfs || echo "DynamoDB table does not exist"
Backend Configuration:
bash
Copy code
echo 'provider "aws" {
  region = "${AWS_REGION}"
}
terraform {
  backend "s3" {
    bucket = "iac-tfstate-blockparty-exam-alison"
    key    = "terraform.tfstate"
    region = "${AWS_REGION}"
  }
}' > backend.tf
