#!/bin/bash
yum update -y
amazon-linux-extras install -y nginx1.12
echo "Install Nginx"
systemctl start nginx
systemctl enable nginx
echo "Nginx Server Starting"