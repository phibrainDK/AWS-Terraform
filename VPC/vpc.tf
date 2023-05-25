// n_subnets should be equal to length(vpc.public_subnets)

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "vpc-tf-${local.stage}-poc-ad"
  cidr   = "10.0.0.0/16"

  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Careful about metrics
  # enable_network_address_usage_metrics = true
  # enable_ipv6                          = true

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  manage_default_network_acl = true
  #################################
  # NACL rules for public subnets #
  #################################
  public_dedicated_network_acl = true
  public_inbound_acl_rules = [
    # SSH => cidr_block should be "trusted_ip_range"
    {
      rule_number = 100
      protocol    = "tcp"
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      cidr_block  = "0.0.0.0/0"
    },
    # HTTP
    {
      rule_number = 200
      protocol    = "tcp"
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      cidr_block  = "0.0.0.0/0"
    },
    # HTTPS
    {
      rule_number = 300
      protocol    = "tcp"
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      cidr_block  = "0.0.0.0/0"
    }
  ]
  public_outbound_acl_rules = [
    # ALL (for now)
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  ##################################
  # NACL rules for private subnets #
  ##################################

  private_dedicated_network_acl = true
  private_inbound_acl_rules = [
    # SSH => cidr_block should be "trusted_ip_range"
    {
      rule_number = 100
      protocol    = "tcp"
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      cidr_block  = "0.0.0.0/0"
    },
    # HTTPS
    {
      rule_number = 200
      protocol    = "tcp"
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      cidr_block  = "0.0.0.0/0"
    },
    # ALL (for now -> ####)
    {
      rule_number = 300
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
  private_outbound_acl_rules = [
    # TODO: Update it
    # ALL (for now)
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  # Testing for now
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "${local.stage}"
  }
}
