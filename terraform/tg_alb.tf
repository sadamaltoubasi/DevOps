# ============================================  Target Group and ALB For STAGE SERVER ============================================
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




# ============================================  Target Group and ALB For PROD SERVER ============================================
# Target Group
resource "aws_lb_target_group" "prod_app_tg" {
  name     = "prod-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "8080"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_target_group_attachment" "attach_instance_prod" {
  target_group_arn = aws_lb_target_group.prod_app_tg.arn
  target_id        = aws_instance.prod_server.id
  port             = 8080
}


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

resource "aws_lb_listener" "http_listener_prod" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_app_tg.arn
  }
}

