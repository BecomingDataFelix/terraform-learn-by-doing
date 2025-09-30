output "alb_dns_name" { value = module.compute.alb_dns_name }
output "rds_endpoint" { value = module.db.rds_endpoint }
output "rds_secret_arn" { value = module.db.secret_arn }
