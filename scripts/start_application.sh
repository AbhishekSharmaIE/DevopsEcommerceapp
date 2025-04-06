#!/bin/bash

cd /var/www/ecommerce

# Create systemd service file
sudo tee /etc/systemd/system/ecommerce.service << EOF
[Unit]
Description=Gunicorn instance to serve ecommerce application
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/var/www/ecommerce
Environment="PATH=/var/www/ecommerce/venv/bin"
ExecStart=/var/www/ecommerce/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 app:app

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
sudo systemctl daemon-reload

# Start and enable the service
sudo systemctl start ecommerce
sudo systemctl enable ecommerce 