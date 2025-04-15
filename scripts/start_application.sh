#!/bin/bash

# Set up the application directory
APP_DIR="/var/www/html/ecommerce"
cd $APP_DIR

# Create and activate virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment and install dependencies
echo "Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Reload systemd and start services
echo "Starting gunicorn service..."
sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl restart gunicorn

# Verify the service is running
sleep 5
if systemctl is-active --quiet gunicorn; then
    echo "Application started successfully"
    exit 0
else
    echo "Failed to start application"
    systemctl status gunicorn
    exit 1
fi 