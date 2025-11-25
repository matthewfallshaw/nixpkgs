{
  config,
  pkgs,
  lib,
  ...
}:
# Let-In ----------------------------------------------------------------------------------------{{{
let
  inherit (lib)
    attrValues
    concatStringsSep
    mapAttrsToList
    optional
    removePrefix
    ;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (config.home.user-info) nixConfigDirectory;

  mkLuaTableFromList = x: "{" + lib.concatMapStringsSep "," (y: "'${y}'") x + "}";
  mkNeovimAutocmd =
    {
      event,
      pattern,
      callback ? "",
    }:
    ''
      vim.api.nvim_create_autocmd(${mkLuaTableFromList event}, {
        pattern = ${mkLuaTableFromList pattern},
        callback = ${callback},
      })
    '';
  requireConf = p: "require 'malo.${builtins.replaceStrings [ "." ] [ "-" ] p.pname}'";

  # Helper to generate "only-outside-VSCode" specs
  onlyTerminal = p: {
    use = p;
    vscode = false;
    opt = true;
  };

  completionPlugins = with pkgs.vimPlugins; [
    # dependencies first that do not themselves require 'cmp'
    (onlyTerminal lspkind-nvim)
    (onlyTerminal cmp-nvim-lsp)
    (onlyTerminal luasnip)

    # main engine
    {
      use = nvim-cmp;
      vscode = false;
      config = requireConf nvim-cmp;
    }

    # cmp sources that require the engine
    (onlyTerminal cmp-async-path)
    (onlyTerminal cmp-buffer)
    (onlyTerminal cmp-nvim-lsp-signature-help)
    (onlyTerminal cmp_luasnip)
  ];

  # Function to create `programs.neovim.plugins` entries inspired by `packer.nvim`.
  packer =
    {
      use,
      # Plugins that this plugin depends on.
      deps ? [ ],
      # Used to manually specify that the plugin shouldn't be loaded at start up.
      opt ? false,
      # Whether to load the plugin when using VS Code with `vscode-neovim`.
      vscode ? false,
      # Code to run before the plugin is loaded.
      setup ? "",
      # Code to run after the plugin is loaded.
      config ? "",
      # The following all imply lazy-loading and imply `opt = true`.
      # `FileType`s which load the plugin.
      ft ? [ ],
      # Autocommand events which load the plugin.
      event ? [ ],
    }:
    let
      loadFunctionName = "load_${
        builtins.replaceStrings
          [
            "."
            "-"
          ]
          [
            "_"
            "_"
          ]
          use.pname
      }";
      autoload = !opt && vscode && ft == [ ] && event == [ ];
      configFinal = concatStringsSep "\n" (
        optional (!autoload) "vim.cmd 'packadd ${use.pname}'" ++ optional (config != "") config
      );
    in
    {
      plugin = use.overrideAttrs (old: {
        dependencies = lib.unique (old.dependencies or [ ] ++ deps);
      });
      optional = !autoload;
      type = "lua";
      config =
        if (setup == "" && configFinal == "") then
          null
        else
          (concatStringsSep "\n" (
            [ "\n-- ${use.pname or use.name}" ]
            ++ optional (setup != "") setup

            # If the plugin isn't always loaded at startup
            ++ optional (!autoload) (
              concatStringsSep "\n" (
                [ "local ${loadFunctionName} = function()" ]
                ++ optional (!vscode) "if vim.g.vscode == nil then"
                ++ [ configFinal ]
                ++ optional (!vscode) "end"
                ++ [ "end" ]
                ++ optional (ft == [ ] && event == [ ]) "${loadFunctionName}()"
                ++ optional (ft != [ ]) (mkNeovimAutocmd {
                  event = [ "FileType" ];
                  pattern = ft;
                  callback = loadFunctionName;
                })
                ++ optional (event != [ ]) (mkNeovimAutocmd {
                  inherit event;
                  pattern = [ "*" ];
                  callback = loadFunctionName;
                })
              )
            )

            # If the plugin is always loaded at startup
            ++ optional (autoload && configFinal != "") configFinal
          ));
    };

  mkVimColorVariable = k: v: ''let g:theme_${k} = "${v}"'';
  colorSetToVimscript = colors: concatStringsSep "\n" (mapAttrsToList mkVimColorVariable colors);
