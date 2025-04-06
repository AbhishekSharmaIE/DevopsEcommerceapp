#!/bin/bash

# Get the EC2 instance IP from environment variable
EC2_INSTANCE_IP=${EC2_INSTANCE_IP:-3.250.5.252}

# Create a temporary directory for the deployment
DEPLOY_DIR="/tmp/deploy-$(date +%s)"
mkdir -p $DEPLOY_DIR

# Copy the application files to the temporary directory
cp -r app.py requirements.txt static templates $DEPLOY_DIR/

# Create a deployment archive
cd $DEPLOY_DIR
zip -r ../deployment.zip .

# Copy the deployment archive to the EC2 instance
scp -i ecommerce-app-key.pem ../deployment.zip ec2-user@$EC2_INSTANCE_IP:/home/ec2-user/

# SSH into the instance and deploy the application
ssh -i ecommerce-app-key.pem ec2-user@$EC2_INSTANCE_IP << 'EOF'
    # Stop the current application
    pkill -f gunicorn

    # Create a backup of the current deployment
    if [ -d "/home/ec2-user/app" ]; then
        mv /home/ec2-user/app /home/ec2-user/app_$(date +%s)
    fi

    # Create a new deployment directory
    mkdir -p /home/ec2-user/app
    cd /home/ec2-user/app

    # Extract the deployment archive
    unzip -o /home/ec2-user/deployment.zip

    # Set up Python virtual environment
    python3 -m venv venv
    source venv/bin/activate

    # Install dependencies
    pip install -r requirements.txt

    # Start the application
    nohup gunicorn --bind 127.0.0.1:5000 --workers 3 app:app > gunicorn.log 2>&1 &

    # Clean up
    rm /home/ec2-user/deployment.zip
EOF

# Clean up
rm -rf $DEPLOY_DIR
rm -f /tmp/deployment.zip 