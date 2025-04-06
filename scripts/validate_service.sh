#!/bin/bash

# Check if Nginx is running
if ! systemctl is-active --quiet nginx; then
    echo "Nginx is not running"
    exit 1
fi

# Check if application service is running
if ! systemctl is-active --quiet ecommerce; then
    echo "Ecommerce application is not running"
    exit 1
fi

# Check if application is responding
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ $response -ne 200 ]; then
    echo "Application is not responding properly (HTTP $response)"
    exit 1
fi

echo "Application deployment validated successfully"
exit 0 