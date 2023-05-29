// n_subnets should be equal to length(vpc.public_subnets)

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "vpc-tf-${local.stage}-poc-ad"
  cidr   = local.vpc_cidr
  azs    = local.azs
  # private_subnets                  = local.private_subnets
  # public_subnets                   = local.public_subnets
  private_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  private_subnet_names = [for k, v in local.azs : format("Private Subnet (${local.stage})#%d", k + 1)]

  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  # Testing for now
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = true
  # public_subnet_ipv6_native                      = true
  # public_subnet_ipv6_prefixes                    = [for k, v in local.azs : format("%d", k + 1)]
  # private_subnet_ipv6_prefixes                   = [for k, v in local.azs : format("%d", k + 1 + length(local.azs))]
  # private_subnet_ipv6_native                      = true
  # private_subnet_enable_dns64                    = false
  # private_subnet_assign_ipv6_address_on_creation = true

  # Careful about metrics
  # enable_network_address_usage_metrics = true
  # enable_ipv6 = true
  # ipv6_cidr                  = "2001:db8:123::/56"
  # private_subnet_ipv6_native = false
  # ipv6_ipam_pool_id          = ""
  create_egress_only_igw = true
  # VPC Flow Logs
  enable_flow_log                   = true
  flow_log_cloudwatch_iam_role_arn  = aws_iam_role.vpc_flowlogs_role.arn
  flow_log_destination_arn          = aws_cloudwatch_log_group.vpc_flowlogs_cloudwatch.arn
  flow_log_max_aggregation_interval = 60

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
      protocol    = "-1"
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
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
    # TESTING EGRESS ONLY
    # {
    #   rule_number     = 100
    #   rule_action     = "allow"
    #   from_port       = 0
    #   to_port         = 0
    #   protocol        = "58"
    #   ipv6_cidr_block = "::/0"
    # },

    # TODO: Update it
    # ALL (for now)
    {
      rule_number = 200
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]


  tags = {
    Terraform   = "true"
    Environment = "${local.stage}"
  }
  depends_on = [aws_cloudwatch_log_group.vpc_flowlogs_cloudwatch, aws_iam_role.vpc_flowlogs_role]
}


