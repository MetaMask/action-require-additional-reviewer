#!/usr/bin/env bash

set -x
set -e
set -o pipefail

# This PR checks whether the current PR meets the additional reviewer
# requirement for release PRs. Non-release PRs succeed by default.
# It uses the GitHub Status API to accomplish this. See the actual API call
# at the end of the file for more details.

GITHUB_REPOSITORY=${1}

if [[ -z $GITHUB_REPOSITORY ]]; then
  echo "Error: No GitHub repository identifier specified."
  exit 1
fi

HEAD_COMMIT_SHA=${2}

if [[ -z $GITHUB_REPOSITORY ]]; then
  echo "Error: No head commit SHA specified."
  exit 1
fi

GITHUB_STATUS_NAME=${3}

if [[ -z $GITHUB_STATUS_NAME ]]; then
  echo 'Error: No GitHub status name specified.'
  exit 1
fi

IS_RELEASE=${4}

if [[ -z $IS_RELEASE ]]; then
  echo 'Error: No "is release" input specified.'
  exit 1
fi

NUM_OTHER_APPROVING_REVIEWERS=${5}

if [[ $IS_RELEASE == "true" && -z $NUM_OTHER_APPROVING_REVIEWERS ]]; then
  echo "Error: No count of other approving reviewers specified."
  exit 1
fi

# Compute the status for the current commit and set it via the GitHub API.

COMMIT_STATUS_DESCRIPTION="Whether this PR meets the additional reviewer requirement for releases."

if [[ "$IS_RELEASE" == "false" ]]; then
  echo "The PR is not a release PR. Setting status to success by default."
  COMMIT_STATUS="success"
elif (( NUM_OTHER_APPROVING_REVIEWERS > 0 )); then
  echo "Success! Found approving reviews from organization members."
  COMMIT_STATUS="success"
else
  echo "Failure: Did not find approving reviews from other organization members."
  COMMIT_STATUS="pending"
fi

# https://cli.github.com/manual/gh_api
# https://docs.github.com/en/rest/reference/repos#create-a-commit-status

gh api "https://api.github.com/repos/${GITHUB_REPOSITORY}/statuses/${HEAD_COMMIT_SHA}" \
  -X "POST" \
  -H "Accept: application/vnd.github.v3+json" \
  -f context="$GITHUB_STATUS_NAME" \
  -f description="$COMMIT_STATUS_DESCRIPTION" \
  -f state="$COMMIT_STATUS"

# The action should never fail, only set a status for the release branch HEAD
# commit.
exit 0
