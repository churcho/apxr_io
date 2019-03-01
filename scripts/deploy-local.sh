export MIX_ENV=prod

# Exit on errors
set -e
# set -o errexit -o xtrace

CURDIR="$PWD"
BINDIR=$(dirname "$0")
cd "$BINDIR"; BINDIR="$PWD"; cd "$CURDIR"

BASEDIR="$BINDIR/.."
cd "$BASEDIR"

source "$HOME/.asdf/asdf.sh"

echo "Deploying local"

_build/prod/rel/apxr_io/bin/apxr_io deploy_release

echo "Starting apxr-io"

sudo /bin/systemctl restart apxr-io