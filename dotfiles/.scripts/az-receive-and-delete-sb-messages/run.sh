#!/bin/bash

# Set script dir
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Run install if myenv doesn't exist yet
if [ ! -d $SCRIPT_DIR/myenv ]; then
  $SCRIPT_DIR/install.sh
fi

# Run script
$SCRIPT_DIR/myenv/bin/python $SCRIPT_DIR/az-receive-and-delete-sb-messages.py 
