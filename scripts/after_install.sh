#!/bin/bash

cd /var/www/ecommerce

# Activate virtual environment and install dependencies
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn

# Set up Nginx configuration
sudo tee /etc/nginx/sites-available/ecommerce << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable the Nginx site
sudo ln -sf /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx 