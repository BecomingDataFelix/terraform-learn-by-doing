locals {
  name_prefix = "${var.project}-${var.env}"
  common_tags = merge({ Project = var.project, Env = var.env }, var.tags)
}

###################
# Security groups
###################
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-sg-alb"
  description = "ALB SG - allow HTTP/HTTPS from internet"
  vpc_id      = element(var.public_subnet_ids, 0)
  tags        = local.common_tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "frontend" {
  name        = "${local.name_prefix}-sg-frontend"
  vpc_id      = element(var.public_subnet_ids, 0)
  description = "Allow traffic from ALB"
  tags        = local.common_tags

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow only ALB to reach frontend"
  }

  # allow outbound to anywhere (including DB)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend" {
  name        = "${local.name_prefix}-sg-backend"
  vpc_id      = element(var.private_subnet_ids, 0)
  description = "Allow traffic from frontend instances"
  tags        = local.common_tags

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
    description     = "Allow only frontend to talk to backend"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################
# ALB + Target Group
###################
resource "aws_lb" "alb" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb.id]
  tags               = local.common_tags
}

resource "aws_lb_target_group" "frontend" {
  name     = "${local.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = element(var.public_subnet_ids, 0) # vpc id isn't accepted; but we use subnet's vpc implicitly
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

###################
# Launch template for frontend
###################
data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "frontend" {
  name_prefix   = "${local.name_prefix}-frontend-"
  image_id      = data.aws_ami.linux.id
  instance_type = var.frontend_instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.frontend.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "Hello from ${local.name_prefix} frontend" > /usr/share/nginx/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Role = "frontend" })
  }
}

###################
# Frontend ASG
###################
resource "aws_autoscaling_group" "frontend" {
  name                = "${local.name_prefix}-frontend-asg"
  min_size            = var.frontend_min_size
  max_size            = var.frontend_max_size
  desired_capacity    = var.frontend_desired_capacity
  vpc_zone_identifier = var.public_subnet_ids
  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.frontend.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  # Adding tags to ASG itself (not instances)
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

###################
# Backend launch template + ASG (private subnets)
###################
resource "aws_launch_template" "backend" {
  name_prefix   = "${local.name_prefix}-backend-"
  image_id      = data.aws_ami.linux.id
  instance_type = var.backend_instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.backend.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "Hello from ${local.name_prefix} backend" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Role = "backend" })
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "${local.name_prefix}-backend-asg"
  min_size            = var.backend_min_size
  max_size            = var.backend_max_size
  desired_capacity    = var.backend_desired_capacity
  vpc_zone_identifier = var.private_subnet_ids
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  health_check_type = "EC2"

  # Adding tags to ASG itself (not instances)
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

###################
# Instance profile for SSM (recommended instead of opening SSH)
###################
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${local.name_prefix}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}



