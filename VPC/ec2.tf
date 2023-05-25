resource "aws_security_group" "ec2_public_security_group" {
  # count       = 4
  vpc_id      = module.vpc.vpc_id
  name_prefix = "tlm-talmaclick-poc-sg"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    description = "SSH log into linux #instance"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    description = "Port enable for redirect from Load Balancer"
  }
  egress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    description = "Enable all possible ports responses #instance"
  }
  depends_on = [module.vpc]
}

# Crea una instancia EC2

################################################
# Dependen del tipo de instancia la AMI a usar # 
################################################
/*
t2.micro:
  Amazon Linux 2: ami-0c55b159cbfafe1f0
  Ubuntu 20.04: ami-0dba2cb6798deb6d8
  Windows Server 2019: ami-0ddc0d90d9318ca3f
t2.small:
  Amazon Linux 2: ami-0c55b159cbfafe1f0
  Ubuntu 20.04: ami-0dba2cb6798deb6d8
  Windows Server 2019: ami-0ddc0d90d9318ca3f
t2.medium:
  Amazon Linux 2: ami-0c55b159cbfafe1f0
  Ubuntu 20.04: ami-0dba2cb6798deb6d8
  Windows Server 2019: ami-0ddc0d90d9318ca3f
t2.large:
  Amazon Linux 2: ami-0c55b159cbfafe1f0
  Ubuntu 20.04: ami-0dba2cb6798deb6d8
  Windows Server 2019: ami-0ddc0d90d9318ca3f
m5.large:
  Amazon Linux 2: ami-0a887e401f7654935
  Ubuntu 20.04: ami-0dba2cb6798deb6d8
  Windows Server 2019: ami-0ddc0d90d9318ca3f
...
*/


resource "aws_instance" "aws_ec2" {
  count                = local.n_instance
  ami                  = "ami-0c94855ba95c71c99"
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.tf-key-pair[count.index].key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "${local.prefix}-tlm-talmaclick-${count.index}"
  }

  user_data                   = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<html><body><h1>Hello, World, ilu sg! $(hostname -f)</h1></body></html>" > /var/www/html/index.html
EOF 
  subnet_id                   = module.vpc.public_subnets[count.index % 4]
  vpc_security_group_ids      = [aws_security_group.ec2_public_security_group.id]
  associate_public_ip_address = true
  source_dest_check           = true
  // volume_type => gp2 | gp3 | io1 | io2 | sc1 | st1 

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  depends_on = [
    module.vpc,
    aws_security_group.ec2_public_security_group,
    tls_private_key.rsa,
    local_file.tf-key
  ]
}
