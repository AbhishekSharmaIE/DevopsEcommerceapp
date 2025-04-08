#!/bin/bash
# Update the system
dnf update -y

# Install Ruby and wget
dnf install -y ruby wget

# Install CodeDeploy agent
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Start CodeDeploy agent
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Install Node.js 18
dnf install -y nodejs

# Install Git
dnf install -y git

# Create application directory
mkdir -p /var/www/html/
chmod 755 /var/www/html/

# Install PM2 globally
npm install -g pm2

# Install and start SSM agent
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent 