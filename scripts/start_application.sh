#!/bin/bash
cd /home/ubuntu/ecommerce
source venv/bin/activate
cd app
nohup python app.py > /dev/null 2>&1 & 