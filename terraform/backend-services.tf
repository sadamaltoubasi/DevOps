resource "aws_db_subnet_group" "vpro-rds-subgrp" {
  name       = "vpro-rds-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Name = "vpro-rds-subgrp"
  }
}

resource "aws_db_instance" "vpro-rds" {
  allocated_storage      = 20
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0.42"
  instance_class         = "db.t4g.micro"
  db_name                = var.dbname
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = "default.mysql8.0"
  multi_az               = "false"
  publicly_accessible    = "false"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.vpro-rds-subgrp.name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
}

