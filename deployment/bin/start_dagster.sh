#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
DEPLOYMENT_DIR="$(dirname "$(dirname "$0")")"
VENV_DIR="$DEPLOYMENT_DIR/env"
REQUIREMENTS_FILE="$DEPLOYMENT_DIR/requirements.txt"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check if Python is installed
if ! command_exists python3; then
    echo "Python3 is not installed. Installing Python..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y python3 python3-venv python3-pip
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command_exists brew; then
            echo "Homebrew is not installed. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install python
    else
        echo "Unsupported OS. Please install Python manually."
        exit 1
    fi
fi

# Step 2: Check if Python venv is installed
if ! python3 -m venv --help >/dev/null 2>&1; then
    echo "Python venv module is not installed. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y python3-venv
    else
        echo "Unable to install venv on this OS. Please install manually."
        exit 1
    fi
fi

# Step 3: Create the virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
else
    echo "Virtual environment already exists in $VENV_DIR."
fi

# Step 4: Activate the virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Step 5: Install requirements
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing dependencies from $REQUIREMENTS_FILE..."
    pip install --upgrade pip
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "Requirements file not found at $REQUIREMENTS_FILE. Skipping dependency installation."
fi

# Step 6: Success message
echo "Setup complete. Virtual environment is ready at $VENV_DIR."

# dagster-webserver &