in
# }}}
{
  # Neovim
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.neovim.enable
  programs.neovim.enable = true;

  # Config and plugins ------------------------------------------------------------------------- {{{

  # Put neovim configuration located in this repository into place in a way that edits to the
  # configuration don't require rebuilding the `home-manager` environment to take effect.
  xdg.configFile."nvim/plugins.vim".source =
    mkOutOfStoreSymlink "${nixConfigDirectory}/configs/nvim/plugins.vim";
  xdg.configFile."nvim/lua".source = mkOutOfStoreSymlink "${nixConfigDirectory}/configs/nvim/lua";
  xdg.configFile."nvim/colors".source =
    mkOutOfStoreSymlink "${nixConfigDirectory}/configs/nvim/colors";

  # Load the `init` module from the above configs
  programs.neovim.extraConfig = ''
    ${colorSetToVimscript config.colors.malo-ok-solar-light.colors}
    ${colorSetToVimscript config.colors.malo-ok-solar-light.namedColors}

    lua require('init')
  '';

  # Add NodeJs since it's required by some plugins I use.
  programs.neovim.withNodeJs = true;

  # Add `penlight` Lua module package since I used in the above configs
  programs.neovim.extraLuaPackages = ps: [ ps.penlight ];

  # Add plugins using my `packer` function.
  programs.neovim.plugins =
    with pkgs.vimPlugins;
    map packer (
      completionPlugins
      ++ [
        # Apperance, interface, UI, etc.
        {
          use = bufferline-nvim;
          vscode = false;
          deps = [
            nvim-web-devicons
            scope-nvim
          ];
          config = requireConf bufferline-nvim;
        }
        {
          use = galaxyline-nvim;
          vscode = false;
          deps = [ nvim-web-devicons ];
          config = requireConf galaxyline-nvim;
        }
        {
          use = gitsigns-nvim;
          vscode = false;
          config = requireConf gitsigns-nvim;
        }
        {
          use = indent-blankline-nvim;
          vscode = false;
          config = requireConf indent-blankline-nvim;
        }
        {
          use = lush-nvim;
          vscode = true;
        }
        {
          use = noice-nvim;
          vscode = false;
          deps = [
            nui-nvim
            nvim-notify
          ];
          config = requireConf noice-nvim;
        }
        {
          use = telescope-nvim;
          vscode = false;
          config = requireConf telescope-nvim;
          deps = [
            nvim-web-devicons
            telescope-file-browser-nvim
            telescope-fzf-native-nvim
            telescope_hoogle
            telescope-symbols-nvim
            telescope-zoxide
          ];
        }
        {
          use = toggleterm-nvim;
          config = requireConf toggleterm-nvim;
        }
        {
          use = zoomwintab-vim;
          opt = true;
        }

        # Completions

        # Language servers, linters, etc.
        {
          use = lsp_lines-nvim;
          vscode = false;
          config = ''
            require'lsp_lines'.setup()
            vim.diagnostic.config({ virtual_lines = { only_current_line = true } })'';
        }
        { use = haskell-tools-nvim; }
        {
          use = nvim-lspconfig;
          vscode = false;
          deps = [
            neodev-nvim
            telescope-nvim
          ];
          config = requireConf nvim-lspconfig;
        }

        # Language support/utilities
        {
          use = nvim-treesitter.withAllGrammars;
          vscode = false;
          config = requireConf nvim-treesitter;
        }
        {
          use = vim-haskell-module-name;
          vscode = true;
        }
        {
          use = vim-polyglot;
          config = requireConf vim-polyglot;
        }
        { use = vim-openscad; }

        # Editor behavior
        # { use = comment-nvim; config = "require'comment'.setup()"; }
        {
          use = editorconfig-vim;
          setup = "vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*' }";
        }
        {
          use = tabular;
          vscode = true;
        }
        {
          use = vim-surround;
          vscode = true;
        }
        {
          use = nvim-lastplace;
          config = "require'nvim-lastplace'.setup()";
        }
        {
          use = vim-pencil;
          setup = "vim.g['pencil#wrapModeDefault'] = 'soft'";
          config = "vim.fn['pencil#init'](); vim.wo.spell = true";
          ft = [
            "markdown"
            "text"
          ];
        }
        { use = lexima-vim; } # Auto close pairs
        { use = Recover-vim; }
        { use = vim-cool; } # disables search highlighting when you are done searching and re-enables it when you search again
        { use = vim-repeat; }
        { use = vim-rooter; }
        { use = vim-unimpaired; }

        # Misc
        { use = direnv-vim; }
        {
          use = vim-eunuch;
          vscode = true;
        }
        { use = vim-fugitive; }
        {
          use = which-key-nvim;
          opt = true;
        }
        { use = bufferize-vim; } # Send vim command output to a scratch buffer
      ]
    );

  # From personal addon module `../modules/home/programs/neovim/extras.nix`
  programs.neovim.extras.termBufferAutoChangeDir = true;
  programs.neovim.extras.nvrAliases.enable = true;
  programs.neovim.extras.defaultEditor = true;

  # }}}

  # Required packages -------------------------------------------------------------------------- {{{

  programs.neovim.extraPackages = attrValues {
    inherit (pkgs)
      neovim-remote

      # Language servers, linters, etc.
      # See `../configs/nvim/lua/malo/nvim-lspconfig.lua` and
      # `../configs/nvim/lua/malo/null-ls-nvim.lua` for configuration.

      # C/C++/Objective-C
      ccls

      # Bash
      bash-language-server

      # Javascript/Typescript
      typescript-language-server

      # Nix
      nil
      nixpkgs-fmt

      # Vim
      vim-language-server

      #Other
      yaml-language-server
      lua-language-server
      vscode-langservers-extracted
      ;
  };
  # }}}
}
# vim: foldmethod=marker
