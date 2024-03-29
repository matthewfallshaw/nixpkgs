{ pkgs, lib, ... }:

{
  imports = [
    # Other nix-darwin configuration
    ./homebrew.nix
    ./defaults.nix
  ];

  # Networking
  networking.dns = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    kitty
    iterm2
    terminal-notifier
  ];

  # Fonts
  fonts.fontDir.enable= true;
  fonts.fonts = with pkgs; [
     recursive
     (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
   ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Lorri daemon
  # https://github.com/target/lorri
  # Used in conjuction with Direnv which is installed in `../home/default.nix`.
  services.lorri.enable = true;
}
