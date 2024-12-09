terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
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