#!/bin/bash

# Get the EC2 instance IP from environment variable
EC2_INSTANCE_IP=${EC2_INSTANCE_IP:-3.250.5.252}

# Create a temporary directory for the deployment
DEPLOY_DIR="/tmp/deploy-$(date +%s)"
mkdir -p $DEPLOY_DIR

# Copy the application files to the temporary directory
cp -r app requirements.txt static templates data $DEPLOY_DIR/

# Use SSH with key file
ssh -i ecommerce-key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$EC2_INSTANCE_IP << 'EOF'
    # Stop the current application
    pkill -f gunicorn || true

    # Create a backup of the current deployment
    if [ -d "/home/ubuntu/app" ]; then
        mv /home/ubuntu/app /home/ubuntu/app_$(date +%s)
    fi

    # Create a new deployment directory
    mkdir -p /home/ubuntu/app
EOF

# Copy the application files directly to the EC2 instance
scp -i ecommerce-key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $DEPLOY_DIR/* ubuntu@$EC2_INSTANCE_IP:/home/ubuntu/app/

# SSH into the instance to set up the environment and start the application
ssh -i ecommerce-key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$EC2_INSTANCE_IP << 'EOF'
    cd /home/ubuntu/app

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