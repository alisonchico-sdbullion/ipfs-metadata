terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  #   backend "s3" {
  #     bucket         = "iac-terraform-api2"
  #     key            = "ecs/api.tfstate"
  #     region         = "us-east-1"
  #     dynamodb_table = "terraform_${local.name}"
  #   }
}

resource "aws_dynamodb_table" "terraform_locks" {
  count        = terraform.workspace == "default" ? 1 : 0
  name         = "terraform_${local.name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}