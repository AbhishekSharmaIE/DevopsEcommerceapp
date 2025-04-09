#!/bin/bash
set -e

cd /var/www/html/ecommerce

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Set permissions
chown -R www-data:www-data /var/www/html/ecommerce
chmod -R 755 /var/www/html/ecommerce

# Configure nginx
cat > /etc/nginx/sites-available/ecommerce << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Configure gunicorn service
cat > /etc/systemd/system/gunicorn.service << 'EOF'
[Unit]
Description=Gunicorn instance to serve ecommerce application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/html/ecommerce
Environment="PATH=/var/www/html/ecommerce/venv/bin"
ExecStart=/var/www/html/ecommerce/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload 