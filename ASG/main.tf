provider "aws" {
  region = "us-east-1"
}

data "aws_elb_service_account" "main" {}

/*
FOR MOUNT_SCRIPT.sh dynamic => TODO: update it dynamic via "apply" command

data "template_file" "mount_script_template" {
  template = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<html><body><h1>Hello, World, ilu sg! $(hostname -f)</h1></body></html>" > /var/www/html/index.html
    echo -e "\nMounting complete!"
  EOF
}

resource "local_file" "mount_script_files" {
  filename   = "mount_script.sh"
  content    = data.template_file.mount_script_template.rendered
  depends_on = [data.template_file.mount_script_template]
}

*/