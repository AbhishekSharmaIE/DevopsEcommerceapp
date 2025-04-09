#!/bin/bash
cd /home/ubuntu/ecommerce

# Kill any existing Python processes
pkill -f "python app.py" || true

# Activate virtual environment
source venv/bin/activate

# Start the application
nohup python app.py > app.log 2>&1 &

# Save the PID
echo $! > app.pid 