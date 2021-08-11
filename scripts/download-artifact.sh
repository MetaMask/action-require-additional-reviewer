#!/usr/bin/env bash

set -x
set -e
set -o pipefail

# This script downloads the artifact with the specified name to the specified
# directory, from the successful workflow run corresponding to the specified
# workflow name, pull request base branch, and GitHub repository identifier.

# The path to the directory where the artifact files will be downloaded.
ARTIFACTS_DIR_PATH=${1}

if [[ -z $ARTIFACTS_DIR_PATH ]]; then
  echo "Error: No artifacts directory specified."
  exit 1
fi

# The name of the artifact to download.
ARTIFACT_NAME=${2}

if [[ -z $ARTIFACT_NAME ]]; then
  echo "Error: No artifact name specified."
  exit 1
fi

# Inputs 3-5 are used to identify the workflow run to download artifacts from.

WORKFLOW_NAME=${3}

if [[ -z $WORKFLOW_NAME ]]; then
  echo "Error: No workflow name specified."
  exit 1
fi

PULL_REQUEST_BASE_BRANCH=${4}

if [[ -z $PULL_REQUEST_BASE_BRANCH ]]; then
  echo "Error: No pull request base branch specified."
  exit 1
fi

GITHUB_REPOSITORY=${5}

if [[ -z $GITHUB_REPOSITORY ]]; then
  echo "Error: No GitHub repository identifier specified."
  exit 1
fi

GIT_MERGE_BASE_SHA=$(git merge-base HEAD "$PULL_REQUEST_BASE_BRANCH")

if [[ -z $GIT_MERGE_BASE_SHA ]]; then
  echo "Error: \"git merge base\" did not return a value."
  exit 1
fi


# We need the ID of the workflow that created the current release PR, in order
# to download the artifacts of that workflow.
#
# See the end of the file for details on the response value from GitHub.
WORKFLOW_ID=$(
  gh api "/repos/${GITHUB_REPOSITORY}/actions/runs" |
  jq '.workflow_runs |
    map(select(
      .name == "'"${WORKFLOW_NAME}"'" and
      (.conclusion | test("^success$"; "i")) and
      .head_sha == "'"${GIT_MERGE_BASE_SHA}"'"
    ))[0].id
  '
)

if [[ -z $WORKFLOW_ID || "$WORKFLOW_ID" == null ]]; then
  echo "Error: Failed to extract workflow ID."
  exit 1
fi

# Finally, we can download the artifacts for the correct workflow run and write
# them to the specified artifacts directory.
mkdir -p "$ARTIFACTS_DIR_PATH" && cd "$ARTIFACTS_DIR_PATH"
gh run download "$WORKFLOW_ID" -n "$ARTIFACT_NAME"
echo "Artifact successfully downloaded!"

# gh api /repos/ORG_NAME/REPO_NAME/actions/runs
# 
# https://docs.github.com/en/rest/reference/actions#list-workflow-runs-for-a-repository
# https://docs.github.com/en/graphql/reference/objects#workflowrun
# https://docs.github.com/en/graphql/reference/objects#checkrun
# https://docs.github.com/en/graphql/reference/enums#checkconclusionstate
#
# [
#  {
#    "id": 1118040733,
#    "name": "Create Release Pull Request",
#    "node_id": "WFR_kwLOFShwTM5Co_Kd",
#    "head_branch": "main",
#    "head_sha": "a71c77620588491bd7becf547c5d7bb4e70dac8b",
#    "run_number": 9,
#    "event": "workflow_dispatch",
#    "status": "completed",
#    "conclusion": "success",
#    ...
#  },
#  ...
# ]
