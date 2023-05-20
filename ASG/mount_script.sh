#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<html><body><h1>Hello, World, ilu sg! $(hostname -f)</h1></body></html>" > /var/www/html/index.html
echo -e "\nMounting complete!"