#!/bin/bash
set -e

echo "Deploy started"

cd /root/software_projects/prof_milena_prado

echo "Syncing code..."
git fetch origin
git reset --hard origin/main

echo "Loading environment..."
set -a
source .env
set +a

echo "Installing dependencies..."
/root/software_projects/prof_milena_prado/venv/bin/pip install -r requirements.txt

echo "Running migrations..."
/root/software_projects/prof_milena_prado/venv/bin/python manage.py migrate --noinput

echo "Collecting static..."
/root/software_projects/prof_milena_prado/venv/bin/python manage.py collectstatic --noinput

echo "Validating Django config..."
/root/software_projects/prof_milena_prado/venv/bin/python manage.py check --deploy

echo "Restarting service..."
systemctl restart prof-milena

echo "Deploy complete"