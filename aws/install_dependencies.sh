#!/bin/bash
yum update -y
yum -y install docker git
systemctl start docker
git config --global user.name "Admin"
git config --global user.email "admin@example.com"