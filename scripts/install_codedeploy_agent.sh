#!/bin/bash

# Install CodeDeploy agent
echo "Installing CodeDeploy agent..."
sudo apt-get update
sudo apt-get install -y ruby-full
sudo apt-get install -y wget

cd /home/ubuntu
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Verify installation
sudo service codedeploy-agent status 