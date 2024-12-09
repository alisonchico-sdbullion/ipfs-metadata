


module "ecs_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"

  name                       = local.name
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = true
  security_groups            = [module.ecs_service.security_group_id]

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

resource "aws_lb_target_group" "ecs_target_group" {
  name                 = local.name
  port                 = var.app_port
  protocol             = "HTTP"
  target_type          = "ip" # Registering tasks by their IP address
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 5

  health_check {
    enabled             = true
    path                = "/metadata"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30 # Optional, change as per requirements
    timeout             = 5  # Optional, change as per requirements
    healthy_threshold   = 2  # Optional, change as per requirements
    unhealthy_threshold = 2  # Optional, change as per requirements
  }

  tags = local.tags
}

resource "aws_lb_listener" "ecs_http_listener" {
  load_balancer_arn = module.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}

