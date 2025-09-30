module "app" {
  source = "../../modules/app"

  project = var.project
  env     = var.env
  region  = var.region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway

  frontend_instance_type = var.frontend_instance_type
  backend_instance_type  = var.backend_instance_type

  db_instance_class = var.db_instance_class
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version

  # Do NOT pass db password here. Let module create secret in Secrets Manager.
  tags = {
    Owner = "dev-team"
  }
}

