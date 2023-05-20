// n_subnets should be equal to length(vpc.public_subnets)

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "vpc-tf-${local.stage}-poc-ad"
  cidr   = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "${local.stage}"
  }
}