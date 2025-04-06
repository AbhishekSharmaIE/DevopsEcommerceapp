#!/bin/bash
set -e

echo "Starting the application..."
cd /var/www/ecommerce
source venv/bin/activate

# Start Gunicorn
gunicorn --bind 0.0.0.0:8000 app:app --daemon

# Configure Nginx
cat > /etc/nginx/sites-available/ecommerce << EOF
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

ln -sf /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx 