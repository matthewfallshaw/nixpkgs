package.path = package.path ..
  ";" .. os.getenv("HOME") .. "/.nix-profile/share/lua/5.3/?.lua" ..
  ";" .. os.getenv("HOME") .. "/.nix-profile/share/lua/5.3/?/init.lua"

-- Add my personal helpers
local utils = require 'malo.utils'
local augroup = utils.augroup
local keymap = utils.keymap
local keymaps = utils.keymaps
local bufkeymaps = utils.bufkeymaps
local s = utils.symbols
local _ = require 'moses'

-- Add some aliases for Neovim Lua API
local o = vim.o
local wo = vim.wo
local g = vim.g
local cmd = vim.cmd
local env = vim.env
local api = vim.api

-- TODO --------------------------------------------------------------------------------------------

-- - Flesh out custom colorscheme
--   - Revisit Pmenu highlights:
--   - Experiment with `Diff` highlights to look more like `delta`'s output.
--   - Set `g:terminal_color` values.
--   - Decide on whether I want to include a bunch of language specific highlights
--   - Figure out what to do with `tree-sitter` highlights.
--   - Stretch
--     - Add more highlights for plugins I use, and other popular plugins.
--     - Create monotone variant, where one base color is supplied, and all colors are generate
--       based on transformations of that colors.
-- - Make tweaks to custom status line
--   - Find a way to dynamically display current LSP status/progress/messages.
--   - See if there's an easy way to show show Git sections when in terminal buffer.
--   - Revamp conditions for when segments are displayed
--   - A bunch of other small tweaks.
-- - List searching with telescope.nvim.
--   - Improve workspace folder detection on my telescope.nvim extensions
-- - Other
--   - Figure out how to get Lua LSP to be aware Nvim plugins. Why aren't they on `package.path`?
--   - Play around with `tree-sitter`.
--   - Look into replacing floaterm-vim with vim-toggleterm.lua.


-- Non-nix Config ---------------------------------------------------------------------------- {{{
-- Plugins
vim.api.nvim_command('source ~/.config/nvim/plugins.vim')
-- }}}

-- Basic Vim Config --------------------------------------------------------------------------------

o.scrolloff  = 10   -- start scrolling when cursor is within 5 lines of the ledge
o.linebreak  = true -- soft wraps on words not individual chars
o.mouse      = 'a'  -- enable mouse support in all modes
o.updatetime = 300
o.autochdir  = true
o.foldenable = false

-- Search and replace
o.ignorecase = true      -- make searches with lower case characters case insensative
o.smartcase  = true      -- search is case sensitive only if it contains uppercase chars
o.inccommand = 'nosplit' -- show preview in buffer while doing find and replace

-- Tab key behavior
o.expandtab   = true      -- Convert tabs to spaces
o.tabstop     = 2         -- How many columns of whitespace is a \t worth
o.shiftwidth  = o.tabstop -- How many columns of whitespace is a level of indentation worth
o.softtabstop = o.tabstop -- How many columns of whitespace is a keypress worth

-- Set where splits open
o.splitbelow = true -- open horizontal splits below instead of above which is the default
o.splitright = true -- open vertical splits to the right instead of the left with is the default

