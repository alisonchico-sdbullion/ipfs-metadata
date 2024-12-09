
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${local.name}"
  retention_in_days = 30
  tags              = local.tags
}

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
  cpu                    = var.cpu
  memory                 = var.memory
  # Container definition(s)
  container_definitions = {
    (local.name) = {
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      image     = local.ecs_image
      port_mappings = [
        {
          name          = local.name
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      readonly_root_filesystem  = false
      enable_cloudwatch_logging = true
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
      # Inject secrets into the container
      environment = [
        {
          name  = "username"
          value = jsondecode(aws_secretsmanager_secret_version.db_connection_details.secret_string)["username"]
        },
        {
          name  = "db_name"
          value = jsondecode(aws_secretsmanager_secret_version.db_connection_details.secret_string)["db_name"]
        },
        {
          name  = "db_address"
          value = jsondecode(aws_secretsmanager_secret_version.db_connection_details.secret_string)["db_address"]
        },
        {
          name  = "port"
          value = jsondecode(aws_secretsmanager_secret_version.db_connection_details.secret_string)["port"]
        },
        {
          name  = "password"
          value = jsondecode(data.aws_secretsmanager_secret_version.db_instance_secret.secret_string)["password"]
        }
      ]
    }
  }
  task_exec_iam_statements = {
    secrets_access = {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      resources = [
        "${aws_secretsmanager_secret.db_connection_details.arn}",
        "${module.db.db_instance_master_user_secret_arn}"
      ]
    }
    cloudwatch_logs_access = {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = [
        "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${local.name}*"
      ]
    }
  }
  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.ecs_target_group.arn
      container_name   = local.name
      container_port   = var.app_port
    }
  }
  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = var.app_port
      to_port                  = var.app_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.ecs_alb.security_group_id
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