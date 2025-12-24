################################################################################
# VPC
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.vpc}"
  cidr = "10.1.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b"]
  private_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets   = ["10.1.101.0/24","10.1.102.0/24"]

  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_vpn_gateway           = false
  one_nat_gateway_per_az       = false

}