#!/usr/bin/env bash
# Exit on error
set -o errexit

# Install dependencies first!
pip install -r requirements.txt

# Create static and media directories
mkdir -p staticfiles
mkdir -p media

# Apply database migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --no-input

echo "✅ Build completed successfully!"
