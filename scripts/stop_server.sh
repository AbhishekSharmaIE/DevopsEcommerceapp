#!/bin/bash
set -e

echo "Stopping the application..."
pkill -f gunicorn || true
systemctl stop nginx || true 