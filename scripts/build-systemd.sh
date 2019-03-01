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

echo "Copying systemd unit files for $SERVICE_NAME"

cp _build/${MIX_ENV}/systemd/lib/systemd/system/* "${DESTDIR}/lib/systemd/system/"
chmod 644 ${DESTDIR}/lib/systemd/system/${SERVICE_NAME}*