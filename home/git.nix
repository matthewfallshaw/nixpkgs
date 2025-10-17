{ config, ... }:

{
  # Git
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.enable
  # Aliases config in ./configs/git-aliases.nix
  programs.git.enable = true;

  programs.git.extraConfig = {
    diff.colorMoved = "default";
    pull.rebase = true;
    rebase.autoStash = true;
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
  };

  programs.git.ignores = [
    "*~"
    ".DS_Store"
  ];

  programs.git.userEmail = "5561+matthewfallshaw@users.noreply.github.com";
  programs.git.userName = config.home.user-info.fullName;
  programs.git.attributes = [ "*.scpt filter=osa" ];

  # Enhanced diffs
  # programs.git.delta.enable = true;
  programs.git.difftastic.enable = true;
  programs.git.difftastic.options.display = "inline";

  # GitHub CLI
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.gh.enable
  # Aliases config in ./gh-aliases.nix
  programs.gh.enable = true;
  programs.gh.settings.version = 1;
  programs.gh.settings.git_protocol = "ssh";
}
