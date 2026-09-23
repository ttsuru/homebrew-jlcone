# homebrew-jlcone

> [!IMPORTANT]
> **This tap is archived.** `jlcone` is now in the official Homebrew cask repository
> ([Homebrew/homebrew-cask#288488](https://github.com/Homebrew/homebrew-cask/pull/288488), merged 2026-09-20),
> so no third-party tap is needed any more:
>
> ```sh
> brew install --cask jlcone
> ```
>
> If you installed from this tap, switch with:
>
> ```sh
> brew untap ttsuru/jlcone
> brew reinstall --cask jlcone
> ```
>
> Version bumps and bug reports go to [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask).
> The content below is kept for reference only.

[![tests](https://github.com/ttsuru/homebrew-jlcone/actions/workflows/tests.yml/badge.svg)](https://github.com/ttsuru/homebrew-jlcone/actions/workflows/tests.yml)

An unofficial [Homebrew](https://brew.sh/) tap for [JLCONE](https://jlcone.com/download), JLCPCB's
official desktop app for getting quotes, uploading Gerber files, placing orders and tracking them.

Upstream only offers a manual `.dmg` download. This tap wraps it in a cask so that you can:

- install the official build for your CPU (Apple Silicon or Intel) with SHA-256 verification,
- follow new releases with `brew upgrade` (the tap runs `livecheck` daily and opens a bump PR automatically),
- remove the app with `brew uninstall`, or with `--zap` to also remove its settings and caches.

> [!NOTE]
> This tap is not affiliated with JLCPCB and does not redistribute the software. The cask points
> at the official download URL; the app itself is proprietary and governed by JLCPCB's
> [terms](https://jlcpcb.com/help/article/Terms-%26-Conditions).

## Requirements

| | |
| --- | --- |
| macOS | 11 Big Sur or later (`LSMinimumSystemVersion` of the app) |
| CPU | Apple Silicon or Intel; the cask picks the matching native build |
| Homebrew | 6.0 or later (tap trust) |

## Install

```sh
brew install --cask ttsuru/jlcone/jlcone
```

Using the fully-qualified name trusts only this cask. To trust the whole tap and use the short name:

```sh
brew tap ttsuru/jlcone
brew trust --tap ttsuru/jlcone
brew install --cask jlcone
```

If you already installed JLCONE by dragging it out of the official dmg, adopt it instead of
installing a second copy:

```sh
brew install --cask --adopt ttsuru/jlcone/jlcone
```

## Upgrade

JLCONE updates itself (it ships `electron-updater`), so the cask is marked `auto_updates true` and a
plain `brew upgrade` leaves it alone. To upgrade through Homebrew anyway:

```sh
brew update && brew upgrade --cask --greedy jlcone
```

## Uninstall

```sh
brew uninstall --cask jlcone          # quits the app, removes it and its login item
brew uninstall --cask --zap jlcone    # also removes settings, caches and logs
```

## How updates reach this tap

The [autobump workflow](.github/workflows/autobump.yml) runs `brew bump` every day. It reads the same
`latest-mac.yml` feed the app's own updater uses, and when the version changes it opens a pull
request with the new version and both checksums. The [tests workflow](.github/workflows/tests.yml)
then audits the cask and installs it on Apple Silicon and Intel runners, checking the code signature
and notarization, before the change is merged.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/maintenance.md](docs/maintenance.md).
Report vulnerabilities as described in [SECURITY.md](SECURITY.md).

## License

The tap (cask, docs, CI) is released under the [MIT License](LICENSE). JLCONE is copyrighted by
Jialichuang (Hong Kong) Co., Limited and is not part of this repository.
