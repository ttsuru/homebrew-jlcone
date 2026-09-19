# Maintenance guide

The cask in this tap was written from an analysis of the official JLCONE 1.0.71 disk images. This
document records the findings and the design decisions, so that a maintainer can tell what needs to
change in the cask when a new release behaves differently.

## How the download URL is discovered

<https://jlcone.com/download> contains no static download links. On load, the page sends one request
per platform to an update API and opens the returned URL when the button is clicked:

```sh
curl -s -X POST https://jlcone.com/api/overseas-core-platform/baseDataConfig/checkUpdate \
  -H 'Content-Type: application/json' \
  -d '{"platform":"macos(m)","versionCode":"0"}'      # or "macos(intel)", "windows", "linux"
```

```json
{"data":{"platform":"macos(m)","versionCode":"1.0.71",
         "updateUrl":"https://rs.jlcpcb.com/static/APP/app_version/jlcone-1.0.71-arm64.dmg"}}
```

The page then replaces the host with `rs.jlcone.com` before opening the link. Both hosts serve the
same object (identical `ETag` and size). The cask uses `rs.jlcone.com` because that is what a browser
user actually receives, and because it shares its domain with the `homepage`.

The same directory holds the `electron-updater` feed, which is what `livecheck` reads:

```text
https://rs.jlcone.com/static/APP/app_version/latest-mac.yml
```

It lists the version plus the file name, size and SHA-512 of `jlcone-<version>-arm64.dmg`,
`jlcone-<version>-x64.dmg` and the two `-mac.zip` archives used for in-app updates.

## What is in the disk image (1.0.71)

| Item | Value |
| --- | --- |
| Download URLs | `https://rs.jlcone.com/static/APP/app_version/jlcone-1.0.71-{arm64,x64}.dmg` |
| Contents | `JLCONE.app` and an `/Applications` symlink (drag-and-drop install, no pkg) |
| Bundle identifier | `com.jlcpcb.www` |
| Version | `CFBundleShortVersionString` = `CFBundleVersion` = `1.0.71` |
| Minimum macOS | `LSMinimumSystemVersion` = 11.0 |
| Architectures | One dmg per architecture; each executable is single-arch (`arm64` or `x86_64`) |
| Signature | Developer ID Application: Jialichuang(Hong Kong) co., Limited (`FPD7225NBW`), hardened runtime, notarized and stapled |
| Framework | Electron, packaged with electron-builder; `package.json` name is `jlcone`, `productName` is `JLCONE` |
| URL scheme | `jlcone://` |
| Self-update | `electron-updater` with Squirrel.Mac; `app-update.yml` has `provider: generic`, `url: http://rs.jlcpcb.com/static/APP/app_version`, `updaterCacheDirName: jlcone-updater` |
| Login item | The "auto-start" setting calls `app.setLoginItemSettings({ openAtLogin })` |

Note that the app's built-in updater fetches its feed over plain HTTP. That is upstream behaviour and
outside the control of this tap; the cask itself downloads over HTTPS and is checksum-verified.

## Design decisions in the cask

| Stanza | Decision |
| --- | --- |
| `arch arm: "arm64", intel: "x64"` | Matches the upstream file names; there is no universal build |
| `sha256 arm:, intel:` | One checksum per dmg. `brew bump-cask-pr` updates both |
| `url` | `rs.jlcone.com`, see above. Same domain as `homepage`, so no `verified:` is needed |
| `homepage` | `https://jlcone.com/download`, because `https://jlcone.com/` returns 404 |
| `livecheck` | `strategy :electron_builder` on `latest-mac.yml`, the feed the app's own updater trusts |
| `auto_updates true` | The app updates itself in place, so `brew upgrade` skips it unless `--greedy` is given |
| `depends_on :macos` | The real minimum is macOS 11, which is older than anything Homebrew still supports, so `brew style` rejects an explicit `macos: :big_sur` as redundant |
| `uninstall quit:` | Quits the app by bundle identifier before removal |
| `uninstall login_item:` | Removes the login item the "auto-start" setting may have created |
| `zap trash:` | Standard Electron locations derived from the bundle identifier, the `package.json` name and `updaterCacheDirName`. They come from static analysis of the bundle; re-check them against a machine where the app has been used (see below) |

## Checklist for a new release

Run these after the autobump PR appears, or after `brew bump-cask-pr`.

```sh
# 1. Fetch the dmg and look inside
brew fetch --cask ttsuru/jlcone/jlcone
DMG="$(brew --cache --cask ttsuru/jlcone/jlcone)"
hdiutil attach -nobrowse -readonly -mountpoint /tmp/jlcone "$DMG"
ls -la /tmp/jlcone                                  # still just JLCONE.app?
APP=/tmp/jlcone/JLCONE.app
plutil -p "$APP/Contents/Info.plist" | grep -E 'CFBundleIdentifier|CFBundleShortVersionString|LSMinimumSystemVersion'
lipo -archs "$APP/Contents/MacOS/JLCONE"            # a universal build would let us drop `arch`
codesign -dvv "$APP" 2>&1 | grep -E 'Authority|TeamIdentifier'
spctl --assess --type execute -vv "$APP"
xcrun stapler validate "$APP"
cat "$APP/Contents/Resources/app-update.yml"        # feed URL and updater cache directory
hdiutil detach /tmp/jlcone

# 2. Cross-check the dmg against the vendor's feed (base64 SHA-512)
openssl dgst -sha512 -binary "$DMG" | base64
curl -s https://rs.jlcone.com/static/APP/app_version/latest-mac.yml

# 3. Validate the cask
brew style --cask ttsuru/jlcone/jlcone
brew audit --cask --strict --online ttsuru/jlcone/jlcone
brew livecheck --cask ttsuru/jlcone/jlcone

# 4. Test on a real machine
brew reinstall --cask ttsuru/jlcone/jlcone
open -a JLCONE

# 5. After using the app, check that `zap` still covers everything it creates
ls -d ~/Library/{"Application Support",Caches,HTTPStorages,Logs,Preferences,"Saved Application State"}/*{jlc,JLC}* 2>/dev/null
```

What to change when something differs:

| Change | Action |
| --- | --- |
| Bundle identifier changed | Update `uninstall quit:` and the `zap` paths |
| `LSMinimumSystemVersion` rose to a release Homebrew still supports | Replace `depends_on :macos` with `depends_on macos: :<release>` and update the README |
| A universal dmg replaced the per-arch ones | Drop `arch` and use a single `sha256` |
| File naming or host changed | Fix `url` and the `livecheck` URL |
| `updaterCacheDirName` or the `package.json` name changed | Update the `zap` paths |
| The app started installing helpers, launch agents or a pkg | Add the matching `uninstall` directives |

## CI

- [tests.yml](../.github/workflows/tests.yml): on `push` and `pull_request`, runs
  `brew test-bot --only-tap-syntax` (readall, style, audit) and actionlint. The cask job runs on an
  Apple Silicon and an Intel runner so both dmgs are covered: strict online audit, a check that
  `livecheck` agrees with the cask version, and checksum verification. On pull requests it also
  installs the cask, verifies the code signature, Team ID and Gatekeeper assessment, then runs
  `brew uninstall --zap`.
- [autobump.yml](../.github/workflows/autobump.yml): runs `brew bump --casks --open-pr` daily and
  opens a PR when upstream publishes a new version. Requires "Allow GitHub Actions to create and
  approve pull requests" in the repository settings.
- [dependabot.yml](../.github/dependabot.yml): keeps the SHA-pinned GitHub Actions current, weekly.
