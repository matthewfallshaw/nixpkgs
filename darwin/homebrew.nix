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
  # homebrew.enable = false;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;

  homebrew.taps = [
    # "homebrew/cask"
    # "homebrew/core"
    "homebrew/services"
    "nrlquaker/createzap"
  ];

  # Prefer installing application from the Mac App Store
  homebrew.masApps = {
    # "1Password" = 1333542190;
    "Accelerate for Safari" = 1459809092;
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
    "docker-desktop"
    # "dotnet"
    "ghostty"
    # "github"            # GitHub Desktop
    # "iterm2"
    "macvim-app"            # deletion candidate
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
    # "autodesk-fusion360"
    "freecad"
    #"kicad"
    # "meshmixer"
    "openscad"
    "prusaslicer"
    "raspberry-pi-imager"
    # "superslicer"
    # "ultimaker-cura"    # deletion candidate

    # Services from Homebrew
    "markdown-service-tools"

    # QuickLook plugins from Homebrew
    "betterzip"
    "qlcolorcode"
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
    # "horos"             # Dicom & medical viewer
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
    # "tableau-reader"
    "todoist-app"
    # "toggl-track"
    "tor-browser"
    "transmission"
    "typinator"
    "ubersicht"
    "unison-app"
    "viscosity"
    "vlc"
    # "webcatalog"
    # "gcenx/wine/wineskin"
    "Kegworks-App/kegworks/kegworks"   # successor to wineskin ?
    "xquartz"
    "yed"
    "yt-music"

    # Other
    "logitech-camera-settings"
    "logitech-options"
    "logitech-unifying"
    "onyx"
    "macfuse"

    "microsoft-edge"
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

  # Hack: https://github.com/ghostty-org/ghostty/discussions/2832
  environment.variables.XDG_DATA_DIRS = mkIf (caskPresent "ghostty") [
    "$GHOSTTY_SHELL_INTEGRATION_XDG_DIR"
  ];

  # For cli packages that aren't currently available for macOS in `nixpkgs`. Packages should be
  # installed in `../home/packages.nix` whenever possible.
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

  # OpenSCAD path is now managed in darwin/general.nix with conditional logic
}
