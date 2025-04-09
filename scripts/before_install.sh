#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get install -y python3-pip python3-venv nginx

# Create application directory if it doesn't exist
mkdir -p /var/www/html/ecommerce

# Stop services if they're running
systemctl stop nginx || true
systemctl stop gunicorn || true

# Clean up old deployment
rm -rf /var/www/html/ecommerce/* 