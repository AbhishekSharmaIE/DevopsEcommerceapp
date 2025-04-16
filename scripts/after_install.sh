#!/bin/bash
set -e

# Set up virtual environment
echo "Setting up virtual environment..."
cd /var/www/html/ecommerce
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Set proper permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data /var/www/html/ecommerce
sudo chmod -R 755 /var/www/html/ecommerce

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p /var/www/html/ecommerce/logs
mkdir -p /var/www/html/ecommerce/app/data
touch /var/www/html/ecommerce/logs/gunicorn.log
touch /var/www/html/ecommerce/app/data/users.json
touch /var/www/html/ecommerce/app/data/products.json
chown -R www-data:www-data /var/www/html/ecommerce/logs
chown -R www-data:www-data /var/www/html/ecommerce/app/data

# Ensure all files have correct permissions
find /var/www/html/ecommerce -type d -exec chmod 755 {} \;
find /var/www/html/ecommerce -type f -exec chmod 644 {} \;
find /var/www/html/ecommerce -name "*.sh" -exec chmod +x {} \;

echo "Post-installation tasks completed successfully"

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
ExecStart=/var/www/html/ecommerce/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app.app:app

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload 