module "ecs_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"

  name                       = local.name
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = true
  security_groups            = [module.ecs_service.security_group_id]

  target_groups = {
    golang-app = {
      name                 = "${local.name}"
      backend_protocol     = "HTTP"
      backend_port         = var.app_port
      target_type          = "ip"
      target_id            = ""
      deregistration_delay = 5
      health_check = {
        enabled  = true
        path     = "/metadata"
        port     = "traffic-port"
        protocol = "HTTP"
        matcher  = "200"
      }
    },
  }

  listeners = {
    default-http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "golang-app"
      }
    }
  }

}