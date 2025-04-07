#!/bin/bash

# Get the EC2 instance ID from environment variable or use the default one
EC2_INSTANCE_ID=${EC2_INSTANCE_ID:-"i-01203af55713a9f83"}

# Create a temporary directory for the deployment
DEPLOY_DIR="/tmp/deploy-$(date +%s)"
mkdir -p $DEPLOY_DIR

# Copy the application files to the temporary directory
cp -r app.py requirements.txt static templates data $DEPLOY_DIR/

# Create a deployment archive
cd $DEPLOY_DIR
zip -r ../deployment.zip .

# Copy the deployment archive to the EC2 instance using AWS Systems Manager
aws s3 cp ../deployment.zip s3://ecommerce-app-pipeline-artifacts/deployment.zip

# Use AWS Systems Manager to run commands on the EC2 instance
aws ssm send-command \
    --instance-ids "$EC2_INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands=[ \
        "cd /home/ec2-user", \
        "aws s3 cp s3://ecommerce-app-pipeline-artifacts/deployment.zip .", \
        "pkill -f gunicorn || true", \
        "[ -d \"app\" ] && mv app app_$(date +%s)", \
        "mkdir -p app", \
        "cd app", \
        "unzip -o ../deployment.zip", \
        "python3 -m venv venv", \
        "source venv/bin/activate", \
        "pip install -r requirements.txt", \
        "pip install gunicorn", \
        "nohup gunicorn --bind 127.0.0.1:5000 --workers 3 application:application > gunicorn.log 2>&1 &", \
        "rm ../deployment.zip" \
    ] \
    --region eu-west-1

# Clean up
rm -rf $DEPLOY_DIR
rm -f /tmp/deployment.zip 