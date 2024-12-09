# Disclaimer

This automation use 3 major automations to deploy a Golang app Container.
 - Docker for containerization (detailed on Containerization.md) 
 - Terraform for infrastructure provision (detailed on Infrastructure.md)
 - Github action workflow for ci/cd provision (detailed on Pipeline.md)

As the purporse of this code is to apply for a exam i detailed additional roadmap that would enhance the automation of the code but was not applied due to time limit.


## Instruction

- If is the first usage you need to follow some specific steps before you trigger the pipeline you need to create a service account on aws, download the security credentials and add on github secrets and variables on settings page of your repo, you need to add this secrets
  - AWS_ACCESS_KEY_ID
  - AWS_REGION
  - AWS_SECRET_ACCESS_KEY    
- After that you will need to apply ecr, s3 bucket and dynamodb tables mannualy, as this is necessary for the enablement of terraform and so the pipeline be able to push the build artefact, to do that you need to install terraform on your computer (latest version) and apply the following targets:
  - terraform init
  - terraform apply -target=module.s3_tf-state.aws_s3_bucket.this[0]
  - terraform apply -target=aws_ecr_repository.ipfs
  - terraform apply -target=aws_dynamodb_table.terraform_locks
- Uncomment the code on backend.tf  
- By end execute terraform init --migrate-state that will move your state to the bucket, following this approachs you can trigger the pipeline.