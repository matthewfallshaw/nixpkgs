{ config, lib, pkgs, ... }:

let
  mkIfCaskPresent = cask: lib.mkIf (lib.any (x: x == cask) config.homebrew.casks);
  brewBinPrefix = if pkgs.system == "aarch64-darwin" then "/opt/homebrew/bin" else "/usr/local/bin";
in
{
  environment.shellInit = ''
    eval "$(${brewBinPrefix}/brew shellenv)"
  '';

  homebrew.enable = true;
  # homebrew.enable = false;
  homebrew.brewPrefix = brewBinPrefix;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  # homebrew.onActivation.upgrade = true;
  homebrew.global.brewfile = true;
  homebrew.global.lockfiles = false;

  homebrew.taps = [
    "homebrew/cask"
    "homebrew/cask-drivers"
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
    "homebrew/core"
    "homebrew/services"
  ];

  homebrew.masApps = {
    # "1Password" = 1333542190;
    "Accelerate for Safari" = 1459809092;
    "AVG Cleaner" = 667434228;
    Calca = 635758264;
    "Contacts Sync For Google Gmail" = 451691288;
    eDrawings = 1209754386;
    Evernote = 406056744;
    Gapplin = 768053424;
    GarageBand = 682658836;
    "Icon Slate" = 439697913;
    # iMovie = 408981434;
    Keynote = 409183694;
    Kindle = 405399194;
    "LG Screen Manager" = 1142051783;
    "Microsoft Remote Desktop" = 1295203466;
    Numbers = 409203825;
    Pages = 409201541;
    Pixelmator = 407963104;
    "Pixelmator Pro" = 1289583905;
    # Slack = 803453959;
    Vimari = 1480933944;            # Safari Vimium equiv
    "WiFi Explorer" = 494803304;
    "The Unarchiver" = 425424353;
    Xcode = 497799835;
  };

  homebrew.casks = [
    # Development
    "atom"
    "circuitjs1"
    "db-browser-for-sqlite"
    "dbeaver-community"
    "docker"
    "dotnet"
    # "github"            # GitHub Desktop
    "gitup"
    "insomnia"          # … but I hate it
    # "iterm2"
    "macvim"            # deletion candidate
    "meld"              # visual diff and merge tool
    "neovide"
    "paraview"
    "rowanj-gitx"
    "sublime-merge"
    "vagrant"
    "visual-studio-code"
    "zerobranestudio"   # deletion candidate

    # Crypto
    "electron-cash"
    "electrum"

    # Hardware hacking
    "arduino"
    "freecad"
    "autodesk-fusion360"
    "meshlab"
    # "meshmixer"
    "openscad"
    "prusaslicer"
    "raspberry-pi-imager"
    # "superslicer"
    "ultimaker-cura"    # deletion candidate

    # Services from Homebrew
    "markdown-service-tools"

    # QuickLook plugins from Homebrew
    "betterzip"
    "qlcolorcode"
    "qlimagesize"
    "qlmarkdown"
    "qlstephen"
    "quicklook-csv"
    "quicklook-json"

    # Other GUI apps
    "1password"
    "1password-cli"
    "adobe-acrobat-reader"
    "balenaetcher"
    "calibre"
    "dropbox"
    "etrecheckpro"
    "freeplane"         # deletion candidate
    "firefox"
    "fujitsu-scansnap-home"
    "google-chrome"
    "google-drive"
    "gpg-suite"         # deletion candidate
    "grandperspective"
    "hammerspoon"
    "horos"             # Dicom & medical viewer
    "imageoptim"
    "inkscape"
    "karabiner-elements"
    "keybase"
    "keycue"
    "launchcontrol"
    "nvalt"
    "quicksilver"
    "signal"
    "shortcutdetective"
    "skype"
    "spotify"
    "steam"
    "suspicious-package"
    "tableau-reader"
    "toggl-track"
    "tor-browser"
    "transmission"
    "typinator"
    "ubersicht"
    "unison"
    "viscosity"
    "vlc"
    "webcatalog"
    "xquartz"
    "yed"
    "yt-music"

    # Other
    "logitech-camera-settings"
    "logitech-options"
    "logitech-unifying"
    "onyx"
    "macfuse"

    "wkhtmltopdf"
  ];

  # TODO: Check whether these are in `nixpkgs`
  homebrew.brews = [
    # "rbenv"
    "trash"
    "switchaudio-osx"
    "mupdf-tools"
    "rtl_433"
    # "ext4fuse"
  ];

  environment.systemPath = mkIfCaskPresent "openscad"
    [ "/Applications/OpenSCAD.app/Contents/MacOS" ];
}
