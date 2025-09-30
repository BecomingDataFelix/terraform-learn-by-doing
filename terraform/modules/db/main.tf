locals {
  name_prefix = "${var.project}-${var.env}"
  common_tags = merge({ Project = var.project, Env = var.env }, var.tags)
}

# DB subnet group
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-dbsubnet"
  subnet_ids = var.private_subnet_ids
  tags       = local.common_tags
}

# If an existing secret ARN is passed, read it; else create one with random password
data "aws_secretsmanager_secret" "existing" {
  count = var.secret_arn != "" ? 1 : 0
  arn   = var.secret_arn
}

data "aws_secretsmanager_secret_version" "existing_version" {
  count     = var.secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.existing[0].arn
}

resource "random_password" "rds_password" {
  count            = var.secret_arn == "" ? 1 : 0
  length           = 20
  override_special = "!@#$%*()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  special          = true
}

resource "aws_secretsmanager_secret" "this" {
  count = var.secret_arn == "" ? 1 : 0
  name  = "${local.name_prefix}-db-secret"
  tags  = local.common_tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count     = var.secret_arn == "" ? 1 : 0
  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    username = "${local.name_prefix}-appadmin"
    password = random_password.rds_password[0].result
  })
}

# resolved credentials
locals {
  secret_json = var.secret_arn != "" ? jsondecode(data.aws_secretsmanager_secret_version.existing_version[0].secret_string) : jsondecode(aws_secretsmanager_secret_version.this[0].secret_string)
  db_username = lookup(local.secret_json, "username", "${local.name_prefix}-appadmin")
  db_password = lookup(local.secret_json, "password", "")
}

# create RDS instance (single AZ by default; multi_az optional)
resource "aws_db_instance" "this" {
  identifier              = "${local.name_prefix}-rds"
  allocated_storage       = var.db_allocated_storage
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = local.db_username
  password                = local.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.db_security_group_ids != null ? var.db_security_group_ids : []
  multi_az                = var.multi_az
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = var.multi_az ? 7 : 1
  tags                    = local.common_tags
}

# Optionally write endpoint to SSM Parameter Store for easy discovery by other apps
resource "aws_ssm_parameter" "db_endpoint" {
  count = var.save_endpoint_to_ssm ? 1 : 0
  name  = "/${var.project}/${var.env}/rds/endpoint"
  type  = "String"
  value = aws_db_instance.this.address
  tags  = local.common_tags
}

output "rds_endpoint" { value = aws_db_instance.this.address }
output "rds_port" { value = aws_db_instance.this.port }
output "db_username" { value = local.db_username }
output "secret_arn" {
  value = var.secret_arn != "" ? var.secret_arn : aws_secretsmanager_secret.this[0].arn
}
