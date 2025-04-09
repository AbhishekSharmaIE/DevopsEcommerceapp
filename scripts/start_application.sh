#!/bin/bash

# Stop any existing processes
echo "Stopping existing processes..."
sudo systemctl stop gunicorn || true
pkill -f gunicorn || true

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
pip install -r requirements.txt

# Start the application
echo "Starting application..."
nohup gunicorn --bind 0.0.0.0:5000 app:app > gunicorn.log 2>&1 &

# Save the process ID
echo $! > gunicorn.pid

# Verify the application is running
sleep 5
if pgrep -f gunicorn > /dev/null; then
    echo "Application started successfully"
    exit 0
else
    echo "Failed to start application"
    exit 1
fi 