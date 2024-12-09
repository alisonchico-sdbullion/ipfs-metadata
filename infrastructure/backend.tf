terraform {
  backend "s3" {
    bucket         = "iac-tfstate-blockparty-exam-alison"
    key            = "ecs/api.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_ipfs"
  }
}