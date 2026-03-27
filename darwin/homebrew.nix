{ config, lib, ... }:

let
  inherit (lib) mkIf;
  caskPresent = cask: lib.any (x: x.name == cask) config.homebrew.casks;
  brewEnabled = config.homebrew.enable;
  brewShellInit = mkIf brewEnabled ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';
in

{
  # environment.shellInit = brewShellInit;
  # programs.zsh.shellInit = brewShellInit; # `zsh` doesn't inherit `environment.shellInit`
  # Note: Homebrew PATH is now managed directly in environment.systemPath

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
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;

  homebrew.taps = [
    "nrlquaker/createzap"
    "vjeantet/tap" # for alerter
    "sikarugir-app/sikarugir" # for sikarugir cask (zap cleanup tries to untap otherwise)
  ];

  # Apps from the Mac App Store
  homebrew.masApps = {
    "Accelerate for Safari" = 1459809092;
    Calca = 635758264;
    "Contacts Sync For Google Gmail" = 451691288;
    # Evernote = 406056744;
    # FIXME: Evernote is installed. Where did it come from if not here?
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
    # Slack = 803453959; # provided by Bellroy
    Vimari = 1480933944; # Safari Vimium equiv
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
    "docker-desktop"
    "iterm2"
    "macvim-app" # deletion candidate
    "neovide-app"
    # "paraview"
    "sublime-merge"
    # "temurin"           # PlantUML renderer
    #"vagrant"
    #"visual-studio-code"   # rely on nix packages instead

    # Crypto
    "electron-cash"
    "electrum"

    # Hardware hacking
    # "autodesk-fusion360"  # manual install from insider program https://feedback.autodesk.com/project/home.html?cap=326ccb1f-9653-409c-8884-c57523f9e054&display=personal
    "cloudcompare"
    "freecad"
    "kicad"
    "meshlab"
    # "meshmixer"          # no longer in Homebrew; Autodesk discontinued it
    "openscad"
    "prusaslicer"
    "raspberry-pi-imager"
    # "superslicer"

    # Services from Homebrew
    "markdown-service-tools"

    # QuickLook plugins from Homebrew
    "betterzip"
    "qlcolorcode"
    "qlmarkdown"
    "qlstephen"
    "quicklook-csv"

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
    # "horos"             # Dicom & medical viewer
    "imageoptim"
    "inkscape"
    "karabiner-elements"
    "keybase"
    "keyclu"
    "keycue"
    "launchcontrol"
    "nvalt"
    "obsidian"
    "private-internet-access"
    "quicksilver"
    "setapp"
    "signal"
    "shortcutdetective"
    "spotify"
    "steam"
    "suspicious-package"
    "todoist-app"
    "tor-browser"
    "transmission"
    "typinator"
    "ubersicht"
    "unison-app"
    "viscosity"
    "vlc"

    "Sikarugir-App/sikarugir/sikarugir" # successor to wineskin → kegworks → sikarugir

    "xquartz"
    "yed"
    "yt-music"

    # Other
    "logitech-camera-settings"
    "logitech-options"
    "onyx"
    "macfuse"

    "microsoft-edge"
    "microsoft-excel"
    "microsoft-word"
  ];

  # Configuration related to casks
  home-manager.users.${config.users.primaryUser.username} =
    mkIf (caskPresent "1password" && config ? home-manager)
      {
        # https://developer.1password.com/docs/ssh/get-started
        programs.ssh.enable = true;
        programs.ssh.extraConfig = ''
          # Only set `IdentityAgent` not connected remotely via SSH.
          # This allows using agent forwarding when connecting remotely.
          Match host * exec "test -z $SSH_TTY"
            IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        '';
        # https://developer.1password.com/docs/ssh/git-commit-signing/
        programs.git.signing = {
          format = "ssh";
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRE89kenq6taAlJpiF2KOJo7OY9IX2tc5xauNJT1Tjb";
          signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          signByDefault = true;
        };
      };

  # For cli packages that aren't currently available for macOS in `nixpkgs`. Packages should be
  # installed in `../home/packages.nix` whenever possible.
  homebrew.brews = [
    "mas" # nix-darwin puts pkgs.mas 2.2.2 on PATH but brew bundle needs `mas get` (3.x+)
    "vjeantet/tap/alerter"
    "mupdf-tools"
    "rtl_433"
    "switchaudio-osx"
    "trash"
  ];

  # OpenSCAD path is now managed in darwin/general.nix
}
