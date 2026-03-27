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

    # Merge/diff tools
    merge.tool = "smerge";
    diff.tool = "smerge";
    mergetool.smerge.cmd = ''smerge mergetool "$BASE" "$LOCAL" "$REMOTE" "$MERGED" -o "$MERGED"'';
    mergetool.smerge.trustExitCode = true;
    difftool.smerge.cmd = ''smerge mergetool "$BASE" "$LOCAL" "$REMOTE"'';
    mergetool.keepBackup = false;

    # macOS credential helper
    credential.helper = "osxkeychain";

    # LFS
    filter.lfs.clean = "git-lfs clean -- %f";
    filter.lfs.smudge = "git-lfs smudge -- %f";
    filter.lfs.process = "git-lfs filter-process";
    filter.lfs.required = true;

    # Whitespace
    core.whitespace = "fix";
    apply.whitespace = "nowarn";

    # Submodules
    status.submodulesummary = true;
  };

  programs.git.ignores = [
    "*~"
    ".*.sw?"
    ".DS_Store"
    "._*"
    ".AppleDouble"
    ".LSOverride"
    ".Spotlight-V100"
    ".TemporaryItems"
    ".Trashes"
    ".VolumeIcon.icns"
    ".com.apple.timemachine.donotpresent"
    ".fseventsd"
    ".DocumentRevisions-V100"
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
