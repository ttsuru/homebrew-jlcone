# Contributing

Issues and pull requests are welcome.

## Scope

- Following new JLCONE releases (normally the autobump workflow opens the PR)
- Gaps in `uninstall` / `zap`, and documentation fixes
- CI improvements

Problems inside the JLCONE app itself cannot be fixed here. Please contact
[JLCPCB support](https://jlcpcb.com/help/contact) for those.

## Local development

Homebrew expects a tap at `$(brew --repository)/Library/Taps/<user>/homebrew-<repo>`. Symlink your
working copy there so that `brew` commands run against it directly:

```sh
git clone https://github.com/ttsuru/homebrew-jlcone.git
cd homebrew-jlcone
mkdir -p "$(brew --repository)/Library/Taps/ttsuru"
ln -s "$PWD" "$(brew --repository)/Library/Taps/ttsuru/homebrew-jlcone"
brew trust --tap ttsuru/jlcone
```

## Bumping the version

1. Check the latest version: `brew livecheck --cask ttsuru/jlcone/jlcone`
2. Run `brew bump-cask-pr --no-fork --version <new version> ttsuru/jlcone/jlcone`. It downloads both
   dmgs, computes `sha256 arm:` and `sha256 intel:`, audits the cask and opens the PR.
   (If you edit by hand, update `version` and **both** checksums.)
3. Run the checks below.

```sh
brew style --cask ttsuru/jlcone/jlcone
brew audit --cask --strict --online ttsuru/jlcone/jlcone
brew livecheck --cask ttsuru/jlcone/jlcone     # must match the cask version
brew fetch --cask ttsuru/jlcone/jlcone         # sha256 must match
brew reinstall --cask ttsuru/jlcone/jlcone     # the app must launch
```

[docs/maintenance.md](docs/maintenance.md) explains how to check whether the bundle identifier,
minimum macOS version or update feed changed in a new release.

## Commit messages

Follow Homebrew conventions.

- Version bump: `jlcone 1.0.72`
- Anything else: `<token>: <summary>`, e.g. `jlcone: add missing zap path`

## Code of conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
