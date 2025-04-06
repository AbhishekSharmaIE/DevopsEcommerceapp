#!/bin/bash
set -e

echo "Installing system dependencies..."
apt-get update
apt-get install -y python3-pip python3-venv nginx

echo "Creating virtual environment..."
python3 -m venv /var/www/ecommerce/venv
source /var/www/ecommerce/venv/bin/activate

echo "Installing Python dependencies..."
pip install -r /var/www/ecommerce/requirements.txt
pip install gunicorn 