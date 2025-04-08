#!/bin/bash
set -e

echo "Stopping existing server..."
sudo systemctl stop ecommerce-app || true

echo "Creating application directory..."
sudo mkdir -p /var/www/ecommerce

echo "Copying application files..."
# The files will be in the deployment root directory
cd /opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/

# Exclude the venv directory when copying
rsync -av --exclude='venv' . /var/www/ecommerce/

echo "Setting up Python environment..."
cd /var/www/ecommerce
python3.9 -m venv venv
source venv/bin/activate

echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "Setting up systemd service..."
sudo tee /etc/systemd/system/ecommerce-app.service << EOF
[Unit]
Description=Ecommerce Application
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/var/www/ecommerce
Environment="PATH=/var/www/ecommerce/venv/bin"
ExecStart=/var/www/ecommerce/venv/bin/gunicorn -w 4 -b 0.0.0.0:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Starting application..."
sudo systemctl daemon-reload
sudo systemctl enable ecommerce-app
sudo systemctl start ecommerce-app

echo "Deployment completed successfully!" 