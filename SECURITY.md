# Security Policy

## Scope

This tap is responsible for three things: downloading from the official URL, verifying the SHA-256
checksum, and defining how the app is installed and removed. Please report issues such as the
following as vulnerabilities in this tap:

- The cask `url` points anywhere other than the vendor's hosts, or a `sha256` does not match the
  official file
- `uninstall` / `zap` deletes files that do not belong to JLCONE
- Problems with the permissions or pinned dependencies of the CI workflows

Vulnerabilities in the JLCONE app itself cannot be handled here. Report them to
[JLCPCB](https://jlcpcb.com/help/contact).

## Reporting

Use GitHub's [private vulnerability reporting](https://github.com/ttsuru/homebrew-jlcone/security/advisories/new)
for anything that could put users at risk. Do not open a public issue.

## How integrity is ensured

- Each `sha256` in the cask is computed from the dmg served by the official host over HTTPS. Homebrew
  verifies it after every download and refuses to install on a mismatch.
- The vendor's `latest-mac.yml` update feed publishes a SHA-512 for each dmg. It is compared with the
  downloaded files when the cask is updated (see [docs/maintenance.md](docs/maintenance.md)).
- `JLCONE.app` is signed with an Apple Developer ID and notarized
  (Team ID `FPD7225NBW`, Jialichuang(Hong Kong) co., Limited). CI verifies the signature, the Team ID
  and the Gatekeeper assessment after installing the cask on both Apple Silicon and Intel runners.
- GitHub Actions used by the workflows are pinned to commit SHAs and kept current by Dependabot.
  Workflows start from `permissions: {}` and grant each job only what it needs.
