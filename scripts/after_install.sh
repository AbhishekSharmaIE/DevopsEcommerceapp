#!/bin/bash
cd /home/ubuntu/ecommerce

# Deactivate any existing virtual environment
deactivate 2>/dev/null || true

# Create and activate new virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install requirements
python -m pip install --upgrade pip
pip install -r requirements.txt

# Set correct permissions
chmod +x scripts/*.sh 