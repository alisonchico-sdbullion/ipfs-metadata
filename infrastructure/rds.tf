module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier                            = local.name
  engine                                = "postgres"
  engine_version                        = "14"
  engine_lifecycle_support              = "open-source-rds-extended-support-disabled"
  family                                = "postgres14"
  major_engine_version                  = "14"
  instance_class                        = "db.t4g.large"
  allocated_storage                     = 20
  max_allocated_storage                 = 100
  db_name                               = "ipfs"
  username                              = jsondecode(aws_secretsmanager_secret_version.db_master_password.secret_string)["username"]
  manage_master_user_password           = true
  port                                  = 5432
  multi_az                              = true
  db_subnet_group_name                  = module.vpc.database_subnet_group
  vpc_security_group_ids                = [module.security_group.security_group_id]
  maintenance_window                    = "Mon:00:00-Mon:03:00"
  backup_window                         = "03:00-06:00"
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  create_cloudwatch_log_group           = true
  backup_retention_period               = 1
  skip_final_snapshot                   = true
  deletion_protection                   = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${local.name}-rds-monitoring"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "${local.name}-rds-monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  cloudwatch_log_group_tags = {
    "Sensitive" = "high"
  }
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-db_sg"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}