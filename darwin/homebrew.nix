{ config, lib, ... }:
{
  # homebrew.enable = true;
  homebrew.enable = false;
  homebrew.autoUpdate = true;
  homebrew.cleanup = "zap";
  homebrew.global.brewfile = true;
  homebrew.global.noLock = true;

  homebrew.taps = [
    "homebrew/cask"
    "homebrew/cask-drivers"
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
    "homebrew/core"
    "homebrew/services"
  ];

  homebrew.masApps = {
    "1Password" = 1333542190;
    "Accelerate for Safari" = 1459809092;
    "AVG Cleaner" = 667434228;
    Calca = 635758264;
    "Contacts Sync For Google Gmail" = 451691288;
    eDrawings = 1209754386;
    Evernote = 406056744;
    Gapplin = 768053424;
    GarageBand = 682658836;
    "Icon Slate" = 439697913;
    iMovie = 408981434;
    Keynote = 409183694;
    Kindle = 405399194;
    "LG Screen Manager" = 1142051783;
    "Lights Switch" = 1181873676;
    "Microsoft Remote Desktop" = 1295203466;
    Numbers = 409203825;
    Pages = 409201541;
    Pixelmator = 407963104;
    "Pixelmator Pro" = 1289583905;
    Slack = 803453959;
    Vimari = 1480933944;            # Safari Vimium equiv
    "WiFi Explorer" = 494803304;
    "The Unarchiver" = 425424353;
    Xcode = 497799835;
  };

  homebrew.casks = [
    # Development
    "atom"
    "circuitjs1"
    "dash"
    "db-browser-for-sqlite"
    "dbeaver-community"
    "docker"
    "dotnet"
    "gitup"
    "insomnia"          # … but I hate it
    # "iterm2"
    "macvim"            # deletion candidate
    "rowanj-gitx"
    "sublime-merge"
    "vagrant"
    "vimr"
    "visual-studio-code"
    "zerobranestudio"   # deletion candidate

    # Crypto
    "electron-cash"
    "electrum"

    # Hardware hacking
    "arduino"
    # "freecad"
    "autodesk-fusion360"
    "meshlab"
    "meshmixer"
    "openscad"
    "prusaslicer"
    "raspberry-pi-imager"
    "superslicer"
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
    "balenaetcher"
    "calibre"
    "dropbox"
    "etrecheckpro"
    "freeplane"         # deletion candidate
    "firefox"
    "google-chrome"
    "google-drive"
    "google-backup-and-sync"
    "gpg-suite"         # deletion candidate
    "grandperspective"
    "hammerspoon"
    "imageoptim"
    "inkscape"
    "karabiner-elements"
    "keybase"
    "keycue"
    "launchcontrol"
    "nvalt"
    "quicksilver"
    "signal"
    "skyfonts"
    "skype"
    "spotify"
    "steam"
    "suspicious-package"
    "toggl-track"
    "tor-browser"
    "transmission"
    "typinator"
    "ubersicht"
    "unison"
    "viscosity"
    "vlc"
    "xquartz"
    "yed"

    # Other
    "logitech-camera-settings"
    "logitech-control-center"
    "logitech-unifying"
    "onyx"
  ];

  # TODO: Check whether these are in `nixpkgs`
  homebrew.brews = [
    # "rbenv"
    "trash"
  ];

  environment.systemPath = lib.mkIf ( builtins.elem "openscad" config.homebrew.casks )
    [ "/Applications/OpenSCAD.app/Contents/MacOS" ];
}
