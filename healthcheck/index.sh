#!/bin/bash

# exit when any command fails
set -e

# get where the script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bash $DIR/connected-to-warp.sh

# if BETA_FIX_HOST_CONNECTIVITY is set, run fix-host-connectivity.sh
if [ -n "$BETA_FIX_HOST_CONNECTIVITY" ]; then
    bash $DIR/fix-host-connectivity.sh
fi
