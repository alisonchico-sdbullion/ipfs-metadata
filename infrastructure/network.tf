module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs                          = local.availability_zones
  private_subnets              = [for k, v in local.availability_zones : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets               = [for k, v in local.availability_zones : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets             = [for k, v in local.availability_zones : cidrsubnet(local.vpc_cidr, 8, k + 8)]
  database_subnet_names        = ["DB Subnet"]
  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = true

}