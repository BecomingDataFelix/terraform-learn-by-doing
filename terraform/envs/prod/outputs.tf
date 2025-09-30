output "alb" { value = module.app.alb_dns_name }
output "rds" { value = module.app.rds_endpoint }
output "db_secret_arn" { value = module.app.rds_secret_arn }
