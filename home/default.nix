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
  programs.fish.functions = {
    set-bat-colors = {
      body = ''set -xg BAT_THEME "Solarized ($term_background)"'';
      onVariable = "term_background";
    };
    cdd = {
      description = "cd into ~/code";
      body = ''
        set -l cdpath "$HOME/code"
        if [ -z "$argv[1]" ]
          cd $cdpath
        else
          cd $cdpath/$argv[1]
        end
      '';
    };
    cds = {
      description = "cd into ~/source";
      body = ''
        set -l cdpath "$HOME/source"
        if [ -z "$argv[1]" ]
          cd $cdpath
        else
          cd $cdpath/$argv[1]
        end
      '';
    };
    cdup = {
      description = "cd up n directories";
      body = ''
        set -l ups ""
        for i in (seq 1 $argv[1])
          set ups $ups"../"
        end
        cd $ups
      '';
    };
    mcd = {
      description = "Make a directory and cd into it";
      body = ''
        mkdir -p "$argv[1]"; and cd "$argv[1]"
      '';
    };
    mtd = {
      description = "Make a temp directory and cd into it";
      body = ''
        set -l dir (mktemp -d)
        if test -n "$dir"
          if test -d "$dir"
            echo "$dir"
            cd "$dir"
          else
            echo "mktemp directory $dir does not exist"
          end
        else
          echo "mktemp didn't work"
        end
      '';
    };
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
  programs.direnv.nix-direnv.enableFlakes = true;

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
    python3Packages.shell-functools # a collection of functional programming tools for the shell
    procs                    # fancy version of `ps`
    ripgrep                  # better version of `grep`
    tealdeer                 # rust implementation of `tldr`
    thefuck                  # do what I mean on the command line
    unrar                    # extract RAR archives
    wget                     # get all of the things
    xz                       # extract XZ archives

    # Dev stuff
    (agda.withPackages (p: [ p.standard-library ]))
    bundix                         # ruby Bundler
    cloc                           # source code line counter
    dotnet-sdk                     # Microsoft .NET SDK  TODO
    ghc                            # Glasgow Haskell Compiler
    gitAndTools.gh                 # github.com command line
    google-cloud-sdk               # Google cloud sdk
    haskell-language-server
    haskellPackages.cabal-install
    haskellPackages.hapistrano     # a deployment library for Haskell applications similar to Ruby's Capistrano
    haskellPackages.hlint          # Haskell linter
    haskellPackages.hoogle
    haskellPackages.hpack
    haskellPackages.implicit       # implicitcad.org (openscad in Haskell)
    haskellPackages.implicit-hie   # auto generate hie-bios cradles & hie.yaml
    haskellPackages.stack
    home-assistant-cli             # Command-line tool for Home Assistant
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
  home.sessionVariables = { EDITOR = "nvim"; };

  home.activation = {
    rakeDevEnvironmentBuild = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.rubyPackages.rake}/bin/rake -f ${../configs/rakefile.rb}
    '';
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    rakeDevEnvironmentBuildDarwin = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.rubyPackages.rake}/bin/rake -f ${../configs/rakefile.darwin.rb}
    '';
  };

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
  # }}}

  # This value determines the Home Manager release that your configuration is compatible with. This
  # helps avoid breakage when a new Home Manager release introduces backwards incompatible changes.
  #
  # You can update Home Manager without changing this value. See the Home Manager release notes for
  # a list of state version changes in each release.
  home.stateVersion = "21.05";
}
# vim: foldmethod=marker
