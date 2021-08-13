#!/usr/bin/env bash

set -x
set -e
set -o pipefail

# This script checks whether an organization member or owner other than the
# specified action initiator (i.e., GitHub username) has approved the pull
# request associated with the current git branch. It uses the the GitHub CLI,
# gh, to fetch information about the PR, and jq to parse the result, which is in
# JSON.
#
# This script takes the path to a directory as an argument, which should contain
# GitHub workflow artifacts in the form of text files, each named after a
# release PR number, e.g. 99.txt, and each containing the name of the user that
# created the release PR (via the @metamask/create-release-pr action).
#
# If parsing the result from GitHub fails, or if nobody other than the action
# initiator has approved the pull request, this script will exit with a non-zero
# code.

PR_NUMBER=${1}

if [[ -z $PR_NUMBER ]]; then
  echo "Error: No pull request number specified."
  exit 1
fi

ARTIFACTS_DIR_PATH=${2}

if [[ -z $ARTIFACTS_DIR_PATH ]]; then
  echo "Error: No artifacts directory specified."
  exit 1
fi

ARTIFACT_FILE_PATH="${ARTIFACTS_DIR_PATH}/${PR_NUMBER}.txt"

if [[ ! -f "${ARTIFACT_FILE_PATH}" ]]; then
  echo "Error: The expected artifact file at \"${ARTIFACT_FILE_PATH}\" does not exist."
  exit 1
fi

# Get the first word in the artifact text file, which should be the GitHub
# username of the action initiator.
ACTION_INITIATOR=$(grep -o -m 1 "\w\+" < "${ARTIFACT_FILE_PATH}")

if [[ -z "${ACTION_INITIATOR}" ]]; then
  echo 'Error: The workflow artifact file does not contain a username.'
  exit 1
fi

echo \
  "Identified author of release PR #${PR_NUMBER} as \"${ACTION_INITIATOR}\"." \
  "Looking for approving reviews from other organization members..."

# Get the JSON data from GitHub. For the expected format of this data, see the
# end of this file.
PR_INFO=$(gh pr view "$PR_NUMBER" --json reviews)

if [[ -z $PR_INFO ]]; then
  echo 'Error: "gh pr view" returned an empty value.'
  exit 1
fi

NUM_OTHER_APPROVING_REVIEWERS=$( 
  echo "${PR_INFO}" |
  jq '.reviews |
    map(select(
      (.state | test("^approved$"; "i")) and
      (.authorAssociation | test("^collaborator|member|owner$"; "i"))
    )) |
    map(.author.login) |
    map(select(. != "'"${ACTION_INITIATOR}"'")) |
    length'
)

echo ::set-output name=num-other-approving-reviewers::"$NUM_OTHER_APPROVING_REVIEWERS"

# Relevant GitHub documentation:
# https://docs.github.com/en/graphql/reference/enums#pullrequestreviewstate
# https://docs.github.com/en/graphql/reference/enums#commentauthorassociation

# Related, but not exactly the same as "gh pr view":
# https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads#pull_request
#
# https://cli.github.com/manual/gh_pr_view
#
# gh pr view --json number,reviews
#
# {
#   "number": 99,
#   "reviews": [
#     {
#       "author": {
#         "login": "username1"
#       },
#       "state": "COMMENTED",
#       "authorAssociation": "OWNER",
#       ...
#     },
#     {
#       "author": {
#         "login": "username2"
#       },
#       "state": "APPROVED",
#       "authorAssociation": "MEMBER",
#       ...
#     },
#     ...
#   ]
# }