{ ... }:

{
  # SSH
  # https://nix-community.github.io/home-manager/options.html#opt-programs.ssh.enable
  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;

  programs.ssh.matchBlocks = {
    "*" = {
      controlPath = "~/.ssh/%C"; # ensures the path is unique but also fixed length
    };
    "ha homeassistant homeassistant.local" = {
      hostname = "homeassistant.local";
      user = "root";
      # identityFile = "~/.ssh/id_rsa";
      # identityFile = "~/.ssh/id_ed25519";
    };
    "xl octopixl octopixl.local" = {
      hostname = "octopixl.local";
      user = "pi";
    };
    "bear bear.local" = {
      hostname = "bear.local";
      user = "pi";
    };
    "lead leadcnc leadcnc.local fnc fluidnc" = {
      hostname = "leadcnc.local";
      user = "pi";
    };
  };
}
