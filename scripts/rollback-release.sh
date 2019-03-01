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

_build/prod/rel/apxr_io/bin/apxr_io rollback_release
sudo /bin/systemctl restart apxr-io