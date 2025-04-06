#!/bin/bash

# Install system dependencies
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv nginx

# Create application directory if it doesn't exist
sudo mkdir -p /var/www/ecommerce

# Clean up old deployment if exists
sudo rm -rf /var/www/ecommerce/*

# Create virtual environment
cd /var/www/ecommerce
python3 -m venv venv 