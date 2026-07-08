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