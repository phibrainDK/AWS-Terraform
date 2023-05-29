/*
TODO
1. Test VPC - endpoints
2. Add API-GATEWAY INTEGRATION for endpoints or via LB
3. ENABLE INTERNET GATEWAY ONLY EGRESS
4. ENABLE ACM CERTIFICATION FOR ELB
5. MAKE STRONGER NACL AND SG RULES FOR PRIVATE SUBNETS AND INSTANCES
*/

provider "aws" {
  region = "us-east-1"
}

data "aws_elb_service_account" "main" {}
data "aws_availability_zones" "available" {}

resource "aws_key_pair" "tf-key-pair" {
  count      = local.n_instance
  key_name   = "${local.prefix}-key-pair-${count.index}"
  public_key = tls_private_key.rsa[count.index].public_key_openssh
}

resource "tls_private_key" "rsa" {
  count     = local.n_instance
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  count    = local.n_instance
  content  = tls_private_key.rsa[count.index].private_key_pem
  filename = "${local.prefix}-key-pair-${count.index}.pem"
}

resource "null_resource" "wait_for_ssh" {
  count = local.n_instance
  depends_on = [
    aws_instance.aws_ec2
  ]
  connection {
    type        = local.connections[count.index].type
    user        = local.connections[count.index].user
    private_key = file(local.connections[count.index].private_key)
    host        = aws_instance.aws_ec2[count.index].public_ip
    timeout     = "1m"
  }
}