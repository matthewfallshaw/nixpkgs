{ config, pkgs, lib, ... }:

{
  # Import config broken out into files
  imports = [
    ./git.nix
    ./kitty.nix
    ./neovim.nix
    ./shells.nix
  ];

  # Packages with configuration --------------------------------------------------------------- {{{

  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
  };
  # See `./shells.nix` for more on how this is used.
  programs.fish.functions.set-bat-colors = {
    body = ''set -xg BAT_THEME "Solarized ($term_background)"'';
    onVariable = "term_background";
  };
  programs.fish.interactiveShellInit = ''
    # Set `bat` colors based on value of `$term_backdround` when shell starts up.
    set-bat-colors
  '';

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.zoxide.enable
  programs.zoxide.enable = true;

  # Visual Studio Code
  # https://code.visualstudio.com/
  # https://nix-community.github.io/home-manager/options.html#opt-programs.vscode.enable
  programs.vscode.enable = true;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    editorconfig.editorconfig
    eamodio.gitlens
  ];
  # }}}

  # Other packages ----------------------------------------------------------------------------- {{{

  home.packages = with pkgs; [
    # Some basics
    abduco                   # lightweight session management
    # bandwhich                # display current network utilization by process
    bottom                   # fancy version of `top` with ASCII graphs
    browsh                   # in terminal browser
    cmake                    # cross-Platform Makefile Generator
    coreutils                # GNU Core Utilities
    curl                     #
    du-dust                  # fancy version of `du`
    exa                      # fancy version of `ls`
    fd                       # fancy version of `find`
    findutils                # find, locate, updatedb, xargs
    fswatch                  # a file change monitor
    htop                     # fancy version of `top`
    hyperfine                # benchmarking tool
    mosh                     # wrapper for `ssh`; better and does not drop connections
    nodePackages.speed-test  # nice speed-test tool
    parallel                 # runs commands in parallel
    perl534Packages.vidir    # a great way to bulk edit filenames
    pwgen                    # password generator
    procs                    # fancy version of `ps`
    rdfind                   # find duplicate files and optionally replace them with {hard|sym}links
    ripgrep                  # better version of `grep`
    smartmontools            #
    tealdeer                 # rust implementation of `tldr`
    thefuck                  # do what I mean on the command line
    unrar                    # extract RAR archives
    wget                     # get all of the things
    xz                       # extract XZ archives

    # Dev stuff
    bundix                         # ruby nixified executable generator
    cloc                           # source code line counter
    cocoapods                      # dependency manager for Swift and Objective-C Cocoa projects
    dotnet-sdk                     # Microsoft .NET SDK  TODO
    ghc                            # Glasgow Haskell Compiler
    gitAndTools.gh                 # github.com command line
    # github-desktop
    git-lfs                        # git large file store
    google-cloud-sdk               # Google cloud sdk
    haskellPackages.cabal-install
    # haskellPackages.ghcup
    # haskellPackages.hapistrano     # a deployment library for Haskell applications similar to Ruby's Capistrano
    haskellPackages.hlint          # Haskell linter
    haskellPackages.hls-hlint-plugin
    haskellPackages.hoogle
    haskellPackages.hpack
    haskellPackages.implicit       # implicitcad.org (openscad in Haskell)
    haskellPackages.implicit-hie   # auto generate hie-bios cradles & hie.yaml
    stack
    # haskell-language-server
    home-assistant-cli             # Command-line tool for Home Assistant
    html-tidy
    idris2                         # a purely functional programming language with first class types
    jq                             # query json
    nodePackages.typescript
    nodePackages.npm-check-updates
    nodePackages.rollup
    nodePackages.yarn
    nodejs
    (python3.withPackages (p: with p; [
      mypy
      numpy
      pandas
      pandas-stubs
      pylint
      yapf
    ]))
    # R
    ruby
    s3cmd

    # Lua
    # lua53Packages.busted
    # lua53Packages.fun
    lua53Packages.luafilesystem
    # lua53Packages.moses
    # lua53Packages.std-strict

    # Hardware hacking
    # fritzing

    # Useful nix related tools
    cachix                          # adding/managing alternative binary caches hosted by Cachix
    # comma                           # run software from without installing it
    lorri                           # improve `nix-shell` experience in combination with `direnv`
    niv                             # easy dependency management for nix projects
    nodePackages.node2nix
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli          # useful macOS CLI commands
    prefmanager    # tool for working with macOS defaults
  ];
  # }}}

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" "${config.home.homeDirectory}/bin" ];
  home.sessionVariables = { EDITOR = "nvim"; };

#  home.activation = {
#    rakeDevEnvironmentBuild = lib.hm.dag.entryAfter ["writeBoundary"] ''
#      ${pkgs.rubyPackages.rake}/bin/rake -f ${../configs/rakefile.rb}
#    '';
#  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
#    rakeDevEnvironmentBuildDarwin = lib.hm.dag.entryAfter ["writeBoundary"] ''
#      ${pkgs.rubyPackages.rake}/bin/rake -f ${../configs/rakefile.darwin.rb}
#    '';
#  };

  # Misc configuration files --------------------------------------------------------------------{{{

  # https://docs.haskellstack.org/en/stable/yaml_configuration/#non-project-specific-config
  home.file.".stack/config.yaml".text = lib.generators.toYAML {} {
    templates = {
      scm-init = "git";
      params = {
        author-name = config.programs.git.userName;
        author-email = config.programs.git.userEmail;
        github-username = "matthewfallshaw";
        copyright = "MIT";
      };
    };
    nix.enable = true;
  };

  # Stop `parallel` from displaying citation warning
  home.file.".parallel/will-cite".text = "";
  # }}}
}
# vim: foldmethod=marker
