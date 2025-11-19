#!/usr/bin/env bash
set -o errexit

# Create directories
mkdir -p staticfiles
mkdir -p media

# Apply database migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --no-input

# Note: Removed superuser creation for security
# Create admin user manually through Django admin if needed
