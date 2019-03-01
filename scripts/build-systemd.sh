#!/usr/bin/env bash

export MIX_ENV=prod

# Exit on errors
set -e
# set -o errexit -o xtrace

# Config vars
SERVICE_NAME="apxr-io"
DESTDIR="/srv"

CURDIR="$PWD"
BINDIR=$(dirname "$0")
cd "$BINDIR"; BINDIR="$PWD"; cd "$CURDIR"

BASEDIR="$BINDIR/.."
cd "$BASEDIR"

source "$HOME/.asdf/asdf.sh"

echo "Generating systemd config"

mix systemd.generate