#!/bin/bash

# Get the EC2 instance IP from environment variable
EC2_INSTANCE_IP=${EC2_INSTANCE_IP:-3.250.5.252}

# Create a temporary directory for the deployment
DEPLOY_DIR="/tmp/deploy-$(date +%s)"
mkdir -p $DEPLOY_DIR

# Copy the application files to the temporary directory
cp -r app.py requirements.txt static templates data $DEPLOY_DIR/

# Use direct SSH without key
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$EC2_INSTANCE_IP << 'EOF'
    # Stop the current application
    pkill -f gunicorn || true

    # Create a backup of the current deployment
    if [ -d "/home/ec2-user/app" ]; then
        mv /home/ec2-user/app /home/ec2-user/app_$(date +%s)
    fi

    # Create a new deployment directory
    mkdir -p /home/ec2-user/app
EOF

# Copy the application files directly to the EC2 instance
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $DEPLOY_DIR/* ec2-user@$EC2_INSTANCE_IP:/home/ec2-user/app/

# SSH into the instance to set up the environment and start the application
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$EC2_INSTANCE_IP << 'EOF'
    cd /home/ec2-user/app

    # Set up Python virtual environment
    python3 -m venv venv
    source venv/bin/activate

    # Install dependencies
    pip install -r requirements.txt
    pip install gunicorn

    # Start the application
    nohup gunicorn --bind 0.0.0.0:5000 --workers 3 app:app > gunicorn.log 2>&1 &
EOF

# Clean up
rm -rf $DEPLOY_DIR 