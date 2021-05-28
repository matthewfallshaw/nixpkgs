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

  # TODO: Check whether these are in `nixpkgs`
  homebrew.brews = [
    # "rbenv"
    "trash"
  ];

  homebrew.casks = [
    # Development
    "atom"
    "dash"
    "db-browser-for-sqlite"
    "dbeaver-community"
    "docker"
    "dotnet"
    "gitup"
    "insomnia"
    "iterm2"
    "macvim"
    "rowanj-gitx"
    "vagrant"
    "vimr"
    "visual-studio-code"
    "zerobranestudio"

    # Crypto
    "electron-cash"
    "electrum"

    # Hardware hacking
    "arduino"
    # "freecad"
    "autodesk-fusion360"
    "cncjs"
    "meshlab"
    "meshmixer"
    "openscad"
    "prusaslicer"
    "sketchup"
    "superslicer"
    "ultimaker-cura"

    # Services from Homebrew
    "markdown-service-tools"

    # QuickLook plugins from Homebrew
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
    "epichrome"
    "etrecheckpro"
    "freeplane"
    "firefox"
    "google-chrome"
    "google-drive"
    "google-backup-and-sync"
    "gpg-suite"
    "grandperspective"
    "hammerspoon"
    "imageoptim"
    "inkscape"
    "karabiner-elements"
    "keybase"
    "keycue"
    "launchcontrol"
    "libreoffice"
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
    # "logitech-firmwareupdatetool"
    # "logitech-g-hub"
    # "logitech-options"
    "logitech-unifying"
    "onyx"
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
    Vimari = 1480933944;
    "WiFi Explorer" = 494803304;
    "The Unarchiver" = 425424353;
    Xcode = 497799835;
  };

  environment.systemPath = lib.mkIf ( builtins.elem "openscad" config.homebrew.casks )
    [ "/Applications/OpenSCAD.app/Contents/MacOS" ];
}
