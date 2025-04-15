#!/bin/bash

# Stop any running application
echo "Stopping existing application..."
sudo systemctl stop gunicorn || true
pkill -f gunicorn || true

# Create application directory if it doesn't exist
echo "Creating application directory..."
sudo mkdir -p /var/www/html/ecommerce
sudo chown -R ubuntu:ubuntu /var/www/html/ecommerce

# Install required system packages
echo "Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv nginx

# Configure nginx
echo "Configuring nginx..."
sudo tee /etc/nginx/sites-available/ecommerce << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Create gunicorn service
echo "Creating gunicorn service..."
sudo tee /etc/systemd/system/gunicorn.service << EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/var/www/html/ecommerce
Environment="PATH=/var/www/html/ecommerce/venv/bin"
ExecStart=/var/www/html/ecommerce/venv/bin/gunicorn --access-logfile - --workers 3 --bind 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

# Ensure proper permissions
sudo chown -R ubuntu:ubuntu /var/www/html/ecommerce
sudo chmod -R 755 /var/www/html/ecommerce 