# 1. الـ Security Group الخاصة بالـ ALB (تسمح بالدخول من الإنترنت على بورت 80)
resource "aws_security_group" "alb_sg" {
  name        = "vpro-alb-sg"
  description = "Allow HTTP traffic from internet to ALB"
  vpc_id      = module.vpc.vpc_id # ربطها بالـ VPC الخاصة بك

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # السماح للجميع للوصول للـ ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpro-alb-sg"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "vpro-bastion-sg"
  description = "Allow SSH traffic from internet to Bastion Host"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpro-bastion-sg"
  }
}


# 2. الـ Security Group الخاصة بالـ Instances (تسمح بالدخول على بورت 8080 فقط من الـ ALB)
resource "aws_security_group" "backend_sg" {
  name        = "vpro-instance-sg"
  description = "Allow traffic only from ALB on port 8080"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpro-instance-sg"
  }
}

# ============================================  Target Group and ALB For stage server ============================================
# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "vpro-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/" # المسار الذي يفحص التطبيق
    protocol            = "HTTP"
    port                = "8080"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

# 4. ربط الـ Instance الأول بالـ Target Group
resource "aws_lb_target_group_attachment" "attach_instance_1" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id # الـ Instance الأول في subnet 1
  port             = 8080
}


# 6. إنشاء الـ Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "vpro-alb"
  internal           = false # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# 7. إنشاء الـ Listener (يستمع على بورت 80 ويوجه للـ Target Group)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 8. مخرجات (Outputs): لطباعة رابط الـ ALB بعد الانتهاء لتجربته مباشرة
output "alb_dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.app_alb.dns_name
}



# ============================================  Target Group and ALB For PROD SERVER ============================================
# Target Group
resource "aws_lb_target_group" "prod_app_tg" {
  name     = "prod-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/" # المسار الذي يفحص التطبيق
    protocol            = "HTTP"
    port                = "8080"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

# 4. ربط الـ Instance الأول بالـ Target Group
resource "aws_lb_target_group_attachment" "attach_instance_prod" {
  target_group_arn = aws_lb_target_group.prod_app_tg.arn
  target_id        = aws_instance.prod_server.id # الـ Instance الأول في subnet 1
  port             = 8080
}


# 6. إنشاء الـ Application Load Balancer (ALB)
resource "aws_lb" "prod_alb" {
  name               = "prod-alb"
  internal           = false # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# 7. إنشاء الـ Listener (يستمع على بورت 80 ويوجه للـ Target Group)
resource "aws_lb_listener" "http_listener_prod" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_app_tg.arn
  }
}

# 8. مخرجات (Outputs): لطباعة رابط الـ ALB بعد الانتهاء لتجربته مباشرة
output "alb_prod_dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.prod_alb.dns_name
}