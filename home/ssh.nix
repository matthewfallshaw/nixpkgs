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
    "notnux6 notnux6.local" = {
      hostname = "notnux6.local";
      user = "matt";
      identityFile = "~/.ssh/id_ed25519.pub";
      extraOptions.IdentitiesOnly = "yes";
    };
    "notnux7 notnux7.local" = {
      hostname = "notnux7.local";
      user = "matt";
      identityFile = "~/.ssh/id_ed25519.pub";
      extraOptions.IdentitiesOnly = "yes";
    };
    "ha homeassistant homeassistant.local" = {
      hostname = "homeassistant.local";
      user = "root";
    };
    "xl octopixl octopixl.local" = {
      hostname = "octopixl.local";
      user = "pi";
    };
    "bear bear.local" = {
      hostname = "bear.local";
      user = "pi";
    };
    "lead leadcnc leadcnc.local" = {
      hostname = "leadcnc.local";
      user = "pi";
    };
  };
}
