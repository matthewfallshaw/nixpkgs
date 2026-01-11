{ config, ... }:

{
  # Git
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.enable
  # Aliases config in ./configs/git-aliases.nix
  programs.git.enable = true;

  programs.git.settings = {
    diff.colorMoved = "default";
    pull.rebase = true;
    rebase.autoStash = true;
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
    user.email = "5561+${config.home.user-info.githubUsername}@users.noreply.github.com";
    user.name = config.home.user-info.fullName;
  };

  programs.git.ignores = [
    "*~"
    ".DS_Store"
  ];

  programs.git.attributes = [ "*.scpt filter=osa" ];

  # Enhanced diffs
  # programs.git.delta.enable = true;
  programs.difftastic.enable = true;
  programs.difftastic.git.enable = true;
  programs.difftastic.options.display = "inline";

  # GitHub CLI
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.gh.enable
  # Aliases config in ./gh-aliases.nix
  programs.gh.enable = true;
  programs.gh.settings.version = 1;
  programs.gh.settings.git_protocol = "ssh";
}
