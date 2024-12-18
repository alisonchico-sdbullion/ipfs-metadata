resource "aws_secretsmanager_secret" "db_connection_details" {
  name        = "${local.name}-db-connection-detail"
  description = "Connection details for the RDS database ${local.name}"
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "db_connection_details" {
  secret_id = aws_secretsmanager_secret.db_connection_details.id
  secret_string = jsonencode({
    db_address = module.db.db_instance_address
    username   = module.db.db_instance_username
    db_name    = module.db.db_instance_name
    port       = module.db.db_instance_port
  })
}

data "aws_secretsmanager_secret_version" "db_instance_secret" {
  depends_on = [module.db]
  secret_id  = module.db.db_instance_master_user_secret_arn
}