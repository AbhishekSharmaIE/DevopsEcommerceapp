#!/bin/bash
set -e

# Start nginx
systemctl start nginx

# Enable and start gunicorn
systemctl enable gunicorn
systemctl start gunicorn

# Kill any existing Python processes
pkill -f "python app.py" || true

# Activate virtual environment and start the application
cd /var/www/html/ecommerce
source venv/bin/activate
nohup gunicorn --workers 3 --bind 0.0.0.0:5000 app:app > app.log 2>&1 &

# Save the PID
echo $! > app.pid 