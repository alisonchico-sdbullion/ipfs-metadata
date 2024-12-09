data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

data "aws_ecr_repository" "ipfs_ecr_repository" {
  name = data.aws_ecr_image.ipfs_ecr.repository_name
}

data "aws_ecr_image" "ipfs_ecr" {
  repository_name = "ipfs"
  most_recent     = true
}


locals {
  region = var.region
  name   = var.name

  tags = {
    Name       = local.name
    Repository = "https://github.com/alisonchico-sdbullion/ipfs-metadata"
  }

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)

  ecs_image = "${data.aws_ecr_repository.ipfs_ecr_repository.repository_url}:${data.aws_ecr_image.ipfs_ecr.image_tags[0]}"
}