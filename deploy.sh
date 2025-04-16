#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting deployment process...${NC}"

# Step 1: Run pylint checks
echo -e "${YELLOW}Running pylint checks...${NC}"
pylint app/ --output-format=text > pylint_report.txt
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Pylint found some issues. Check pylint_report.txt for details.${NC}"
else
    echo -e "${GREEN}Pylint checks completed!${NC}"
fi

# Step 2: Create deployment package
echo -e "${YELLOW}Creating deployment package...${NC}"
mkdir -p deploy/app
cp -r app/* deploy/app/
cp requirements.txt deploy/
cp Procfile deploy/
cp nginx.conf deploy/
cp gunicorn.service deploy/
cp gunicorn.socket deploy/
cp -r scripts deploy/
chmod +x deploy/scripts/*.sh

# Step 3: Deploy to EC2
echo -e "${YELLOW}Deploying to EC2...${NC}"
EC2_HOST="ec2-52-214-107-96.eu-west-1.compute.amazonaws.com"
EC2_USER="ubuntu"
EC2_KEY="/home/abhishek/Desktop/Ecommerce/ecommerce-app-key-eu.pem"

# Copy files to EC2
echo -e "${YELLOW}Copying files to EC2...${NC}"
scp -i "$EC2_KEY" -r deploy/* $EC2_USER@$EC2_HOST:/home/$EC2_USER/app/

# SSH into EC2 and run deployment commands
echo -e "${YELLOW}Setting up services on EC2...${NC}"
ssh -i "$EC2_KEY" $EC2_USER@$EC2_HOST << 'EOF'
    cd /home/ubuntu/app
    
    # Stop existing services
    sudo systemctl stop gunicorn
    sudo systemctl stop nginx
    
    # Update systemd service files
    sudo cp gunicorn.service /etc/systemd/system/
    sudo cp gunicorn.socket /etc/systemd/system/
    
    # Update nginx configuration
    sudo cp nginx.conf /etc/nginx/sites-available/ecommerce
    sudo ln -sf /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/
    
    # Create/update virtual environment
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install -r requirements.txt
    
    # Set permissions
    sudo chown -R www-data:www-data /home/ubuntu/app
    sudo chmod -R 755 /home/ubuntu/app
    
    # Restart services
    sudo systemctl daemon-reload
    sudo systemctl restart gunicorn
    sudo systemctl restart nginx
    
    # Check service status
    echo "Gunicorn status:"
    sudo systemctl status gunicorn
    echo "Nginx status:"
    sudo systemctl status nginx
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment completed successfully!${NC}"
else
    echo -e "${RED}Deployment failed.${NC}"
    exit 1
fi

# Cleanup
rm -rf deploy
echo -e "${GREEN}Cleanup completed.${NC}" 