#!/bin/bash

# Define variables
URL="http://localhost:8080"
TITLE="Test Blog"
ADMIN_USER="dev"
ADMIN_EMAIL="test@email.io"
ADMIN_PASSWORD="123123"

# Start containers
docker compose up -d

# Run the Docker Compose command
docker compose run --rm wpcli core install \
    --url="$URL" \
    --title="$TITLE" \
    --admin_user="$ADMIN_USER" \
    --admin_email="$ADMIN_EMAIL" \
    --admin_password="$ADMIN_PASSWORD" \
    --skip-email

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Script completed successfully."
else
    echo "WordPress installation failed. Script stopping."
fi
