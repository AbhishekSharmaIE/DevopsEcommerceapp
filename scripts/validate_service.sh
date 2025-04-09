#!/bin/bash
set -e

# Check if nginx is running
if ! systemctl is-active --quiet nginx; then
    echo "Nginx is not running"
    exit 1
fi

# Check if gunicorn is running
if ! systemctl is-active --quiet gunicorn; then
    echo "Gunicorn is not running"
    exit 1
fi

# Check if the application is responding
if ! curl -s http://localhost:5000/ > /dev/null; then
    echo "Application is not responding"
    exit 1
fi

echo "All services are running correctly"
exit 0 