{ lib, pkgs, ... }:

{
  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
  };

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  # Visual Studio Code
  # https://code.visualstudio.com/
  # https://nix-community.github.io/home-manager/options.html#opt-programs.vscode.enable
  programs.vscode.enable = true;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    editorconfig.editorconfig
    eamodio.gitlens
  ];

  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.zoxide.enable
  programs.zoxide.enable = true;

  home.packages = lib.attrValues ({
    # Some basics
    inherit (pkgs)
      abduco               # lightweight session management
      bottom               # fancy version of `top` with ASCII graphs
      browsh               # in terminal browser
      cmake                # cross-Platform Makefile Generator
      coreutils            # GNU Core Utilities
      curl
      du-dust              # fancy version of `du`
      eza                  # fancy version of `ls`
      fd                   # fancy version of `find`
      findutils            # find, locate, updatedb, xargs
      fswatch              # a file change monitor
      htop                 # fancy version of `top`
      hyperfine            # benchmarking tool
      mosh                 # wrapper for `ssh`; better and does not drop connections
      parallel             # runs commands in parallel
      pwgen                # password generator
      procs                # fancy version of `ps`
      rdfind               # find duplicate files and optionally replace them with {hard|sym}links
      ripgrep              # better version of `grep`
      smartmontools
      tealdeer             # rust implementation of `tldr`
      thefuck              # do what I mean on the command line
      unrar                # extract RAR archives
      wget                 # get all of the things
      xz                   # extract XZ archives
    ;

    # Dev stuff
    inherit (pkgs)
      bundix                         # ruby nixified executable generator
      cloc                           # source code line counter
      dotnet-sdk                     # Microsoft .NET SDK  TODO
      # fritzing # Hardware hacking
      ghc                            # Glasgow Haskell Compiler
      git-lfs                        # git large file store
      # github-desktop
      google-clasp
      google-cloud-sdk               # Google cloud sdk
      # haskell-language-server
      home-assistant-cli             # Command-line tool for Home Assistant
      html-tidy
      jq                             # query json
      nodejs
      ruby
      # R
      s3cmd
      stack
      typescript
    ;

    inherit (pkgs.gitAndTools)
      gh                 # github.com command line
    ;

    inherit (pkgs.nodePackages)
      npm-check-updates
      rollup
      speed-test                 # nice speed-test tool
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
      # ghcup
      # hapistrano          # a deployment library for Haskell applications similar to Ruby's Capistrano
      hlint                 # Haskell linter
      # hls-hlint-plugin
      hoogle
      hpack
      implicit              # implicitcad.org (openscad in Haskell)
      implicit-hie
    ;

    agda = pkgs.agda.withPackages (ps: [ ps.standard-library ]);

    # Useful nix related tools
    inherit (pkgs)
      cachix             # adding/managing alternative binary caches hosted by Cachix
      comma              # run software from without installing it
      niv                # easy dependency management for nix projects
      nix-output-monitor # get additional information while building packages
      nix-tree           # interactively browse dependency graphs of Nix derivations
      nix-update         # swiss-knife for updating nix packages
      nixpkgs-review     # review pull-requests on nixpkgs
      node2nix           # generate Nix expressions to build NPM packages
      statix             # lints and suggestions for the Nix programming language
    ;

  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    inherit (pkgs)
      cocoapods   # dependency manager for Swift and Objective-C Cocoa projects
      m-cli       # useful macOS CLI commands
      prefmanager # tool for working with macOS defaults
    ;
  });
}
# vim: foldmethod=marker
