cask "jlcone" do
  arch arm: "arm64", intel: "x64"

  version "1.0.71"
  sha256 arm:   "b3ccacd5be9f3e1d7656c62bddd42141fba48110c876329f02284aa4901afd2b",
         intel: "5423ef603d89bb4e60271770c234a0d0e4f9bcbaa96d90cbd8fe93a94eaa3a29"

  # The download page resolves its links through an update API that returns
  # rs.jlcpcb.com URLs and then rewrites the host to rs.jlcone.com. Both hosts
  # serve the same object; use the one the page hands to the browser.
  url "https://rs.jlcone.com/static/APP/app_version/jlcone-#{version}-#{arch}.dmg"
  name "JLCONE"
  desc "Desktop client for JLCPCB quoting, ordering and order tracking"
  homepage "https://jlcone.com/download"

  # electron-updater feed used by the app itself (app-update.yml).
  livecheck do
    url "https://rs.jlcone.com/static/APP/app_version/latest-mac.yml"
    strategy :electron_builder
  end

  auto_updates true
  depends_on :macos

  app "JLCONE.app"

  # The app can register itself as a login item ("auto-start" setting).
  uninstall quit:       "com.jlcpcb.www",
            login_item: "JLCONE"

  zap trash: [
    "~/Library/Application Support/jlcone",
    "~/Library/Caches/com.jlcpcb.www.ShipIt",
    "~/Library/Caches/jlcone-updater",
    "~/Library/Preferences/com.jlcpcb.www.plist",
  ]
end
