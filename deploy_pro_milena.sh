#!/bin/bash

set -e

echo "Entering project..."
cd /root/software_projects/prof_milena_prado

echo "Pulling latest code..."
git fetch origin
git reset --hard origin/main

echo "Activating virtualenv..."
source venv/bin/activate

echo "Installing dependencies..."
pip install -r requirements.txt

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Restarting systemd service..."
systemctl restart prof-milena

echo "Deployment finished."