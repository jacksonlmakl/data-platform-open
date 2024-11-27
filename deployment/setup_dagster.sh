#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
source env/bin/activate
# Load environment variables from .env file
ENV_FILE="$(dirname "$0")/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found in deployment directory."
    exit 1
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)

# Variables
PROJECT_ROOT="$(dirname "$(dirname "$0")")"
ORCHESTRATION_DIR="$PROJECT_ROOT/orchestration"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
DEPLOYMENT_DIR="$(dirname "$0")" # Corrected to use the script's actual location
PYPROJECT_TOML="$DEPLOYMENT_DIR/pyproject.toml"
DEFINITIONS_FILE="$ORCHESTRATION_DIR/definitions.py"
JOB_FILE="$ORCHESTRATION_DIR/run_scripts_job.py"
SCHEDULE_FILE="$ORCHESTRATION_DIR/run_scripts_schedule.py"
REPOSITORY_FILE="$ORCHESTRATION_DIR/repositories.py"

# Step 1: Ensure project structure
echo "Ensuring project structure..."
mkdir -p "$ORCHESTRATION_DIR"
mkdir -p "$SCRIPTS_DIR"
touch "$ORCHESTRATION_DIR/__init__.py"
touch "$SCRIPTS_DIR/__init__.py"

# Step 2: Update pyproject.toml
echo "Updating pyproject.toml..."
cat <<EOF > "$PYPROJECT_TOML"
[project]
name = "python_scripts"
version = "0.1.0"
description = "Dagster project to run scripts."
requires-python = ">=3.9"
dependencies = [
    "dagster",
    "dagster-cloud",
]

[tool.dagster]
module_name = "orchestration.definitions"
project_name = "python_scripts"
working_directory = "$PROJECT_ROOT"
EOF

# Step 3: Create the Dagster job
echo "Creating Dagster job..."
cat <<EOF > "$JOB_FILE"
from dagster import job, op
import subprocess
import os

@op
def run_all_scripts():
    """
    Op to execute all Python scripts in the scripts directory.
    """
    scripts_dir = os.path.abspath("$SCRIPTS_DIR")
    for script in os.listdir(scripts_dir):
        if script.endswith(".py"):
            script_path = os.path.join(scripts_dir, script)
            print(f"Running script: {script_path}")
            result = subprocess.run(
                ["python3", script_path],
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                raise Exception(f"Script {script} failed: {result.stderr}")
            print(f"Output for {script}:\n{result.stdout}")

@job
def run_scripts_job():
    run_all_scripts()
EOF

# Step 4: Create the Dagster schedule
echo "Creating Dagster schedule..."
cat <<EOF > "$SCHEDULE_FILE"
from dagster import schedule
from orchestration.run_scripts_job import run_scripts_job

@schedule(cron_schedule="0 9 * * *", job=run_scripts_job, execution_timezone="UTC")
def daily_run_scripts_schedule():
    return {}
EOF

# Step 5: Create the Dagster repository
echo "Creating Dagster repository..."
cat <<EOF > "$DEFINITIONS_FILE"
from dagster import Definitions
from orchestration.run_scripts_job import run_scripts_job
from orchestration.run_scripts_schedule import daily_run_scripts_schedule

defs = Definitions(
    jobs=[run_scripts_job],
    schedules=[daily_run_scripts_schedule],
)
EOF

# Step 6: Install the project in editable mode
echo "Installing project..."
cd "$DEPLOYMENT_DIR"
pip install -e "$PROJECT_ROOT"

# Step 7: Start Dagster services
echo "Starting Dagster services..."
export DAGSTER_HOME="$PROJECT_ROOT/orchestration"
mkdir -p "$DAGSTER_HOME"
dagster-daemon run &
dagster-webserver --port 3000 --host 0.0.0.0 &
echo "Dagster setup complete. Webserver running at http://localhost:3000"
