{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) attrValues mkIf elem;

  mkOpRunAliases = cmds:
    lib.genAttrs cmds (cmd: mkIf (elem pkgs.${cmd} config.home.packages) "op run -- ${cmd}");
in

{
  # 1Password CLI plugin integration
  # https://developer.1password.com/docs/cli/shell-plugins/nix
  # programs._1password-shell-plugins.enable = true;
  # programs._1password-shell-plugins.plugins = attrValues {
  #   inherit (pkgs) gh cachix;
  # };
  # Setup tools to work with 1Password
  # home.sessionVariables = {
  #   GITHUB_TOKEN = "op://Personal/GitHub Personal Access Token/credential";
  # };
  home.shellAliases = mkOpRunAliases [
    "nix-update"
    "nixpkgs-review"
  ];

  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://nix-community.github.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
  };

  # Btop, a fancy version of `top`.
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.btop.enable
  programs.btop.enable = true;

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://nix-community.github.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Visual Studio Code
  # https://code.visualstudio.com/
  # https://nix-community.github.io/home-manager/options.html#opt-programs.vscode.enable
  programs.vscode.enable = true;
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    editorconfig.editorconfig
    eamodio.gitlens
  ];

  # SSH
  # https://nix-community.github.io/home-manager/options.html#opt-programs.ssh.enable
  # Some options also set in `../darwin/homebrew.nix`.
  # programs.ssh.enable = true;
  # programs.ssh.controlPath = "~/.ssh/%C"; # ensures the path is unique but also fixed length

  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  # https://nix-community.github.io/home-manager/options.html#opt-programs.zoxide.enable
  programs.zoxide.enable = true;

  # Zsh
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
  programs.zsh.enable = true;
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.history.path = "${config.xdg.stateHome}/zsh_history";

  home.packages = attrValues (
    {
      # Some basics
      inherit (pkgs)
        abduco # lightweight session management
        bandwhich # display current network utilization by process
        bottom # fancy version of `top` with ASCII graphs
        browsh # in terminal browser
        coreutils # GNU Core Utilities
        curl
        cmake # cross-Platform Makefile Generator
        du-dust # fancy version of `du`
        eza # fancy version of `ls`
        fd # fancy version of `find`
        findutils # find, locate, updatedb, xargs
        fswatch # a file change monitor
        hyperfine # benchmarking tool
        mosh # wrapper for `ssh` that better and not dropping connections
        parallel # runs commands in parallel
        pwgen # password generator
        rdfind # find duplicate files and optionally replace them with {hard|sym}links
        ripgrep # better version of `grep`
        tealdeer # rust implementation of `tldr`
        thefuck # do what I mean on the command line
        unrar # extract RAR archives
        upterm # secure terminal sharing
        wget # get all of the things
        xz # extract XZ archives
        ;

      # Dev stuff
      inherit (pkgs)
        bundix # ruby nixified executable generator
        claude-code # Claude AI code assistant
        cloc # source code line counter
        deno
        # dotnet-sdk # Microsoft .NET SDK  TODO
        esphome # ESPHome command line tools
        # fritzing # Hardware hacking
        # ghc # Glasgow Haskell Compiler
        # git-lfs # git large file store
        # github-desktop
        # github-copilot-cli
        gnupg
        google-clasp # Google Apps Script command line tools
        google-cloud-sdk
        graphviz
        # haskell-language-server
        home-assistant-cli # Command-line tool for Home Assistant
        html-tidy
        # idris2
        jq # query json
        nodejs
        pnpm # fast, disk space efficient (nodejs) package manager
        ruby
        # R
        s3cmd
        stack
        typescript
        ;
      # inherit (pkgs.gitAndTools)
      #   gh                 # github.com command line
      # ;
      inherit (pkgs.nodePackages)
        npm-check-updates
        rollup
        # speed-test # nice speed-test tool
        yarn
      ;
      # Include Python packages using withPackages
      pythonPackages = pkgs.python3.withPackages (ps: with ps; [
        # ifcopenshell
        mypy
        numpy
        pandas
        # pandas-stubs
        pylint
        yapf
      ]);

      inherit (pkgs.lua53Packages)
        # Lua
        # busted
        # fun
        luafilesystem
        # moses
        # std-strict
        tl
      ;
      inherit (pkgs.haskellPackages)
        cabal-install
        hlint
        hoogle
        hpack
        implicit-hie
        ;
      # agda = pkgs.agda.withPackages (ps: [ ps.standard-library ]);

      # Useful nix related tools
      inherit (pkgs)
        cachix # adding/managing alternative binary caches hosted by Cachix
        comma # run software from without installing it
        nix-output-monitor # get additional information while building packages
        nix-tree # interactively browse dependency graphs of Nix derivations
        nix-update # swiss-knife for updating nix packages
        nixpkgs-review # review pull-requests on nixpkgs
        node2nix # generate Nix expressions to build NPM packages
        statix # lints and suggestions for the Nix programming language
        ;

    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      inherit (pkgs)
        cocoapods
        m-cli # useful macOS CLI commands
        prefmanager # tool for working with macOS defaults
        ;
    }
  );
}
