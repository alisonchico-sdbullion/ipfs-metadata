terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
    backend "s3" {
      bucket         = "iac-tfstate-blockparty-exam-alison"
      key            = "ecs/api.tfstate"
      region         = "us-east-1"
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
  count        = terraform.workspace == "default" ? 1 : 0
  name         = "terraform_ipfs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}