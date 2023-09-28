# MetaMask/action-require-additional-reviewer

## Deprecated

This action is deprecated since it's no longer in use within the MetaMask
repositories. It's still available for use, but no longer maintained.

## Description

This action can be used to create workflows that require additional reviewers for programmatically created pull requests.
It is designed to be used with [`MetaMask/action-create-release-pr`](https://github.com/MetaMask/action-create-release-pr).

`action-create-release-pr` is manually triggered by a GitHub user, but the resulting PR is authored by the GitHub Actions bot. This means that the human release author can merge their own release without third-party review. By modifying the `action-create-release-pr` workflow and using this action in a separate workflow, a status check will be added to your PRs that you can use to ensure that at least one organization member other than the release author has approved a release PR before it can be merged.

## Usage

This action is designed to be used in public repositories alongside [`MetaMask/action-create-release-pr`](https://github.com/MetaMask/action-create-release-pr), and will not work unless your repository also uses that action as recommended by its documentation.

To use this action, you need to make a small addition to the `MetaMask/action-create-release-pr` workflow of your repository, and add a new workflow that uses this action:

- [`.github/workflows/create-release-pr.yml`](https://github.com/MetaMask/action-require-additional-reviewer/blob/main/.github/workflows/create-release-pr.yml)
- [`.github/workflows/require-additional-reviewer.yml`](https://github.com/MetaMask/action-require-additional-reviewer/blob/main/.github/workflows/require-additional-reviewer.yml)
  - **This workflow file self-references this action with the string "`/.`". Replace that string with "`MetaMask/action-require-additional-reviewer@v1`" in your workflow.**

Once the Require Additional Reviewer workflow has run once, you it will create a GitHub commit status that you can use as a mandatory check in your repository branch protection settings.

This action should never fail, and the status check it creates should only be either pending or successful. If the action fails to execute, first try recreating the release PR. If that doesn't work, identify the error produced by the workflow run and file a bug report.

### Access Token

Under recommended usage, the only input you have to provide to this action is an access token with the `read:org` scope. This token is necessary in order to determine the organization assocation of reviewers.
See the GitHub documentation for how to [create access tokens](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) and how to [use them in workflows](https://docs.github.com/en/actions/reference/encrypted-secrets).

### Constraints on Release Pull Requests

Due to constraints imposed by the GitHub Actions platform and the GitHub API, this action imposes some constraints on release pull requests. Therefore, if you use this action, your release pull requests:

- **must not** be rebased before being merged into the base branch.
  - This action uses the commit hash of the original base branch head to identify the workflow that created the release PR, in order to download the artifacts of that workflow.
  - Merging the base branch into the PR branch is fine.
- **should not** be left open for extended periods of time.
  - If your repository has a lot of `workflow_dispatch` events and a release PR is left open for a long time, eventually this action will fail to extract the ID of the workflow that created the release branch. This action only searches the first 100 successful `workflow_dispatch` events targeting the PR base branch for the workflow run that created the release PR.

## Contributing

### Setup

- Install [Node.js](https://nodejs.org) version 12
  - If you are using [nvm](https://github.com/creationix/nvm#installation) (recommended) running `nvm use` will automatically choose the right node version for you.
- Install [Yarn v1](https://yarnpkg.com/en/docs/install)
- Run `yarn setup` to install dependencies and run any requried post-install scripts
  - **Warning:** Do not use the `yarn` / `yarn install` command directly. Use `yarn setup` instead. The normal install command will skip required post-install scripts, leaving your development environment in an invalid state.

### Testing and Linting

Run `yarn lint` to run the linter, or run `yarn lint:fix` to run the linter and fix any automatically fixable issues.

This repository has no tests.

### Releasing

The project follows the same release process as the other GitHub Actions in the MetaMask organization. The GitHub Actions [`action-create-release-pr`](https://github.com/MetaMask/action-create-release-pr) and [`action-publish-release`](https://github.com/MetaMask/action-publish-release) are used to automate the release process; see those repositories for more information about how they work.

1. Choose a release version.

   - The release version should be chosen according to SemVer. Analyze the changes to see whether they include any breaking changes, new features, or deprecations, then choose the appropriate SemVer version. See [the SemVer specification](https://semver.org/) for more information.

2. If this release is backporting changes onto a previous release, then ensure there is a major version branch for that version (e.g. `1.x` for a `v1` backport release).

   - The major version branch should be set to the most recent release with that major version. For example, when backporting a `v1.0.2` release, you'd want to ensure there was a `1.x` branch that was set to the `v1.0.1` tag.

3. Trigger the [`workflow_dispatch`](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#workflow_dispatch) event [manually](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) for the `Create Release Pull Request` action to create the release PR.

   - For a backport release, the base branch should be the major version branch that you ensured existed in step 2. For a normal release, the base branch should be the main branch for that repository (which should be the default value).
   - This should trigger the [`action-create-release-pr`](https://github.com/MetaMask/action-create-release-pr) workflow to create the release PR.

4. Update the changelog to move each change entry into the appropriate change category ([See here](https://keepachangelog.com/en/1.0.0/#types) for the full list of change categories, and the correct ordering), and edit them to be more easily understood by users of the package.

   - Generally any changes that don't affect consumers of the package (e.g. lockfile changes or development environment changes) are omitted. Exceptions may be made for changes that might be of interest despite not having an effect upon the published package (e.g. major test improvements, security improvements, improved documentation, etc.).
   - Try to explain each change in terms that users of the package would understand (e.g. avoid referencing internal variables/concepts).
   - Consolidate related changes into one change entry if it makes it easier to explain.
   - Run `yarn auto-changelog validate --rc` to check that the changelog is correctly formatted.

5. Review and QA the release.

   - If changes are made to the base branch, the release branch will need to be updated with these changes and review/QA will need to restart again. As such, it's probably best to avoid merging other PRs into the base branch while review is underway.

6. Squash & Merge the release.

   - This should trigger the [`action-publish-release`](https://github.com/MetaMask/action-publish-release) workflow to tag the final release commit and publish the release on GitHub. Since this repository is a GitHub Action, this completes the release process.
     - Note that the shorthand major version tag is automatically updated when the release PR is merged. See [`publish-release.yml`](https://github.com/MetaMask/action-require-additional-reviewer/blob/main/.github/workflows/publish-release.yml) for details.
