#!/bin/bash

# Set script dir
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Create virtual env
python3 -m venv $SCRIPT_DIR/myenv
source $SCRIPT_DIR/myenv/bin/activate

# Install packages
pip3 install -r $SCRIPT_DIR/requirements.txt
