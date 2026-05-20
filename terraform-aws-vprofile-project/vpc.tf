module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpro-vpc"
  cidr = var.VpcCIDR

  azs             = [var.Zone1, var.Zone2, var.Zone3]
  private_subnets = [var.PrivateSubnet1, var.PrivateSubnet2, var.PrivateSubnet3]
  public_subnets  = [var.PublicSubnet1, var.PublicSubnet2, var.PublicSubnet3]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

/*  outputs = {
    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids
    private_subnet_ids = module.vpc.private_subnet_ids
  } */


/*
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
*/