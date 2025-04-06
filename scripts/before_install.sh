#!/bin/bash

# Detect OS and install appropriate packages
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    OS=$(uname -s)
fi

if [[ "$OS" == *"Ubuntu"* ]]; then
    # Ubuntu specific commands
    sudo apt-get update
    sudo apt-get install -y python3-pip python3-venv nginx
    DEPLOY_USER="ubuntu"
elif [[ "$OS" == *"Amazon Linux"* ]]; then
    # Amazon Linux specific commands
    sudo yum update -y
    sudo yum install -y python38 python38-pip python38-devel nginx
    DEPLOY_USER="ec2-user"
else
    echo "Unsupported operating system"
    exit 1
fi

# Create application directory if it doesn't exist
sudo mkdir -p /var/www/ecommerce

# Clean up old deployment if exists
sudo rm -rf /var/www/ecommerce/*

# Create virtual environment
cd /var/www/ecommerce
if [[ "$OS" == *"Ubuntu"* ]]; then
    python3 -m venv venv
else
    python3.8 -m venv venv
fi

# Export DEPLOY_USER for use in appspec.yml
echo "export DEPLOY_USER=$DEPLOY_USER" >> /etc/environment 