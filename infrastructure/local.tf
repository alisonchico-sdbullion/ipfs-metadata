data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  region = var.region
  name   = var.name

  tags = {
    Name       = local.name
    Repository = "https://github.com/alisonchico-sdbullion/ipfs-metadata"
  }

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)

  secrets = [
    {
      name      = "DB_ADDRESS"
      valueFrom = aws_secretsmanager_secret.db_connection_details.arn
    },
    {
      name      = "DB_MASTER_USER_SECRET_ARN"
      valueFrom = module.db.db_instance_master_user_secret_arn
    }
  ]

  containers_template = templatefile("${path.module}/app.json.tpl",
    {
      app_name     = local.name
      docker_image = var.docker_image
      app_port     = var.app_port
      cpu          = var.cpu
      memory       = var.memory
      secrets      = join(",", [for secret in local.secrets : jsonencode(secret)])
      environment  = var.environment
      region       = local.region
    }
  )
}