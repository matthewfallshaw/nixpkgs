{
  description = "Matt’s Nix system configs.";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-20.09";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim plugins
    vim-openscad = { url = "github:sirtaj/vim-openscad"; flake = false; };
    nvim-luapad = { url = "github:rafcamlet/nvim-luapad"; flake = false; };
    bufferize-vim = { url = "github:AndrewRadev/bufferize.vim"; flake = false; };

    # Other sources
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
    malo.url = "github:malob/nixpkgs";
    malo.inputs.nixpkgs.follows = "nixpkgs";
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
            nixpkgs-stable = if system == "x86_64-darwin" then nixpkgs-stable-darwin else nixos-stable;
          in {
            master = nixpkgs-master.legacyPackages.${system};
            stable = nixpkgs-stable.legacyPackages.${system};
          }
        )
      ];
    };

    # Personal configuration shared between `nix-darwin` and plain `home-manager` configs.
    homeManagerCommonConfig = with self.homeManagerModules; {
      imports = [
        ./home
        malo.homeManagerModules.configs.git.aliases
        malo.homeManagerModules.configs.gh.aliases
        configs.git.osagitfilter
        malo.homeManagerModules.configs.starship.symbols
        malo.homeManagerModules.programs.neovim.extras
        malo.homeManagerModules.programs.kitty.extras
      ];
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
            "vim-openscad"
            "nvim-luapad"
            "bufferize-vim"
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
