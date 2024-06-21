{ config, lib, ... }:

let
  inherit (lib) mkIf;
  caskPresent = cask: lib.any (x: x.name == cask) config.homebrew.casks;
  brewEnabled = config.homebrew.enable;
in

{
  environment.shellInit = mkIf brewEnabled ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
  # For some reason if the Fish completions are added at the end of `fish_complete_path` they don't
  # seem to work, but they do work if added at the start.
  programs.fish.interactiveShellInit = mkIf brewEnabled ''
    if test -d (brew --prefix)"/share/fish/completions"
      set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
      set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
  '';

  homebrew.enable = true;
  # homebrew.enable = false;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;

  homebrew.taps = [
    "homebrew/cask-drivers"
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
    "homebrew/services"
    "nrlquaker/createzap"
  ];

  # Prefer installing application from the Mac App Store
  homebrew.masApps = {
    # "1Password" = 1333542190;
    "Accelerate for Safari" = 1459809092;
    "AVG Cleaner" = 667434228;
    Calca = 635758264;
    "Contacts Sync For Google Gmail" = 451691288;
    # Evernote = 406056744;
    Gapplin = 768053424;
    # GarageBand = 682658836;
    "Icon Slate" = 439697913;
    # iMovie = 408981434;
    Keynote = 409183694;
    "LG Screen Manager" = 1142051783;
    "Microsoft Remote Desktop" = 1295203466;
    Numbers = 409203825;
    Pages = 409201541;
    "Pixelmator Pro" = 1289583905;
    # Slack = 803453959;
    Vimari = 1480933944;            # Safari Vimium equiv
    "WiFi Explorer" = 494803304;
    "The Unarchiver" = 425424353;
    Xcode = 497799835;
  };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitiations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = [
    # Development
    "circuitjs1"
    "db-browser-for-sqlite"
    "dbeaver-community"
    "docker"
    "dotnet"
    # "github"            # GitHub Desktop
    "gitup"
    # "iterm2"
    "macvim"            # deletion candidate
    "meld"              # visual diff and merge tool
    "neovide"
    "paraview"
    "sublime-merge"
    "vagrant"
    "visual-studio-code"

    # Crypto
    "electron-cash"
    "electrum"

    # Hardware hacking
    "arduino"
    "freecad"
    # "autodesk-fusion360"
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
    "firefox"
    "fujitsu-scansnap-home"
    "google-chrome"
    "google-drive"
    "grandperspective"
    "hammerspoon"
    "hugin"
    "horos"             # Dicom & medical viewer
    "imageoptim"
    "inkscape"
    "karabiner-elements"
    "keybase"
    "keyclu"
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
    "todoist"
    "toggl-track"
    "tor-browser"
    "transmission"
    "typinator"
    "ubersicht"
    "unison"
    "viscosity"
    "vlc"
    "webcatalog"
    "gcenx/wine/wineskin"
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

    "microsoft-edge"
  ];

  # Configuration related to casks
  # home-manager.users.${config.users.primaryUser.username}.programs.ssh =
  #   mkIf (caskPresent "1password-cli" && config ? home-manager) {
  #     enable = true;
  #     extraConfig = ''
  #       # Only set `IdentityAgent` not connected remotely via SSH.
  #       # This allows using agent forwarding when connecting remotely.
  #       Match host * exec "test -z $SSH_TTY"
  #         IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  #     '';
  #   };

  # For cli packages that aren't currently available for macOS in `nixpkgs`.Packages should be
  # installed in `../home/default.nix` whenever possible.
  homebrew.brews = [
    "alerter"
    # "ext4fuse"
    "mupdf-tools"
    "rtl_433"
    # "rbenv"
    "switchaudio-osx"
    # "terminal-notifier"
    "trash"
  ];

  # Include OpenSCAD path in environment.systemPath if OpenSCAD cask is present
  environment.systemPath = mkIf (caskPresent "openscad")
    [ "/Applications/OpenSCAD.app/Contents/MacOS" ];
}
