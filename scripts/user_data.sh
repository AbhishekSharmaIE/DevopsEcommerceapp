#!/bin/bash

# Install CodeDeploy agent
sudo apt-get update
sudo apt-get install -y ruby-full
sudo apt-get install -y wget

cd /home/ubuntu
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Verify installation
sudo service codedeploy-agent status

# Install other required packages
sudo apt-get install -y python3 python3-pip python3-venv nginx

# Create application directory
sudo mkdir -p /var/www/html/ecommerce
sudo chown -R ubuntu:ubuntu /var/www/html/ecommerce 