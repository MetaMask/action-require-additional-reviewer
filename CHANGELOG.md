# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.5]
### Changed
- Resolve GitHub action deprecation warnings ([#49](https://github.com/MetaMask/action-require-additional-reviewer/pull/49))

## [1.0.4]
### Changed
- Bump actions, removing deprecation warning ([#47](https://github.com/MetaMask/action-require-additional-reviewer/pull/47))

## [1.0.3]
### Fixed
- Status checks for non-release PRs ([#42](https://github.com/MetaMask/action-require-additional-reviewer/pull/42))
  - [#37](https://github.com/MetaMask/action-require-additional-reviewer/pull/37) did not work as expected, and instead prevent the status check used by this action from succeeding for non-release PRs. We will fix PRs from forks separately.

## [1.0.2]
### Fixed
- Fix action always failing for PRs from forks ([#37](https://github.com/MetaMask/action-require-additional-reviewer/pull/37))

## [1.0.1]
### Fixed
- Ensure action does not fail if release branch has no merge commits ([#33](https://github.com/MetaMask/action-require-additional-reviewer/pull/33))

## [1.0.0]
### Added
- Initial release

[Unreleased]: https://github.com/MetaMask/action-require-additional-reviewer/compare/v1.0.5...HEAD
[1.0.5]: https://github.com/MetaMask/action-require-additional-reviewer/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/MetaMask/action-require-additional-reviewer/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/MetaMask/action-require-additional-reviewer/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/MetaMask/action-require-additional-reviewer/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/MetaMask/action-require-additional-reviewer/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/MetaMask/action-require-additional-reviewer/releases/tag/v1.0.0
