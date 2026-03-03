# Releasing

This project uses [release-please](https://github.com/googleapis/release-please) to automate versioning, changelogs, GitHub Releases, and tags.

## Prerequisites

Before releases can run, the following must be configured in the repository:

### GitHub App (for release-please)

A GitHub App is required so that release-created events trigger downstream workflows (e.g., publish). Personal access tokens don't trigger workflow events.

| Secret | Value |
|--------|-------|
| `RELEASE_APP_ID` | Numeric App ID of the GitHub App |
| `RELEASE_PRIVATE_KEY` | PEM-formatted private key |

The GitHub App needs **Contents** (read/write) and **Pull requests** (read/write) permissions on this repository.

### pub.dev environment (for publishing)

- Create a GitHub environment named `pub.dev` under **Settings → Environments**
- pub.dev OIDC authentication is handled by the `dart-lang/setup-dart` action

## How automated releases work

```
commit → main ──► release-please opens/updates PR
                    (bumps version, updates CHANGELOG)
                         │
                    merge PR
                         │
                    release-please creates GitHub Release + tag (vX.Y.Z-alpha.N)
                         │
                    publish.yml triggers on tag push
                         │
                    flutter pub publish --force
```

1. Push a conventional commit to `main` (directly or via PR merge).
2. The `release-please.yml` workflow runs and either opens a new release PR or updates an existing one.
3. The release PR bumps versions in all tracked files (via `x-release-please-version` annotations), updates `CHANGELOG.md`, and updates `.release-please-manifest.json`.
4. When the release PR is merged, release-please creates a GitHub Release and a git tag (e.g., `v0.1.0-alpha.3`).
5. The tag push triggers `publish.yml`, which runs `flutter pub publish --force`.

## Commits that trigger releases

Only commits with these prefixes increment the version:

| Prefix | Effect (during alpha) |
|--------|----------------------|
| `feat:` / `feat!:` | Bumps alpha counter (e.g., `alpha.2` → `alpha.3`) |
| `fix:` / `fix!:` | Bumps alpha counter |
| `perf:` | Bumps alpha counter |

Other prefixes (`chore:`, `docs:`, `ci:`, `test:`, `refactor:`, `style:`, `build:`, `revert:`) are included in the changelog but do **not** trigger a version bump on their own.

## Version-tracked files

release-please updates these files via `x-release-please-version` annotations:

| File | What's updated |
|------|---------------|
| `pubspec.yaml` | `version:` field |
| `lib/src/web/codec/user_codec.dart` | `_flutterLibraryVersion` constant |
| `android/.../ExperimentSdkCodec.kt` | `FLUTTER_LIBRARY_VERSION` constant |
| `ios/Classes/ExperimentSdkCodec.swift` | `flutterLibraryVersion` constant |
| `ios/amplitude_experiment.podspec` | `s.version` field |
| `android/build.gradle` | `version` property |
| `README.md` | Installation version in `pubspec.yaml` snippet |
| `CHANGELOG.md` | Prepends new release section |
| `.release-please-manifest.json` | Current version |

## If publish fails

If `publish.yml` fails after the GitHub Release is created:

1. **Re-run the workflow** — Go to Actions → "Publish to pub.dev" → Re-run failed jobs.
2. **Trigger manually** — Go to Actions → "Publish to pub.dev" → Run workflow (uses `workflow_dispatch`).
3. **Publish locally** — See "Fully manual publish" below.

## Manual release (using release-please CLI)

If the GitHub Action is unavailable, you can run release-please locally:

```bash
npx release-please release-pr \
  --repo-url=amplitude/experiment-flutter-client \
  --token=$GITHUB_TOKEN

npx release-please github-release \
  --repo-url=amplitude/experiment-flutter-client \
  --token=$GITHUB_TOKEN
```

## Fully manual publish (no CI)

```bash
git checkout main && git pull
flutter pub publish --dry-run   # verify
flutter pub publish             # publish
```

You must be an authenticated uploader on pub.dev.

## Graduating from alpha to stable 1.0.0

1. In `release-please-config.json`, change:
   ```json
   "prerelease": false
   ```
   and remove the `"prerelease-type"` and `"versioning"` keys.

2. The next release PR will produce `v1.0.0` (stripping the alpha suffix).

3. After `v1.0.0` is released, also remove `"bump-minor-pre-major"` and `"bump-patch-for-minor-pre-major"` so that standard semver applies:
   - `fix:` → patch bump (1.0.0 → 1.0.1)
   - `feat:` → minor bump (1.0.1 → 1.1.0)
   - `feat!:` / `fix!:` → major bump (1.1.0 → 2.0.0)
