#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
DEPLOYMENT_DIR="$(dirname "$(dirname "$0")")"
DATABASE_DIR="$DEPLOYMENT_DIR./database"
ENV_FILE="$DEPLOYMENT_DIR./deployment/.env"
source env/bin/activate
# Step 1: Navigate to the database/ directory
echo "Navigating to the database directory..."
cd "$DATABASE_DIR"

# Step 2: Load environment variables from .env
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE..."
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Error: .env file not found in $DEPLOYMENT_DIR."
    exit 1
fi
ls

# Step 3: Install dbt
echo "Installing dbt..."
pip install --upgrade pip
pip install dbt-core dbt-postgres

# Step 4: Initialize a new dbt project named 'gold'
if [ ! -d "gold" ]; then
    echo "DBT Project Does Not Exist 'gold'..."
    end
else
    echo "DBT project 'gold' already exists. Skipping initialization."
fi

# # Step 5: Configure dbt using environment variables
# echo "Setting up dbt profiles.yml..."
# DBT_PROFILES_DIR="$DATABASE_DIR/.dbt"
# mkdir -p "$DBT_PROFILES_DIR"

# cat <<EOF > "$DBT_PROFILES_DIR/profiles.yml"
# default:
#   target: dev
#   outputs:
#     dev:
#       type: postgres
#       host: ${DBT_HOST}
#       user: ${DBT_USER}
#       password: ${DBT_PASSWORD}
#       port: ${DBT_PORT}
#       dbname: ${DBT_DATABASE}
#       schema: ${DBT_SCHEMA}
#       threads: 4
# EOF

# echo "DBT setup complete. The 'gold' project is ready in $DATABASE_DIR."
