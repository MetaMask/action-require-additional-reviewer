#!/usr/bin/env bash

set -x
set -e
set -o pipefail

GITHUB_REPOSITORY=${1}

if [[ -z $GITHUB_REPOSITORY ]]; then
  echo "Error: No GitHub repository identifier specified."
  exit 1
fi

IS_RELEASE=${2}

if [[ -z $IS_RELEASE ]]; then
  echo 'Error: No "is release" input specified.'
  exit 1
fi

NUM_OTHER_APPROVING_REVIEWERS=${3}

if [[ $IS_RELEASE == "true" && -z $NUM_OTHER_APPROVING_REVIEWERS ]]; then
  echo "Error: No count of other approving reviewers specified."
  exit 1
fi

HEAD_COMMIT_SHA=$(git show-ref -s HEAD)

if [[ -z $HEAD_COMMIT_SHA ]]; then
  echo "Error: \"git show-ref -s HEAD\" returned an empty value."
  exit 1
fi

# Finally, compute the status for the current commit and set it via the GitHub API.

COMMIT_STATUS_DESCRIPTION="Whether this PR meets the additional reviewer requirement for releases."
COMMIT_STATUS="pending" # the default for releases

if [[ "$IS_RELEASE" == "false" ]]; then
  echo "The PR is not a release PR. Setting status to success by default."
  COMMIT_STATUS="success"
elif (( NUM_OTHER_APPROVING_REVIEWERS > 0 )); then
  echo "Success! Found approving reviews from organization members."
  COMMIT_STATUS="success"
else
  echo "Failure: Did not find approving reviews from other organization members."
fi

# https://cli.github.com/manual/gh_api
# https://docs.github.com/en/rest/reference/repos#create-a-commit-status

gh api "https://api.github.com/repos/${GITHUB_REPOSITORY}/statuses/${HEAD_COMMIT_SHA}" \
  -X "POST" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{
    "context": "MetaMask/action-require-additional-reviewer",
    "description": "'"$COMMIT_STATUS_DESCRIPTION"'",
    "state": "'"$COMMIT_STATUS"'",
    "target_url": "https://github.com/MetaMask/action-require-additional-reviewer"
  }'

# The action should never fail, only set a status for the release branch HEAD
# commit.
exit 0
