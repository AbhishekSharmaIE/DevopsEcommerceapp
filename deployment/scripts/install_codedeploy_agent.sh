#!/bin/bash
set -e

echo "Installing CodeDeploy agent..."
yum update -y
yum install -y ruby
yum install -y wget
cd /home/ec2-user
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent status 