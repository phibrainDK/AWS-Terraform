# Define la región de AWS a utilizar
provider "aws" {
  region = "us-east-1"
}

data "aws_elb_service_account" "main" {}

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

data "template_file" "mount_script_template" {
  count      = length(aws_efs_mount_target.mount_target)
  template   = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y amazon-efs-utils
    sudo mkdir -p /mnt/efs
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "${aws_efs_mount_target.mount_target[count.index].dns_name}":/ /mnt/efs
    df -h
    ls -la /mnt/efs
    echo -e "\nMounting complete!"
  EOF
  depends_on = [aws_efs_mount_target.mount_target]
}

resource "local_file" "mount_script_files" {
  count      = length(data.template_file.mount_script_template.*.rendered)
  filename   = "mount_script_${count.index}.sh"
  content    = data.template_file.mount_script_template[count.index].rendered
  depends_on = [data.template_file.mount_script_template]
}

resource "null_resource" "set-up-efs" {
  count = local.n_instance
  depends_on = [
    aws_instance.aws_ec2,
    aws_efs_mount_target.mount_target,
    local_file.mount_script_files
  ]
  connection {
    type        = local.connections[count.index].type
    user        = local.connections[count.index].user
    private_key = file(local.connections[count.index].private_key)
    host        = aws_instance.aws_ec2[count.index].public_ip
    timeout     = "3m"
  }
  provisioner "local-exec" {
    command = "sh mount_script_0.sh && sh mount_script_1.sh && sh mount_script_2.sh && sh mount_script_3.sh"
  }
}