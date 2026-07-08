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
    self            = true
  }

  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    self            = true
  }

  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    self            = true
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
