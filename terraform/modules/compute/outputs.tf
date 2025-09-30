output "alb_dns_name" { value = aws_lb.alb.dns_name }
output "frontend_asg_name" { value = aws_autoscaling_group.frontend.name }
output "backend_asg_name" { value = aws_autoscaling_group.backend.name }
output "frontend_sg_id" { value = aws_security_group.frontend.id }
output "backend_sg_id" { value = aws_security_group.backend.id }
output "alb_sg_id" { value = aws_security_group.alb.id }
