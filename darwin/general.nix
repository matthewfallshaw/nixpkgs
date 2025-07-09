{pkgs, ... }:

{
  # Networking
  networking.dns = [
    "1.1.1.1" # Cloudflare
    "8.8.8.8" # Google
  ];

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    terminal-notifier
  ];

  # environment.systemPath = [
  #   # User paths
  #   "/Users/matt/.local/bin"
  #   "/Users/matt/bin"

  #   # Nix paths
  #   "/Users/matt/.nix-profile/bin"
  #   "/etc/profiles/per-user/matt/bin"
  #   "/run/current-system/sw/bin"
  #   "/nix/var/nix/profiles/default/bin"

  #   # Homebrew paths (prioritized before system)
  #   "/opt/homebrew/bin"
  #   "/opt/homebrew/sbin"

  #   # Additional tools
  #   "/opt/X11/bin"

  #   # System paths (intentionally later)
  #   "/usr/local/bin"
  #   "/usr/bin"
  #   "/usr/sbin"
  #   "/bin"
  #   "/sbin"
  # ];

  # Fonts
  fonts.packages = with pkgs; [
    recursive
    nerd-fonts.jetbrains-mono
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Firewall
  networking.applicationFirewall = {
    enable = true;
    allowSigned = true;
    allowSignedApp = true;
    enableStealthMode = true;
  };

  # Store management
  nix.gc.automatic = true;
  nix.gc.interval.Hour = 3;
  nix.gc.options = "--delete-older-than 15d";
  nix.optimise.automatic = true;
  nix.optimise.interval.Hour = 4;
}
