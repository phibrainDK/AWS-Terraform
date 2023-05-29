/*
ebs_device_names:

/dev/sd[f-p]
/dev/sd[f-p][1-6]
/dev/xvd[f-p]
/dev/xvd[f-p][1-6]
/dev/nvme[0-26]n1

*/
locals {
  prefix           = "ECS-tf-${terraform.workspace}"
  stage            = terraform.workspace
  ebs_device_name1 = "/dev/xvdf"
  ebs_device_name2 = "/dev/xvdg"
  n_instance       = 1
  connections = [
    for i in range(0, local.n_instance) : {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "ECS-tf-testing-tf-key-pair-${i}.pem"
    }
  ]
  vpc_cidr = "10.0.0.0/16"
  # Tomo los 4 primeros
  azs      = slice(data.aws_availability_zones.available.names, 0, 4)
  cooldown = 20
  tags = {
    Example    = local.prefix
    GithubRepo = "terraform-aws-ECS"
    GithubOrg  = "terraform-aws-modules"
  }
}