self: super: {

  # Update custom packages
  nixuser-update-mypkgs = super.writeShellScriptBin "nixuser-update-mypkgs" ''
    pushd ~/.config/nixpkgs/pkgs/node-packages
    printf "\nUpdating Node package nix expressions ...\n"
    ${self.pkgs.unstable.nodePackages.node2nix}/bin/node2nix --nodejs-10 -i node-packages.json
    popd
    pushd ~/.config/nixpkgs/pkgs/ruby-gems/
    printf "\nUpdating Ruby Gems nix expressions ...\n"
    ${super.pkgs.bundix}/bin/bundix --magic
    popd
    pushd ~/.config/nixpkgs/pkgs/python-packages
    printf "\nUpdating Python package nix expressions ...\n"
    ${super.pkgs.unstable.pypi2nix}/bin/pypi2nix --python-version python36 --requirements requirements.txt
    popd
  '';

  # Collect garbage, optimize store, repair paths
  nix-cleanup-store = super.writeShellScriptBin "nix-cleanup" ''
    nix-collect-garbage -d
    nix optimise-store 2>&1 | sed -E 's/.*'\'''(\/nix\/store\/[^\/]*).*'\'''/\1/g' | uniq | sudo ${super.pkgs.parallel}/bin/parallel 'nix-store --repair-path {}'
  '';

  myCommonEnv = super.buildEnv {
    name = "CommonEnv";
    paths = with self.pkgs; [
      # Some basics
      coreutils
      curl
      findutils
      unstable.fish-foreign-env        # needed for fish-shell for non-NixOS installations
      graphviz                         # `dot` and other graph visualization tools
      imagemagick                      # bitmap image tools
      jq                               # command line JSON processor
      moreutils
      multimarkdown                    # extended markdown derivative
      parallel                         # runs commands in parallel
      pwgen                            # password generator
      ripgrep                          # better version of grep
      s3cmd                            # utility for interacting with AWS S3
      thefuck                          # suggests fixes to commands that exit with a non-zero status
      tldr                             # simple man pages, mostly examples of how to use commands
      tree                             # a depth indented directory listing
      unrar                            # extract RAR archives
      wget
      xz                               # extract XZ archives

      # General dev stuff
      google-clasp
      google-cloud-sdk
      nodejs-12_x
      unstable.nodePackages.serverless

      # Haskell
      (all-hies.unstableFallback.selection { selector = p: { inherit (p) ghc882 ghc881 ghc865; }; })
      unstable.cabal-install
      haskellPackages.hoogle
      haskellPackages.hpack
      unstable.stack

      # Language servers, linters, etc.
      unstable.ccls
      unstable.nodePackages.bash-language-server
      unstable.nodePackages.typescript
      vim-vint
      watchman
      python37Packages.flake8
      python37Packages.pycodestyle
      python37Packages.pyflakes
      python37Packages.pylint

      # My wrapped and config derivations
      myGitEnv    # includes diff-so-fancy and hub
      myKitty     # my prefered terminal
      myNeovimEnv # includes neovim-remote

      # Useful nix related tools
      bundix                          # working with Ruby projects
      cachix                          # adding/managing atternative binary caches hosted by Cachix
      unstable.nodePackages.node2nix  # working with Node projects
      unstable.pypi2nix               # working with Python projects

      # My custom nix related shell scripts
      nixuser-update-mypkgs
      nix-cleanup-store
    ];
  };
}
