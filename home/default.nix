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
    body = ''set -xg BAT_THEME ansi-"$term_background"'';
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
  programs.direnv.enableNixDirenvIntegration = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.zoxide.enable
  programs.zoxide.enable = true;
  # }}}

  # Other packages ----------------------------------------------------------------------------- {{{

  home.packages = with pkgs; [
    # Some basics
    abduco                   # lightweight session management
    # bandwhich                # display current network utilization by process
    bottom                   # fancy version of `top` with ASCII graphs
    browsh                   # in terminal browser
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
    pwgen                    # password generator
    procs                    # fancy version of `ps`
    ripgrep                  # better version of `grep`
    tealdeer                 # rust implementation of `tldr`
    thefuck                  # do what I mean on the command line
    unrar                    # extract RAR archives
    wget                     # get all of the things
    xz                       # extract XZ archives

    # Dev stuff
    (agda.withPackages (p: [ p.standard-library ]))
    bundler                        # ruby Bundler
    cloc                           # source code line counter
    ghc                            # Glasgow Haskell Compiler
    gitAndTools.gh                 # github.com command line
    google-cloud-sdk               # Google cloud sdk
    haskell-language-server
    haskellPackages.cabal-install
    haskellPackages.hoogle
    haskellPackages.hpack
    haskellPackages.implicit       # implicitcad.org (openscad in Haskell)
    haskellPackages.implicit-hie   # auto generate hie-bios cradles & hie.yaml
    haskellPackages.stack
    idris2                         # a purely functional programming language with first class types
    jq                             # query json
    nodePackages.typescript
    nodejs
    (python3.withPackages (p: with p; [
      mypy
      pylint
      yapf
    ]))
    s3cmd
    tickgit                        # view pending tasks, progress reports, completion summaries
                                   # and historical data (using git history)

    # Lua
    lua53Packages.busted
    lua53Packages.fun
    lua53Packages.std-strict
    lua53Packages.moses

    # Useful nix related tools
    cachix                          # adding/managing alternative binary caches hosted by Cachix
    comma                           # run software from without installing it
    lorri                           # improve `nix-shell` experience in combination with `direnv`
    niv                             # easy dependency management for nix projects
    nodePackages.node2nix

  ] ++ lib.optionals stdenv.isDarwin [
    m-cli          # useful macOS CLI commands
    # prefmanager    # tool for working with macOS defaults
  ];

  # }}}

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" "${config.home.homeDirectory}/bin" ];

  home.activation = {
    rakeDevEnvironmentBuild = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.rubyPackages.rake}/bin/rake -f ${../configs/rakefile.rb}
    '';
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    rakeDevEnvironmentBuildDarwin = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.rubyPackages.rake}/bin/rake -f ${../configs/rakefile.darwin.rb}
    '';
  };

  # This value determines the Home Manager release that your configuration is compatible with. This
  # helps avoid breakage when a new Home Manager release introduces backwards incompatible changes.
  #
  # You can update Home Manager without changing this value. See the Home Manager release notes for
  # a list of state version changes in each release.
  home.stateVersion = "21.05";
}
# vim: foldmethod=marker
