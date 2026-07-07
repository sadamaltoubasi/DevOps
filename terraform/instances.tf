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


  tags = {
    Name        = "app-server"
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