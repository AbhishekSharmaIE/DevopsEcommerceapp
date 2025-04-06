#!/bin/bash
set -e

echo "Stopping the application..."
pkill -f gunicorn || true
systemctl stop nginx || true

# Stop the Node.js application using PM2
pm2 stop ecommerce-app
pm2 delete ecommerce-app 