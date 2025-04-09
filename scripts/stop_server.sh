#!/bin/bash
set -e

# Stop Gunicorn
pkill -f gunicorn || true 