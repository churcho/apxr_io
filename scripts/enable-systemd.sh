#!/usr/bin/env bash

# Enable systemd units on target

set -e

# Config vars
SERVICE_NAME="apxr-io"

echo "==> Enabling systemd unit $SERVICE_NAME"
sudo /bin/systemctl enable "${SERVICE_NAME}"