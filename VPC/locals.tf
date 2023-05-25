/*
ebs_device_names:

/dev/sd[f-p]
/dev/sd[f-p][1-6]
/dev/xvd[f-p]
/dev/xvd[f-p][1-6]
/dev/nvme[0-26]n1

*/
locals {
  prefix           = "VPC-tf-${terraform.workspace}"
  stage            = terraform.workspace
  ebs_device_name1 = "/dev/xvdf"
  ebs_device_name2 = "/dev/xvdg"
  n_instance       = 1
  connections = [
    for i in range(0, local.n_instance) : {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "VPC-tf-testing-tf-key-pair-${i}.pem"
    }
  ]
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  cooldown        = 20
}