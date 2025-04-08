#!/bin/bash
set -e

echo "Installing system dependencies..."
sudo yum update -y
sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget

echo "Installing Python 3.9..."
cd /tmp
wget https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz
tar xzf Python-3.9.18.tgz
cd Python-3.9.18
./configure --enable-optimizations
make -j $(nproc)
sudo make altinstall

# Set Python 3.9 as the default python3
sudo ln -sf /usr/local/bin/python3.9 /usr/bin/python3
sudo ln -sf /usr/local/bin/pip3.9 /usr/bin/pip3

echo "Creating application directory..."
sudo mkdir -p /var/www/ecommerce

# The files will be in the deployment root directory
cd /opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/

echo "Copying application files..."
# Exclude the venv directory when copying
rsync -av --exclude='venv' . /var/www/ecommerce/

echo "Creating virtual environment..."
cd /var/www/ecommerce
/usr/local/bin/python3.9 -m venv venv
source venv/bin/activate

echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "Installing Node.js and npm..."
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

echo "Installing frontend dependencies..."
cd frontend
npm install
cd ..

echo "Dependencies installation completed." 