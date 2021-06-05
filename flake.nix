{
  description = "Matt’s Nix system configs.";

  inputs = {
    # Let Malo forge the new paths; I'll follow timidly behind
    malo.url = "github:malob/nixpkgs";
    # malo.inputs.nixpkgs.follows = "nixpkgs";

    # Package sets
    nixpkgs.follows = "malo/nixpkgs";
    nixpkgs-master.follows = "malo/nixpkgs-master";
    nixpkgs-unstable.follows = "malo/nixpkgs-unstable";
    nixos-stable.follows = "malo/nixos-stable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    # nixos-stable.url = "github:nixos/nixpkgs/nixos-20.09";

    # Environment/system management
    darwin.follows = "malo/darwin";
    home-manager.follows = "malo/home-manager";
    # darwin.url = "github:lnl7/nix-darwin";
    # darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim plugins
    astronuta-nvim = { url = "github:tjdevries/astronauta.nvim"; flake = false; };
    autopairs-vim = { url = "github:jiangmiao/auto-pairs"; flake = false; };
    bufferize-vim = { url = "github:AndrewRadev/bufferize.vim"; flake = false; };
    vim-openscad = { url = "github:sirtaj/vim-openscad"; flake = false; };
    vim-rooter = { url = "github:airblade/vim-rooter"; flake = false; };

    # Other sources
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, darwin, home-manager, flake-utils, malo, ... }@inputs:
  let
    # Some building blocks --------------------------------------------------------------------- {{{

    # Configuration for `nixpkgs` mostly used in personal configs.
    nixpkgsConfig = with inputs; {
      config = { allowUnfree = true; };
      overlays = malo.overlays ++ self.overlays ++ [
        (
          final: prev:
          let
            system = prev.stdenv.system;
          in {
            master = nixpkgs-master.legacyPackages.${system};
            unstable = nixpkgs-unstable.legacyPackages.${system};

            # Packages I want on the bleeding edge
            fish = final.unstable.fish;
          }
        )
      ];
    };

    # Personal configuration shared between `nix-darwin` and plain `home-manager` configs.
    homeManagerCommonConfig = {
      imports = [
        ./home
      ] ++ ( with malo.homeManagerModules; [
        configs.git.aliases
        configs.gh.aliases
        configs.starship.symbols
        programs.neovim.extras
        programs.kitty.extras
      ]) ++ ( with self.homeManagerModules; [
        configs.git.osagitfilter
      ]);
    };

    # Modules shared by most `nix-darwin` personal configurations.
    nixDarwinCommonModules = { user }: [
      # Include extra `nix-darwin`
      malo.darwinModules.programs.nix-index
      malo.darwinModules.security.pam
      # Main `nix-darwin` config
      ./darwin
      # `home-manager` module
      home-manager.darwinModules.home-manager
      {
        nixpkgs = nixpkgsConfig;
        # Hack to support legacy worklows that use `<nixpkgs>` etc.
        nix.nixPath = { nixpkgs = "$HOME/.config/nixpkgs/nixpkgs.nix"; };
        # `home-manager` config
        users.users.${user}.home = "/Users/${user}";
        home-manager.useGlobalPkgs = true;
        home-manager.users.${user} = homeManagerCommonConfig;
      }
    ];
    # }}}
  in {

    # Personal configuration ------------------------------------------------------------------- {{{

    # My `nix-darwin` configs
    darwinConfigurations = {
      # Mininal configuration to bootstrap systems
      bootstrap = darwin.lib.darwinSystem {
        modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsConfig; } ];
      };

      # My macOS main laptop config
      Notnux = darwin.lib.darwinSystem {
        modules = nixDarwinCommonModules { user = "matt"; } ++ [
          {
            networking.hostName = "Notnux";
            networking.knownNetworkServices = [
              "Wi-Fi"
              "USB 10/100/1000 LAN"
            ];
          }
        ];
      };

      # Config with small modifications needed/desired for CI with GitHub workflow
      githubCI = darwin.lib.darwinSystem {
        modules = nixDarwinCommonModules { user = "runner"; } ++ [
          ({ lib, ... }: { homebrew.enable = lib.mkForce false; })
        ];
      };
    };

    # Build and activate with `nix build .#home.activationPackage; ./result/activate`
    home = home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      stateVersion = "21.05";
      homeDirectory = "/home/matt";
      username = "matt";
      configuration = {
        imports = [ homeManagerCommonConfig ];
        nixpkgs = nixpkgsConfig;
      };
    };
    # }}}

    # Outputs useful to others ----------------------------------------------------------------- {{{

    overlays = with inputs; [
      (
        final: prev: {
          # Vim plugins
          vimPlugins = prev.vimPlugins // prev.lib.genAttrs [
            "astronuta-nvim"
            "autopairs-vim"
            "bufferize-vim"
            "vim-openscad"
            "vim-rooter"
          ] (final.lib.buildVimPluginFromFlakeInput inputs);
        }
      )
      # Other overlays that don't depend on flake inputs.
    ] ++ map import ((import ./lsnix.nix) ./overlays);
    # }}}

    homeManagerModules = {
      configs.git.osagitfilter = import ./home/configs/git-osagitfilter.nix;
    };

    # Add re-export `nixpkgs` packages with overlays.
    # This is handy in combination with `nix registry add my /Users/matt/.config/nixpkgs`
  } // flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = import nixpkgs { inherit system; inherit (nixpkgsConfig) config overlays; };
  });
}
# vim: foldmethod=marker