-- Some basic autocommands
if g.vscode == nil then
  augroup { name = 'VimBasics', cmds = {
    -- Check if file has changed on disk, if it has and buffer has no changes, reload it
    { 'BufEnter,FocusGained,CursorHold,CursorHoldI', '*', 'checktime' },
    -- Remove trailing whitespace before write
    { 'BufWritePre', '*', [[%s/\s\+$//e]] },
    -- Highlight yanked text
    { 'TextYankPost', '*', [[silent! lua vim.highlight.on_yank {higroup='Search', timeout=150}]] },
  }}
end


-- UI ----------------------------------------------------------------------------------------------

-- Set UI related options
o.termguicolors   = true
o.showmode        = false -- don't show -- INSERT -- etc.
wo.colorcolumn    = '100' -- show column boarder
wo.cursorline     = true  -- highlight current line
wo.number         = true  -- display numberline
wo.relativenumber = true  -- relative line numbers
wo.signcolumn     = 'yes' -- always have signcolumn open to avoid thing shifting around all the time
o.fillchars       = 'stl: ,stlnc: ,vert:·,eob: ' -- No '~' on lines after end of file, other stuff

-- Set colorscheme
require'malo.theme'.extraLushSpecs = {
  'lush_theme.malo.nvim-bufferline-lua',
  'lush_theme.malo.statusline',
  'lush_theme.malo.telescope-nvim',
}
cmd 'colorscheme malo'


-- Terminal ----------------------------------------------------------------------------------------

augroup { name = 'NeovimTerm', cmds = {
  -- Set options for terminal buffers
  { 'TermOpen', '*', 'setlocal nonumber | setlocal norelativenumber | setlocal signcolumn=no' },
}}

-- Leader only used for this one case
g.mapleader = ','
keymaps { mode = 't', opts = { 'noremap' }, maps = {
  -- Enter normal mode in terminal using `<ESC>` like everywhere else.
  { '<ESC>', [[<C-\><C-n>]] },
  -- Sometimes you want to send `<ESC>` to the terminal though.
  { '<leader><ESC>', '<ESC>' },
}}


-- WhichKey maps -----------------------------------------------------------------------------------

-- Define all `<Space>` prefixed keymaps with which-key.nvim
-- https://github.com/folke/which-key.nvim
cmd 'packadd which-key-nvim'
cmd 'packadd! gitsigns-nvim' -- needed for some mappings
local wk = require 'which-key'
wk.setup { plugins = { spelling = { enabled = true } } }

-- Spaced prefiexd in Normal mode
wk.register ({
  [' '] = { '<Cmd>packadd vim-floaterm | FloatermToggle<CR>', 'Toggle floating terminal' },

  -- Tabs
  t = {
    name = '+Tabs',
    n = { '<Cmd>tabnew +term<CR>'  , 'New with terminal' },
    o = { '<Cmd>tabonly<CR>'       , 'Close all other'   },
    q = { '<Cmd>tabclose<CR>'      , 'Close'             },
    l = { '<Cmd>tabnext<CR>'       , 'Next'              },
    h = { '<Cmd>tabprevious<CR>'   , 'Previous'          },
  },

  -- Windows/splits
  ['-']  = { '<Cmd>new +term<CR>'           , 'New terminal below'               },
  ['_']  = { '<Cmd>botright new +term<CR>'  , 'New termimal below (full-width)'  },
  ['\\'] = { '<Cmd>vnew +term<CR>'          , 'New terminal right'               },
  ['|']  = { '<Cmd>botright vnew +term<CR>' , 'New termimal right (full-height)' },
  w = {
    name = '+Windows',
    -- Split creation
    s = { '<Cmd>split<CR>'  , 'Split below'     },
    v = { '<Cmd>vsplit<CR>' , 'Split right'     },
    q = { '<Cmd>q<CR>'      , 'Close'           },
    o = { '<Cmd>only<CR>'   , 'Close all other' },
    -- Navigation
    k = { '<Cmd>wincmd k<CR>' , 'Go up'           },
    j = { '<Cmd>wincmd j<CR>' , 'Go down'         },
    h = { '<Cmd>wincmd h<CR>' , 'Go left'         },
    l = { '<Cmd>wincmd l<CR>' , 'Go right'        },
    w = { '<Cmd>wincmd w<CR>' , 'Go down/right'   },
    W = { '<Cmd>wincmd W<CR>' , 'Go up/left'      },
    t = { '<Cmd>wincmd t<CR>' , 'Go top-left'     },
    b = { '<Cmd>wincmd b<CR>' , 'Go bottom-right' },
    p = { '<Cmd>wincmd p<CR>' , 'Go to previous'  },
    -- Movement
    K = { '<Cmd>wincmd k<CR>' , 'Move to top'              },
    J = { '<Cmd>wincmd J<CR>' , 'Move to bottom'           },
    H = { '<Cmd>wincmd H<CR>' , 'Move to left'             },
    L = { '<Cmd>wincmd L<CR>' , 'Move to right'            },
    T = { '<Cmd>wincmd T<CR>' , 'Move to new tab'          },
    r = { '<Cmd>wincmd r<CR>' , 'Rotate clockwise'         },
    R = { '<Cmd>wincmd R<CR>' , 'Rotate counter-clockwise' },
    z = { '<Cmd>packadd zoomwintab-vim | ZoomWinTabToggle<CR>', 'Toggle zoom' },
    -- Resize
    ['='] = { '<Cmd>wincmd =<CR>'            , 'All equal size'   },
    ['-'] = { '<Cmd>resize -5<CR>'           , 'Decrease height'  },
    ['+'] = { '<Cmd>resize +5<CR>'           , 'Increase height'  },
    ['<'] = { '<Cmd><C-w>5<<CR>'             , 'Decrease width'   },
    ['>'] = { '<Cmd><C-w>5><CR>'             , 'Increase width'   },
    ['|'] = { '<Cmd>vertical resize 106<CR>' , 'Full line-lenght' },
  },

  -- Git
  g = {
    name = '+Git',
    -- vim-fugitive
    b = { '<Cmd>Gblame<CR>' , 'Blame'  },
    s = { '<Cmd>Git<CR>'    , 'Status' },
    d = {
      name = '+Diff',
      s = { '<Cmd>Ghdiffsplit<CR>' , 'Split horizontal' },
      v = { '<Cmd>Gvdiffsplit<CR>' , 'Split vertical'   },
    },
    -- gitsigns.nvim
    h = {
      name = '+Hunks',
      s = { require'gitsigns'.stage_hunk      , 'Stage'      },
      u = { require'gitsigns'.undo_stage_hunk , 'Undo stage' },
      r = { require'gitsigns'.reset_hunk      , 'Reset'      },
      n = { require'gitsigns'.next_hunk       , 'Go to next' },
      N = { require'gitsigns'.prev_hunk       , 'Go to prev' },
      p = { require'gitsigns'.preview_hunk    , 'Preview'    },
    },
    -- telescope.nvim lists
    l = {
      name = '+Lists',
      s = { '<Cmd>Telescope git_status<CR>'  , 'Status'         },
      c = { '<Cmd>Telescope git_commits<CR>' , 'Commits'        },
      C = { '<Cmd>Telescope git_commits<CR>' , 'Buffer commits' },
      b = { '<Cmd>Telescope git_branches<CR>' , 'Branches'       },
    },
    -- Other
    v = { '<Cmd>!gh repo view --web<CR>' , 'View on GitHub' },
  },

  -- Language server
  l = {
    name = '+LSP',
    h = { '<Cmd>Lspsaga hover_doc<CR>'            , 'Hover'                   },
    d = { vim.lsp.buf.definition                  , 'Jump to definition'      },
    D = { vim.lsp.buf.declaration                 , 'Jump to declaration'     },
    a = { '<Cmd>Lspsaga code_action<CR>'          , 'Code action'             },
    f = { vim.lsp.buf.formatting                  , 'Format'                  },
    r = { '<Cmd>Lspsaga rename<CR>'               , 'Rename'                  },
    t = { vim.lsp.buf.type_definition             , 'Jump to type definition' },
    n = { '<Cmd>Lspsaga diagnostic_jump_next<CR>' , 'Jump to next diagnostic' },
    N = { '<Cmd>Lspsaga diagnostic_jump_prev<CR>' , 'Jump to prev diagnostic' },
    l = {
      name = '+Lists',
      a = { '<Cmd>Telescope lsp_code_actions<CR>'       , 'Code actions'         },
      A = { '<Cmd>Telescope lsp_range_code_actions<CR>' , 'Code actions (range)' },
      r = { '<Cmd>Telescope lsp_references<CR>'         , 'References'           },
      s = { '<Cmd>Telescope lsp_document_symbols<CR>'   , 'Documents symbols'    },
      S = { '<Cmd>Telescope lsp_workspace_symbols<CR>'  , 'Workspace symbols'    },
    },
  },

  -- Seaching with telescope.nvim
  s = {
    name = '+Search',
    b = { '<Cmd>Telescope file_browser<CR>'              , 'File Browser'           },
    f = { '<Cmd>Telescope find_files_workspace<CR>'      , 'Files in workspace'     },
    F = { '<Cmd>Telescope find_files<CR>'                , 'Files in cwd'           },
    g = { '<Cmd>Telescope live_grep_workspace<CR>'       , 'Grep in workspace'      },
    G = { '<Cmd>Telescope live_grep<CR>'                 , 'Grep in cwd'            },
    l = { '<Cmd>Telescope current_buffer_fuzzy_find<CR>' , 'Buffer lines'           },
    o = { '<Cmd>Telescope oldfiles<CR>'                  , 'Old files'              },
    t = { '<Cmd>Telescope builtin<CR>'                   , 'Telescope lists'        },
    w = { '<Cmd>Telescope grep_string_workspace<CR>'     , 'Grep word in workspace' },
    W = { '<Cmd>Telescope grep_string<CR>'               , 'Grep word in cwd'       },
    v = {
      name = '+Vim',
      a = { '<Cmd>Telescope autocommands<CR>'    , 'Autocommands'    },
      b = { '<Cmd>Telescope buffers<CR>'         , 'Buffers'         },
      c = { '<Cmd>Telescope commands<CR>'        , 'Commands'        },
      C = { '<Cmd>Telescope command_history<CR>' , 'Command history' },
      h = { '<Cmd>Telescope highlights<CR>'      , 'Highlights'      },
      q = { '<Cmd>Telescope quickfix<CR>'        , 'Quickfix list'   },
      l = { '<Cmd>Telescope loclist<CR>'         , 'Location list'   },
      m = { '<Cmd>Telescope keymaps<CR>'         , 'Keymaps'         },
      s = { '<Cmd>Telescope spell_suggest<CR>'   , 'Spell suggest'   },
      o = { '<Cmd>Telescope vim_options<CR>'     , 'Options'         },
      r = { '<Cmd>Telescope registers<CR>'       , 'Registers'       },
      t = { '<Cmd>Telescope filetypes<CR>'       , 'Filetypes'       },
    },
    s = { function() require'telescope.builtin'.symbols(require'telescope.themes'.get_dropdown({sources = {'emoji', 'math'}})) end, 'Symbols' },
    z = { function() require'telescope'.extensions.z.list({cmd = {'fish', '-c', 'zq -ls'}}) end, 'Z' },
    ['?'] = { '<Cmd>Telescope help_tags<CR>', 'Vim help' },
  }

}, { prefix = ' ' })

-- Spaced prefiexd in mode Visual mode
wk.register ({
  l = {
    name = '+LSP',
    a = { ':<C-U>Lspsaga range_code_action<CR>' , 'Code action (range)' , mode = 'v' },
  },
}, { prefix = ' ' })


-- Misc ---------------------------------------------------------------------------------------- {{{

-- vim-commentary
-- Comment stuff out (easily)
-- https://github.com/tpope/vim-commentary
keymaps { mode = 'n', opts = {}, maps = {
  { '<leader>c', 'gcc' },
}}
keymaps { mode = 'v', opts = {}, maps = {
  { '<leader>c', 'gc' },
}}

-- lexima.vim
-- Auto close pairs
-- https://github.com/cohama/lexima.vim
_.each( { lexima_enable_basic_rules   = 1
        , lexima_enable_newline_rules = 1
        , lexima_enable_endwise_rules = 1
        }
      , function(v, k) vim.api.nvim_set_var(k, v) end)
--[[
call lexima#add_rule({'char': '$', 'input_after': '$', 'filetype': 'latex'})
call lexima#add_rule({'char': '$', 'at': '\%#\$', 'leave': 1, 'filetype': 'latex'})
call lexima#add_rule({'char': '<BS>', 'at': '\$\%#\$', 'delete': 1, 'filetype': 'latex'})
--]]

-- vim-surround
-- Quoting/parenthesizing made simple
-- https://github.com/tpope/vim-surround

-- vim-rooter
-- for non-project files/directories, change to file's directory (similar to autochdir).
_.each( { rooter_change_directory_for_non_project_files = 'current'
        , rooter_cd_cmd                                 = 'lcd'      -- change directory for the current window only
        , rooter_resolve_links                          = 1          -- resolve symbolic links
        , rooter_patterns = { '.git'
                            , '.git/'
                            , 'Makefile'
                            , 'Rakefile'
                            , 'package.json'
                            , 'manifest.json'
                            , 'tsconfig.json'
                            , 'package.yaml'
                            , 'stack.yaml'
                            , '.root' }
        }
  , function(v, k) api.nvim_set_var(k, v) end
  )


-- }}}

-- Custom mappings ------------------------------------------------------------------------------- {{{
keymaps { mode = 'c', opts = { 'noremap' }, maps = {
  -- Moving around in the command window
  { '<C-A>', '<Home>' },
  { '<C-E>', '<End>' },
}}
keymaps { mode = 'i', opts = {}, maps = {
  -- New line below, above
  { '<S-CR>', '<ESC>o' },
  { '<C-CR>', '<ESC>O' },
}}
keymaps { mode = 'n', opts = { 'noremap' }, maps = {
  -- Substitute the word under the cursor
  { '<leader>s', [[:%s/\C\<<C-r><C-w>\>//gc<Left><Left><Left>]] },
}}
keymaps { mode = 'v', opts = { 'noremap' }, maps = {
  -- Subsititute the visually selected word
  { '<leader>s', [[y:%s/\C\<<C-r>"\>//gc<Left><Left><Left>]] },
}}

-- }}}
