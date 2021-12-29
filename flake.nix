{
  description = "Matt’s Nix system configs.";

  inputs = {
    # Let Malo forge the new paths; I'll follow timidly behind
    malo.url = "github:malob/nixpkgs";

    # Package sets
    nixpkgs-master.follows = "malo/nixpkgs-master";
    nixpkgs-stable.follows = "malo/nixpkgs-stable";
    nixpkgs-unstable.follows = "malo/nixpkgs-unstable";
    nixos-stable.follows = "malo/nixos-stable";

    # Environment/system management
    darwin.follows = "malo/darwin";
    home-manager.follows = "malo/home-manager";

    # Neovim plugins
    astronuta-nvim = { url = "github:tjdevries/astronauta.nvim"; flake = false; };
    bufferize-vim = { url = "github:AndrewRadev/bufferize.vim"; flake = false; };
    vim-openscad = { url = "github:sirtaj/vim-openscad"; flake = false; };
    vim-rooter = { url = "github:airblade/vim-rooter"; flake = false; };

    # Other sources
    flake-utils.follows = "malo/flake-utils";
  };


  outputs = { self, darwin, home-manager, flake-utils, malo, ... }@inputs:
  let
    # Some building blocks --------------------------------------------------------------------- {{{

    inherit (darwin.lib) darwinSystem;
    inherit (inputs.nixpkgs-unstable.lib) attrValues optionalAttrs singleton;

    # Configuration for `nixpkgs` mostly used in personal configs.
    nixpkgsConfig = with inputs; rec {
      config = { allowUnfree = true; };
      overlays = attrValues malo.overlays ++ attrValues self.overlays ++ singleton (
        # Sub in x86 version of packages that don't build on Apple Silicon yet
        final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          inherit (final.pkgs-x86)
            home-assistant-cli
            idris2
            nix-index
            niv;
        })
      );
    };

    # Personal configuration shared between `nix-darwin` and plain `home-manager` configs.
    homeManagerStateVersion = "22.05";
    homeManagerCommonConfig = {
      imports = attrValues malo.homeManagerModules ++ attrValues self.homeManagerModules ++ [
        ./home
        { home.stateVersion = homeManagerStateVersion; }
      ];
    };

    # Modules shared by most `nix-darwin` personal configurations.
    nixDarwinCommonModules = attrValues malo.darwinModules ++ [
      # Main `nix-darwin` config
      ./darwin
      (import "${malo}/darwin/bootstrap.nix")
      # `home-manager` module
      home-manager.darwinModules.home-manager
      ( { config, lib, ... }: let inherit (config.users) primaryUser; in {
        nixpkgs = nixpkgsConfig;
        # Hack to support legacy worklows that use `<nixpkgs>` etc.
        nix.nixPath = { nixpkgs = "$HOME/.config/nixpkgs/nixpkgs.nix"; };
        # `home-manager` config
        users.users.${primaryUser}.home = "/Users/${primaryUser}";
        home-manager.useGlobalPkgs = true;
        home-manager.users.${primaryUser} = homeManagerCommonConfig;
        # Add a registry entry for this flake
        nix.registry.my.flake = self;
      })
    ];
    # }}}
  in {

    # Personal configuration ------------------------------------------------------------------- {{{

    # My `nix-darwin` configs
    darwinConfigurations = {
      # Mininal configuration to bootstrap systems
      inherit (malo.darwinConfigurations) bootstrap-x86 bootstrap-arm;

      # My macOS main laptop config
      Notnux = darwinSystem {
        system = "x86_64-darwin";
        modules = nixDarwinCommonModules ++ [
          {
            users.primaryUser = "matt";
            networking.computerName = "notnux5";
            networking.hostName = "Notnux";
            networking.knownNetworkServices = [
              "Wi-Fi"
              "USB 10/100/1000 LAN"
            ];
          }
        ];
      };

      NotnuxM1 = darwinSystem {
        system = "aarch64-darwin";
        modules = nixDarwinCommonModules ++ [
          {
            users.primaryUser = "matt";
            networking.computerName = "notnux5-M1";
            networking.hostName = "NotnuxM1";
            networking.knownNetworkServices = [
              "Wi-Fi"
              "USB 10/100/1000 LAN"
            ];
          }
        ];
      };

      # Config with small modifications needed/desired for CI with GitHub workflow
      githubCI = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = nixDarwinCommonModules ++ [
          ({ lib, ... }: {
            users.primaryUser = "runner";
            homebrew.enable = lib.mkForce false;
          })
        ];
      };
    };

    # Build and activate with `nix build .#home.activationPackage; ./result/activate`
    home = home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      stateVersion = homeManagerStateVersion;
      homeDirectory = "/home/matt";
      username = "matt";
      configuration = {
        imports = [ homeManagerCommonConfig ];
        nixpkgs = nixpkgsConfig;
      };
    };
    # }}}

    # Outputs useful to others ----------------------------------------------------------------- {{{

    overlays = {
      vimPlugins = final: prev:
        let
          inherit (malo.overlays.vimUtils final prev) vimUtils;
        in
        {
          vimPlugins = prev.vimPlugins.extend (super: self:
            (vimUtils.buildVimPluginsFromFlakeInputs inputs [
              "astronuta-nvim"
              "bufferize-vim"
              "vim-openscad"
              "vim-rooter"
            ])
          );
        };

      lua53Packages = import ./overlays/lua.nix;
    };

    homeManagerModules = {
      configs-osagitfilter = import ./home/configs/git-osagitfilter.nix;
    };
    # }}}

  } // flake-utils.lib.eachDefaultSystem (system: {
    legacyPackages = import inputs.nixpkgs-unstable {
      inherit system;
      inherit (nixpkgsConfig) config;
      overlays = with malo.overlays; [
        pkgs-master
        pkgs-stable
        apple-silicon
      ];
    };
  });

}
# vim: foldmethod=marker
