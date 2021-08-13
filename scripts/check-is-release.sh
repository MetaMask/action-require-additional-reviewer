#!/usr/bin/env bash

set -x
set -e
set -o pipefail

HEAD_BRANCH_NAME=${1}

if [[ -z $HEAD_BRANCH_NAME ]]; then
  echo "Error: No head branch name specified."
  exit 1
fi

RELEASE_BRANCH_PREFIX=${2}

if [[ -z $RELEASE_BRANCH_PREFIX ]]; then
  echo 'Error: No release branch prefix specified.'
  exit 1
fi

PREFIX_MATCH=$(
  echo "$HEAD_BRANCH_NAME" | grep -o "^$RELEASE_BRANCH_PREFIX"
)

if [[ -n $PREFIX_MATCH ]]; then
  IS_RELEASE="true"
else
  IS_RELEASE="false"
fi

echo "::set-output name=is-release::$IS_RELEASE"
