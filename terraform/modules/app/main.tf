module "network" {
  source  = "../network"
  project = var.project
  env     = var.env
  region  = var.region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  tags                 = var.tags
}

module "compute" {
  source  = "../compute"
  project = var.project
  env     = var.env
  region  = var.region

  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  frontend_instance_type = var.frontend_instance_type
  backend_instance_type  = var.backend_instance_type
  key_name               = var.key_name

  tags = var.tags
}

module "db" {
  source  = "../db"
  project = var.project
  env     = var.env

  private_subnet_ids    = module.network.private_subnet_ids
  db_security_group_ids = var.db_security_group_ids

  db_instance_class = var.db_instance_class
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version

  secret_arn           = var.secret_arn
  save_endpoint_to_ssm = true
  multi_az             = false
  skip_final_snapshot  = false

  tags = var.tags
}


