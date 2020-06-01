self: super:
let
  # Get sha256 by running nix-prefetch-url --unpack https://github.com/[owner]/[name]/archive/[rev].tar.gz
  customVimPlugins = with super.vimUtils; {
    bufferize-vim = buildVimPluginFrom2Nix {
      name = "bufferize-vim";
      src  = super.fetchFromGitHub {
        owner  = "AndrewRadev";
        repo   = "bufferize.vim";
        rev    = "2f72cbd";
        sha256 = "1fkw1zmp04fadx0d85p2w3nzm4ca2sfnv1db6ljcnj5ldjajmaz7";
      };
    };
    vim-cool = buildVimPluginFrom2Nix {
      name = "vim-cool";
      src  = super.fetchFromGitHub {
        owner  = "romainl";
        repo   = "vim-cool";
        rev    = "6dcd594";
        sha256 = "099sbjdk944bnivqgqgbjplczfm3k84583ryrmpqf3lgrq6pl8wr";
      };
    };
    vim-dispatch-neovim = buildVimPluginFrom2Nix {
      name = "vim-dispatch-neovim";
      src  = super.fetchFromGitHub {
        owner  = "radenling";
        repo   = "vim-dispatch-neovim";
        rev    = "c8c4e21";
        sha256 = "111n3f7lv9nkpj200xh0fwbi3scjqyivpw5fwdjdyiqzd6qabxml";
      };
    };
    vim-haskell-module-name = buildVimPluginFrom2Nix {
      name = "vim-haskell-module-name";
      src  = super.fetchFromGitHub {
        owner  = "chkno";
        repo   = "vim-haskell-module-name";
        rev    = "6dcd594";
        sha256 = "126p0i4mw1f9nmzh96yxymaizja5vbl6z9k1y3zqhxq9nglgdvxb";
      };
    };
    vim-openscad = buildVimPluginFrom2Nix {
      name = "vim-openscad";
      src  = super.fetchFromGitHub {
        owner  = "sirtaj";
        repo   = "vim-openscad";
        rev    = "2ac407d";
        sha256 = "099sbjdk944bnivqgqgbjplczfm3k84583ryrmpqf3lgrq6pl8wr";
      };
    vim-rooter = buildVimPluginFrom2Nix {
      name = "vim-rooter";
      src  = super.fetchFromGitHub {
        owner  = "airblade";
        repo   = "vim-rooter";
        rev    = "8a0a201";
        sha256 = "1r8kzzljs39ycc6jjh5anpl2gw73c2wb1bs8hjv6xnw1scln6gwq";
      };
    };
    };
    # Needed until PR lands in unstable channel
    # my-coc-nvim = buildVimPluginFrom2Nix rec {
    #   pname = "coc-nvim";
    #   version = "0.0.73";
    #   src = super.fetchFromGitHub {
    #     owner = "neoclide";
    #     repo = "coc.nvim";
    #     rev = "v${version}";
    #     sha256 = "1z7573rbh806nmkh75hr1kbhxr4jysv6k9x01fcyjfwricpa3cf7";
    #   };
    # };
  };
in {
  myNeovim = self.pkgs.release-beta.neovim.override {
    configure = {
      customRC = ''
        source $HOME/.config/nixpkgs/configs/nvim/init.vim
      '';
      packages.myVimPackages = with self.pkgs.unstable.vimPlugins // customVimPlugins; {
        start = [
          # UI plugins
          airline
          NeoSolarized
          vim-airline-themes
          vim-choosewin
          vim-devicons
          vim-startify

          # other plugins
          ale
          coc-nvim
          goyo-vim
          Recover-vim
          tabular
          targets-vim
          bufferize-vim
          vim-commentary
          vim-cool
          vim-dispatch
          vim-dispatch-neovim
          vim-eunuch
          vim-fugitive
          vim-haskell-module-name
          vim-openscad
          vim-pencil
          vim-polyglot
          vim-repeat
          vim-rooter
          vim-surround
          vim-unimpaired
          yats-vim
        ];
      };
    };
  };

  myNeovimEnv = super.buildEnv {
    name = "NeovimEnv";
    paths = with self.pkgs; [
      neovim-remote
      myNeovim
    ];
  };
}
