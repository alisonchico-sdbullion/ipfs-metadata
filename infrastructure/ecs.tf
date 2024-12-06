# ###############################################################################
# # Cluster
# ###############################################################################

module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws//modules/cluster"
  version      = "v5.7.0"
  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.tags
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  depends_on             = [module.ecs_cluster]
  source                 = "terraform-aws-modules/ecs/aws//modules/service"
  version                = "v5.7.0"
  name                   = local.name
  cluster_arn            = module.ecs_cluster.arn
  enable_execute_command = true
  cpu                    = local.containers_template.cpu
  memory                 = local.containers_template.memory
  container_definitions  = local.containers_template
  iam_role_statements = {
    secrets_access = {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      resources = [
        "${aws_secretsmanager_secret.db_connection_details.arn}",
        "${module.db.db_instance_master_user_secret_arn}"
      ]
    }
  }
  load_balancer = {
    service = {
      target_group_arn = module.ecs_alb.target_groups["${local.name}"].arn
      container_name   = local.containers_template.app_name
      container_port   = local.containers_template.app_port
    }
  }
  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.containers_template.app_port
      to_port                  = local.containers_template.app_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = local.tags
}