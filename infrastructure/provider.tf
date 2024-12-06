terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
  }
  backend "s3" {
    bucket         = "iac-terraform-api2"
    key            = "ecs/api.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks_api"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  count        = terraform.workspace == "default" ? 1 : 0
  name         = "terraform_locks_${var.name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}