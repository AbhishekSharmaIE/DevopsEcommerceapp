#!/bin/bash
set -e

# Activate virtual environment
source /home/ubuntu/app/venv/bin/activate

# Start Gunicorn
cd /home/ubuntu/app
gunicorn --bind 0.0.0.0:5000 --workers 3 app:app --daemon --log-file /home/ubuntu/app/gunicorn.log 