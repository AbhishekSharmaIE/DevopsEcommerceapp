#!/bin/bash

# Get the EC2 instance IP from environment variable
EC2_INSTANCE_HOST=${EC2_INSTANCE_HOST:-ec2-108-129-203-192.eu-west-1.compute.amazonaws.com}

# Create a temporary directory for the deployment
DEPLOY_DIR="/tmp/deploy-$(date +%s)"
mkdir -p $DEPLOY_DIR

# Copy the application files to the temporary directory
cp -r ../app/* $DEPLOY_DIR/
cp ../requirements.txt $DEPLOY_DIR/
cp -r ../static ../templates ../data $DEPLOY_DIR/
cp ../Procfile $DEPLOY_DIR/

# Use SSH with key file
ssh -i ../ecommerce-app-key-eu.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$EC2_INSTANCE_HOST << 'EOF'
    # Stop the current application
    pkill -f gunicorn || true

    # Create a backup of the current deployment
    if [ -d "/home/ubuntu/app" ]; then
        mv /home/ubuntu/app /home/ubuntu/app_$(date +%s)
    fi

    # Create a new deployment directory
    mkdir -p /home/ubuntu/app

    # Install required packages
    sudo apt-get update
    sudo apt-get install -y python3-venv python3-pip
EOF

# Copy the application files directly to the EC2 instance
scp -i ../ecommerce-app-key-eu.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $DEPLOY_DIR/* ubuntu@$EC2_INSTANCE_HOST:/home/ubuntu/app/

# SSH into the instance to set up the environment and start the application
ssh -i ../ecommerce-app-key-eu.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$EC2_INSTANCE_HOST << 'EOF'
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