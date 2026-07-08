data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# ======================================= Create IAM ROLE FOR APP-SERVER =============================================================



# 1. إنشاء الـ IAM Role الخاصة بالسيرفر
resource "aws_iam_role" "ecr_readonly_role" {
  name = "app-server-ecr-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. ربط السياسة الجاهزة (AmazonEC2ContainerRegistryReadOnly) بالـ Role
resource "aws_iam_role_policy_attachment" "ecr_policy_attach" {
  role       = aws_iam_role.ecr_readonly_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 3. إنشاء الـ Instance Profile (الوعاء الذي يمرر الـ Role إلى الـ EC2)
resource "aws_iam_instance_profile" "app_server_profile" {
  name = "app-server-ecr-profile"
  role = aws_iam_role.ecr_readonly_role.name
}


#======================================= Create EC2 Instances =============================================================

resource "aws_instance" "memcached_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = aws_key_pair.vprotest.key_name

  tags = {
    Name        = "memcached-server"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_instance" "rabbitmq_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = aws_key_pair.vprotest.key_name

  tags = {
    Name        = "rabbitmq-server"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = module.vpc.private_subnets[1]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = aws_key_pair.vprotest.key_name
  iam_instance_profile   = aws_iam_instance_profile.app_server_profile.name


  tags = {
    Name        = "app-server"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_instance" "prod_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = module.vpc.private_subnets[1]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = aws_key_pair.vprotest.key_name
  iam_instance_profile   = aws_iam_instance_profile.app_server_profile.name


  tags = {
    Name        = "prod-server"
    Environment = "dev"
    Terraform   = "true"
  }
}


resource "aws_instance" "bastion-host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.vprotest.key_name
  associate_public_ip_address = true


  tags = {
    Name        = "bastion-host"
    Environment = "dev"
    Terraform   = "true"
  }
}

