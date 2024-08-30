#!/bin/bash
python3 -m venv myenv
source myenv/bin/activate

pip3 install azure-identity azure-servicebus
