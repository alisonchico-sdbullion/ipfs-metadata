module "s3_tf-state" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "iac-tfstate"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}