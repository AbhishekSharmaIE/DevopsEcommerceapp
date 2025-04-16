#!/bin/bash
set -e

# Update package list
sudo apt-get update

# Install Python and pip
sudo apt-get install -y python3 python3-pip python3-venv

# Create and activate virtual environment
python3 -m venv /home/ubuntu/app/venv
source /home/ubuntu/app/venv/bin/activate

# Install Python dependencies
pip install -r /home/ubuntu/app/requirements.txt

# Install system dependencies
sudo apt-get install -y nginx

# Configure nginx
sudo cp /home/ubuntu/app/nginx.conf /etc/nginx/sites-available/ecommerce
sudo ln -sf /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx 