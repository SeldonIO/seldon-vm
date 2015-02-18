#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 1 ]]; then
        echo "Need version"
        exit 1
fi

VERSION=$1



FPATH="s3://seldon-vm/${VERSION}/images/seldon-models/movielens_demo.tar.gz"
echo "--- fetching ${FPATH} ---"
aws s3 cp ${FPATH} .
tar -xvzf movielens_demo.tar.gz
