This GitHub Actions pipeline automates the process of building a Docker image, pushing it to Amazon ECR, and provisioning the required AWS infrastructure using Terraform. The pipeline is structured into two primary jobs:

1. **Build and Push Docker Image**
1. **Terraform Infrastructure Management**
-----
**Pipeline Triggers**

The pipeline triggers on:

- Pushes to the main branch.
- Pull requests to any branch.
- Manual workflow dispatch.
-----
**Environment Variables**

env:

`  `AWS\_REGION: us-east-1

`  `ENV\_PREFIX: prd

`  `ECR: ipfs

- **AWS\_REGION**: Specifies the region where AWS resources will be managed.
- **ENV\_PREFIX**: Defines the environment prefix (e.g., production).
- **ECR**: Name of the Elastic Container Registry repository.
-----
**Jobs**

**1. Build and Push Docker Image**

**Purpose:**

To build the Docker image for the Go application and push it to Amazon ECR.

**Steps:**

1. **Checkout Source Code**:
   1. Pulls the repository code.
1. **Configure AWS Credentials**:
   1. Uses GitHub secrets to authenticate AWS CLI actions.
1. **Login to Amazon ECR**:
   1. Authenticates with ECR for Docker operations.
1. **Build, Tag, and Push Docker Image**:
   1. Builds the image using the Dockerfile.
   1. Tags the image with the Git commit hash.
   1. Pushes the image to ECR.

**Key Commands:**

IMAGE\_TAG=$(git rev-parse --short HEAD)

export DOCKER\_DEFAULT\_PLATFORM=linux/amd64

docker build -t $ECR\_REGISTRY/$ECR:$IMAGE\_TAG .

docker push $ECR\_REGISTRY/$ECR:$IMAGE\_TAG

echo "image=$ECR\_REGISTRY/$ECR:$IMAGE\_TAG" >> $GITHUB\_OUTPUT

-----
**2. Terraform Infrastructure Management**

**Purpose:**

To provision and manage the required AWS infrastructure, such as S3 buckets, DynamoDB tables, and ECR repositories.

**Steps:**

1. **Checkout Source Code**:
   1. Pulls the repository code.
1. **Configure AWS Credentials**:
   1. Authenticates AWS CLI actions.
1. **Setup Terraform**:
   1. Installs and configures Terraform.
1. **Initialize Terraform**:
   1. Prepares the Terraform environment and downloads necessary providers.
1. **Check Existing Resources**:
   1. Verifies if the required AWS resources (S3, ECR, DynamoDB) already exist.
1. **Provision Missing Resources**:
   1. Applies targeted Terraform configurations to create any missing initial resources.
1. **Backend Configuration**:
   1. Configures Terraform backend to store the state in an S3 bucket.
1. **Format Terraform Files**:
   1. Ensures Terraform files adhere to formatting standards.
1. **Plan Infrastructure Changes**:
   1. Generates a plan for infrastructure changes.
1. **Apply Infrastructure Changes**:
   1. Deploys the planned infrastructure changes.

**Key Commands:**

- **Check Resources**:

aws s3 ls s3://iac-tfstate-blockparty-exam-alison || echo "S3 bucket does not exist"

aws ecr describe-repositories --repository-names ipfs || echo "ECR repository does not exist"

aws dynamodb describe-table --table-name terraform\_ipfs || echo "DynamoDB table does not exist"

- **Backend Configuration**:

echo 'provider "aws" {

`  `region = "${AWS\_REGION}"

}

terraform {

`  `backend "s3" {

`    `bucket = "iac-tfstate-blockparty-exam-alison"

`    `key    = "terraform.tfstate"

`    `region = "${AWS\_REGION}"

`  `}

}' > backend.tf

-----
**Advantages of This Pipeline**

1. **Automation**:
   1. Fully automates the process of building and deploying the application and infrastructure.
1. **Reusability**:
   1. Modular jobs (e.g., build, terraform) enable reuse across environments.
1. **Error Handling**:
   1. Verifies the existence of resources before creating or applying changes.
1. **Security**:
   1. Uses GitHub secrets for AWS credentials to secure sensitive data.
1. **Scalability**:
   1. Supports multiple environments (e.g., dev, staging, prod) by parameterizing the environment variables.

