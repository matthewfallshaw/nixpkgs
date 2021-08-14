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
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.05-darwin";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # nixos-stable.url = "github:nixos/nixpkgs/nixos-21.05";

    # Environment/system management
    darwin.follows = "malo/darwin";
    home-manager.follows = "malo/home-manager";
    # darwin.url = "github:LnL7/nix-darwin";
    # darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.url = "github:nix-community/home-manager/release-21.05";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim plugins
    astronuta-nvim = { url = "github:tjdevries/astronauta.nvim"; flake = false; };
    bufferize-vim = { url = "github:AndrewRadev/bufferize.vim"; flake = false; };
    vim-openscad = { url = "github:sirtaj/vim-openscad"; flake = false; };
    vim-rooter = { url = "github:airblade/vim-rooter"; flake = false; };

    # Other sources
    # comma = { url = "github:Shopify/comma"; flake = false; };
    # flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
    moses-lua = { url = "github:Yonaba/Moses"; flake = false; };
    # neovim.url = "github:neovim/neovim?dir=contrib";
    # neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nvim-lspinstall = { url = "github:kabouzeid/nvim-lspinstall"; flake = false; };
    # prefmanager.url = "github:malob/prefmanager";
    # prefmanager.inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs = { self, nixpkgs, darwin, home-manager, flake-utils, malo, ... }@inputs:
  let
    # Some building blocks --------------------------------------------------------------------- {{{

    # Configuration for `nixpkgs` mostly used in personal configs.
    nixpkgsConfig = with inputs; rec {
      config = { allowUnfree = true; };
      overlays = malo.overlays ++ self.overlays ++ [
        (
          final: prev: {
            master = import nixpkgs-master { inherit (prev) system; inherit config; };
            unstable = import nixpkgs-unstable { inherit (prev) system; inherit config; };

            # Packages I want on the bleeding edge
            fish = final.unstable.fish;
            fishPlugins = final.unstable.fishPlugins;
            iterm2 = final.unstable.iterm2;
            kitty = final.unstable.kitty;
            neovim = final.unstable.neovim;
            neovim-unwrapped = final.unstable.neovim-unwrapped;
            nixUnstable = final.unstable.nixUnstable;
            vimPlugins = prev.vimPlugins // final.unstable.vimPlugins;
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
    nixDarwinCommonModules = [
      # Include extra `nix-darwin`
      malo.darwinModules.programs.nix-index
      malo.darwinModules.security.pam
      malo.darwinModules.users
      # Main `nix-darwin` config
      ./darwin
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
      })
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

      # Config with small modifications needed/desired for CI with GitHub workflow
      githubCI = darwin.lib.darwinSystem {
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
            "bufferize-vim"
            "vim-openscad"
            "vim-rooter"
            "nvim-lspinstall"
          ] (final.lib.buildVimPluginFromFlakeInput inputs) // {
            moses-nvim = final.lib.buildNeovimLuaPackagePluginFromFlakeInput inputs "moses-lua";
          };

          # Fixes for packages that don't build for some reason.
          thefuck = prev.thefuck.overrideAttrs (old: { doInstallCheck = false; });
        }
      )
      # Other overlays that don't depend on flake inputs.
    ] ++ map import ((import ./lsnix.nix) ./overlays);

    # My `nix-darwin` modules that are pending upstream, or patched versions waiting on upstream
    # fixes.
    darwinModules = {
      programs.nix-index = import ./modules/darwin/programs/nix-index.nix;
      security.pam = import ./modules/darwin/security/pam.nix;
      users = import ./modules/darwin/users.nix;
    };

    homeManagerModules = {
      configs.git.osagitfilter = import ./home/configs/git-osagitfilter.nix;
      configs.git.aliases = import ./home/configs/git-aliases.nix;
      configs.gh.aliases = import ./home/configs/gh-aliases.nix;
      configs.starship.symbols = import ./home/configs/starship-symbols.nix;
      programs.neovim.extras = import ./modules/home/programs/neovim/extras.nix;
      programs.kitty.extras = import ./modules/home/programs/kitty/extras.nix;
    };
    # }}}

    # Add re-export `nixpkgs` packages with overlays.
    # This is handy in combination with `nix registry add my /Users/matt/.config/nixpkgs`
  } // flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = import nixpkgs { inherit system; inherit (nixpkgsConfig) config overlays; };
  });
}
# vim: foldmethod=marker
