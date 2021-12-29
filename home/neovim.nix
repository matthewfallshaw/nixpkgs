{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf optional;
  nvr = "${pkgs.neovim-remote}/bin/nvr";

  pluginWithDeps = plugin: deps: plugin.overrideAttrs (_: { dependencies = deps; });

  nonVSCodePluginWithConfig = plugin: {
    plugin = plugin;
    optional = true;
    config = ''
      if !exists('g:vscode')
        lua require('malo.' .. string.gsub('${plugin.pname}', '%.', '-'))
      endif
    '';
  };

  nonVSCodePlugin = plugin: {
    plugin = plugin;
    optional = true;
    config = ''if !exists('g:vscode') | packadd ${plugin.pname} | endif'';
  };
in

{
  # Neovim
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.neovim.enable
  programs.neovim.enable = true;

  # Config and plugins ------------------------------------------------------------------------- {{{

  # Minimal init.vim config to load Lua config. Nix and Home Manager don't currently support
  # `init.lua`.
  xdg.configFile."nvim/lua" = {
    source = ../configs/nvim/lua;
    recursive = true;
  };
  xdg.configFile."nvim/colors" = {
    source = ../configs/nvim/colors;
    recursive = true;
  };
  xdg.configFile."nvim/after" = {
    source = ../configs/nvim/after;
    recursive = true;
  };
  programs.neovim.extraConfig = "lua require('init')";

  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Lua ftplugins
    astronuta-nvim
    # Send vim command output to a scratch buffer
    bufferize-vim
    # Auto close pairs
    lexima-vim
    # Colorscheme creation aid
    lush-nvim
    # Luarocks moses only in nvim (deletion candidate)
    moses-nvim
    # Interactive lua scratchpad
    # nvim-luapad
    # plenary-nvim       # required for telescope-nvim and gitsigns.nvim
    # popup-nvim         # required for telescope-nvim
    Recover-vim
    tabular
    vim-commentary
    vim-cool
    vim-eunuch
    vim-haskell-module-name
    vim-openscad
    vim-repeat
    vim-rooter
    vim-surround
    vim-unimpaired
  ] ++ map (p: { plugin = p; optional = true; }) [
    # barbar-nvim
    # completion-buffers
    # completion-nvim
    # completion-tabnine
    telescope-symbols-nvim
    telescope-z-nvim
    which-key-nvim
    zoomwintab-vim
  ] ++ map nonVSCodePlugin [
    # Agda programming language
    agda-vim
    # Support direnv shell contexts
    direnv-vim
    # Distraction free writing environment
    goyo-vim
    vim-fugitive
  ] ++ map nonVSCodePluginWithConfig [
    # Support .editorconfig files
    editorconfig-vim
    (pluginWithDeps galaxyline-nvim [ nvim-web-devicons ])
    gitsigns-nvim
    indent-blankline-nvim
    lspsaga-nvim
    (pluginWithDeps bufferline-nvim [ nvim-web-devicons ])
    (pluginWithDeps nvim-compe [ compe-tabnine ])
    # Common configs for nvim LSP
    nvim-lspconfig
    nvim-treesitter
    (pluginWithDeps telescope-nvim [ nvim-web-devicons ])
    vim-floaterm
    vim-pencil
    vim-polyglot
  ];
  # }}}

  # Shell related ------------------------------------------------------------------------------ {{{

  # From personal addon module `./modules/programs/neovim/extras.nix`
  programs.neovim.extras.termBufferAutoChangeDir = true;
  programs.neovim.extras.nvrAliases.enable = true;

  programs.fish.functions.set-nvim-background = mkIf config.programs.neovim.enable {
    # See `./shells.nix` for more on how this is used.
    body = ''
      # Set `background` of all running Neovim instances base on `$term_background`.
      for server in (${nvr} --serverlist)
        ${nvr} -s --nostart --servername $server -c "set background=$term_background" &
      end
    '';
    onVariable = "term_background";
  };

  programs.fish.interactiveShellInit = mkIf config.programs.neovim.enable ''
    # Run Neovim related functions on init for their effects, and to register them so they are
    # triggered when the relevant event happens or variable changes.
    set-nvim-background
  '';
  # }}}

  # Required packages -------------------------------------------------------------------------- {{{

  programs.neovim.extraPackages = with pkgs; [
    neovim-remote
    gcc         # needed for nvim-treesitter
    tree-sitter # needed for nvim-treesitter

    # Language servers
    # See `../configs/nvim/lua/init.lua` for configuration.
    # ccls
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    nodePackages.vim-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server
    rnix-lsp
  ] ++ optional (pkgs.stdenv.system != "x86_64-darwin") sumneko-lua-language-server;
  # }}}
}
# vim: foldmethod=marker
