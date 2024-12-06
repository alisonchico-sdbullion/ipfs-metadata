module "ecs_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"

  name                       = local.name
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = true

  preserve_host_header       = true
  xff_header_processing_mode = "preserve"
  security_groups            = [module.ecs_service.security_group_id]

  access_logs = {
    bucket = module.log_bucket.s3_bucket_id
    prefix = "access-logs"
  }

  target_groups = [
    {
      name                 = "${local.name}"
      backend_protocol     = "HTTP"
      backend_port         = local.containers_template.app_port
      target_type          = "instance"
      deregistration_delay = 5
      health_check = {
        enabled  = true
        path     = "/metadata"
        port     = "traffic-port"
        protocol = "HTTP"
        matcher  = "200"
      }
    },
  ]
  listeners = {
    default-http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "${local.name}"
      }
    }
  }

}