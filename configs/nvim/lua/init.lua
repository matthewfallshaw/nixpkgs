package.path = package.path ..
    ";" .. os.getenv("HOME") .. "/.nix-profile/share/lua/5.3/?.lua" ..
    ";" .. os.getenv("HOME") .. "/.nix-profile/share/lua/5.3/?/init.lua"

-- Add my personal helpers
local utils = require 'malo.utils'
local augroup = utils.augroup
local keymaps = utils.keymaps

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


-- Non-nix Config ---------------------------------------------------------------------------- {{{
-- Plugins
vim.api.nvim_command('source ~/.config/nvim/plugins.vim')
-- }}}

-- Neovide or VSCode Config ------------------------------------------------------------------- {{{
if g.neovide then
  o.guifont = 'JetBrainsMono Nerd Font:h11'
  g.neovide_input_use_logo = true
  g.neovide_cursor_animation_length = 0.01
  g.neovide_cursor_trail_size = 0.4
end
if g.neovide or g.vscode then
  -- Common key mappings for Neovide and VSCode
  api.nvim_set_keymap('', '<D-v>', '"+p', { noremap = true, silent = false })
  api.nvim_set_keymap('!', '<D-v>', '"+gP', { noremap = true, silent = false })
  api.nvim_set_keymap('t', '<D-v>', '"+p', { noremap = true, silent = false })
  api.nvim_set_keymap('v', '<D-c>', '"+y', { noremap = true, silent = false })

  api.nvim_set_keymap('', '<D-s>', ':w<CR>', { noremap = true, silent = false })
end
if g.vscode then
  -- Disable visual features that VSCode handles
  wo.number = false
  wo.relativenumber = false
  wo.cursorline = false
  wo.colorcolumn = ''
  wo.signcolumn = 'no'

  -- Disable treesitter highlighting in VSCode
  vim.g.loaded_treesitter = 1

  -- Disable certain features that might conflict
  vim.g.loaded_indent_blankline = 1

  -- Prevent theme-related issues
  o.termguicolors = false

  -- Disable diagnostic virtual lines if they're enabled
  vim.diagnostic.config({ virtual_lines = false })

  -- VSCode handles scrolling
  vim.opt.sidescroll = 0
  vim.opt.sidescrolloff = 0
  vim.opt.wrap = false
end
-- }}}

-- Basic Vim Config --------------------------------------------------------------------------------

o.scrolloff   = 10   -- start scrolling when cursor is within 5 lines of the edge
o.linebreak   = true -- soft wraps on words not individual chars
o.mouse       = 'a'  -- enable mouse support in all modes
o.updatetime  = 300
o.autochdir   = true
o.exrc        = true -- allow project specific config in .nvimrc or .exrc files
o.foldenable  = false

-- Search and replace
o.ignorecase  = true      -- make searches with lower case characters case insensitive
o.smartcase   = true      -- search is case sensitive only if it contains uppercase chars
o.inccommand  = 'nosplit' -- show preview in buffer while doing find and replace

-- Tab key behavior
o.expandtab   = true      -- Convert tabs to spaces
o.tabstop     = 2         -- How many columns of whitespace is a \t worth
o.shiftwidth  = o.tabstop -- How many columns of whitespace is a level of indentation worth
o.softtabstop = o.tabstop -- How many columns of whitespace is a keypress worth

-- Set where splits open
o.splitbelow  = true -- open horizontal splits below instead of above which is the default
o.splitright  = true -- open vertical splits to the right instead of the left with is the default

-- Some basic autocommands
if g.vscode == nil then
  augroup { name = 'VimBasics', cmds = {
    { { 'BufEnter', 'FocusGained', 'CursorHold', 'CursorHoldI' }, {
      pattern = '*',
      desc = 'Check if file has changed on disk, if it has and buffer has no changes, reload it.',
      command = 'checktime',
    } },
    { 'BufWritePre', {
      pattern = '*',
      desc = 'Remove trailing whitespace before write.',
      command = [[%s/\s\+$//e]],
    } },
    { 'TextYankPost', {
      pattern = '*',
      desc = 'Highlight yanked text.',
      callback = function() vim.highlight.on_yank { higroup = 'Search', timeout = 150 } end,
    } },
  } }
end


-- UI ----------------------------------------------------------------------------------------------

-- Set UI related options
o.termguicolors   = true
o.showmode        = false                        -- don't show -- INSERT -- etc.
wo.colorcolumn    = '100'                        -- show column border
wo.number         = true                         -- display numberline
wo.relativenumber = true                         -- relative line numbers
wo.cursorline     = true                         -- highlight current line
wo.cursorlineopt  = 'number'                     -- only highlight the number of the cursorline
wo.signcolumn     = 'yes'                        -- always have signcolumn open to avoid thing shifting around all the time
o.fillchars       = 'stl: ,stlnc: ,vert:·,eob: ' -- No '~' on lines after end of file, other stuff

-- Set colorscheme
if g.vscode == nil then
  require 'malo.theme'.extraLushSpecs = {
    'lush_theme.malo.bufferline-nvim',
    'lush_theme.malo.statusline',
    'lush_theme.malo.telescope-nvim',
  }
  cmd 'colorscheme malo'
end


-- Terminal ----------------------------------------------------------------------------------------

augroup { name = 'NeovimTerm', cmds = {
  { 'TermOpen', {
    pattern = '*',
    desc = 'Set options for terminal buffers.',
    command = 'setlocal nonumber | setlocal norelativenumber | setlocal signcolumn=no',
  } },
} }

-- Leader only used for this one case
g.mapleader = ','
keymaps { modes = 't', opts = { noremap = true }, maps = {
  -- Enter normal mode in terminal using `<ESC>` like everywhere else.
  { '<ESC>',         [[<C-\><C-n>]] },
  -- Sometimes you want to send `<ESC>` to the terminal though.
  { '<leader><ESC>', '<ESC>' },
} }

-- WhichKey maps -----------------------------------------------------------------------------------

-- Define all `<Space>` prefixed keymaps with which-key.nvim
-- https://github.com/folke/which-key.nvim
cmd 'packadd which-key.nvim'
cmd 'packadd! gitsigns.nvim' -- needed for some mappings
local wk = require 'which-key'
wk.setup { plugins = { spelling = { enabled = true } } }

-- Space-prefixed mappings in Normal mode
wk.add({

  -- Toggle floating terminal
  { '  ',   '<Cmd>exe v:count1 . "ToggleTerm"<CR>',                                                                                         desc = "Toggle floating terminal" },

  -- Tabs
  { ' t',   group = "Tabs" },
  { ' tn',  '<Cmd>tabnew +term<CR>',                                                                                                        desc = 'New with terminal' },
  { ' to',  '<Cmd>tabonly<CR>',                                                                                                             desc = 'Close all other' },
  { ' tq',  '<Cmd>tabclose<CR>',                                                                                                            desc = 'Close' },
  { ' tl',  '<Cmd>tabnext<CR>',                                                                                                             desc = 'Next' },
  { ' th',  '<Cmd>tabprevious<CR>',                                                                                                         desc = 'Previous' },

  -- Windows/Splits
  { ' -',   '<Cmd>new +term<CR>',                                                                                                           desc = 'New terminal below' },
  { ' _',   '<Cmd>botright new +term<CR>',                                                                                                  desc = 'New terminal below (full-width)' },
  { ' \\',  '<Cmd>vnew +term<CR>',                                                                                                          desc = 'New terminal right' },
  { ' |',   '<Cmd>botright vnew +term<CR>',                                                                                                 desc = 'New terminal right (full-height)' },

  { ' w',   group = "Windows" },
  -- Split creation
  { ' ws',  '<Cmd>split<CR>',                                                                                                               desc = 'Split below' },
  { ' wv',  '<Cmd>vsplit<CR>',                                                                                                              desc = 'Split right' },
  { ' wq',  '<Cmd>q<CR>',                                                                                                                   desc = 'Close' },
  { ' wo',  '<Cmd>only<CR>',                                                                                                                desc = 'Close all other' },
  -- Navigation
  { ' wk',  '<Cmd>wincmd k<CR>',                                                                                                            desc = 'Go up' },
  { ' wj',  '<Cmd>wincmd j<CR>',                                                                                                            desc = 'Go down' },
  { ' wh',  '<Cmd>wincmd h<CR>',                                                                                                            desc = 'Go left' },
  { ' wl',  '<Cmd>wincmd l<CR>',                                                                                                            desc = 'Go right' },
  { ' ww',  '<Cmd>wincmd w<CR>',                                                                                                            desc = 'Go down/right' },
  { ' wW',  '<Cmd>wincmd W<CR>',                                                                                                            desc = 'Go up/left' },
  { ' wt',  '<Cmd>wincmd t<CR>',                                                                                                            desc = 'Go top-left' },
  { ' wb',  '<Cmd>wincmd b<CR>',                                                                                                            desc = 'Go bottom-right' },
  { ' wp',  '<Cmd>wincmd p<CR>',                                                                                                            desc = 'Go to previous' },
  -- Movement
  { ' wK',  '<Cmd>wincmd K<CR>',                                                                                                            desc = 'Move to top' },
  { ' wJ',  '<Cmd>wincmd J<CR>',                                                                                                            desc = 'Move to bottom' },
  { ' wH',  '<Cmd>wincmd H<CR>',                                                                                                            desc = 'Move to left' },
  { ' wL',  '<Cmd>wincmd L<CR>',                                                                                                            desc = 'Move to right' },
  { ' wT',  '<Cmd>wincmd T<CR>',                                                                                                            desc = 'Move to new tab' },
  { ' wr',  '<Cmd>wincmd r<CR>',                                                                                                            desc = 'Rotate clockwise' },
  { ' wR',  '<Cmd>wincmd R<CR>',                                                                                                            desc = 'Rotate counter-clockwise' },
  { ' wz',  '<Cmd>packadd zoomwintab.vim | ZoomWinTabToggle<CR>',                                                                           desc = 'Toggle zoom' },
  -- Resize
  { ' w=',  '<Cmd>wincmd =<CR>',                                                                                                            desc = 'All equal size' },
  { ' w-',  '<Cmd>resize -5<CR>',                                                                                                           desc = 'Decrease height' },
  { ' w+',  '<Cmd>resize +5<CR>',                                                                                                           desc = 'Increase height' },
  { ' w<',  '<Cmd><C-w>5<<CR>',                                                                                                             desc = 'Decrease width' },
  { ' w>',  '<Cmd><C-w>5><CR>',                                                                                                             desc = 'Increase width' },
  { ' w|',  '<Cmd>vertical resize 106<CR>',                                                                                                 desc = 'Full line-length' },

  -- Git
  { ' g',   group = "Git" },
  { ' gb',  '<Cmd>Gblame<CR>',                                                                                                              desc = 'Blame' },
  { ' gs',  '<Cmd>Git<CR>',                                                                                                                 desc = 'Status' },
  -- Git Diff
  { ' gd',  group = '+Diff' },
  { ' gds', '<Cmd>Ghdiffsplit<CR>',                                                                                                         desc = 'Split horizontal' },
  { ' gdv', '<Cmd>Gvdiffsplit<CR>',                                                                                                         desc = 'Split vertical' },
  -- Git Hunks
  { ' gh',  group = '+Hunks' },
  { ' ghs', require 'gitsigns'.stage_hunk,                                                                                                  desc = 'Stage' },
  { ' ghu', require 'gitsigns'.undo_stage_hunk,                                                                                             desc = 'Undo stage' },
  { ' ghr', require 'gitsigns'.reset_hunk,                                                                                                  desc = 'Reset' },
  { ' ghn', require 'gitsigns'.next_hunk,                                                                                                   desc = 'Go to next' },
  { ' ghN', require 'gitsigns'.prev_hunk,                                                                                                   desc = 'Go to prev' },
  { ' ghp', require 'gitsigns'.preview_hunk,                                                                                                desc = 'Preview' },
  -- Git Lists
  { ' gl',  group = '+Lists' },
  { ' gls', '<Cmd>Telescope git_status<CR>',                                                                                                desc = 'Status' },
  { ' glc', '<Cmd>Telescope git_commits<CR>',                                                                                               desc = 'Commits' },
  { ' glC', '<Cmd>Telescope git_bcommits<CR>',                                                                                              desc = 'Buffer commits' },
  { ' glb', '<Cmd>Telescope git_branches<CR>',                                                                                              desc = 'Branches' },
  -- Other Git
  { ' gv',  '<Cmd>!gh repo view --web<CR>',                                                                                                 desc = 'View on GitHub' },

  -- LSP
  { ' l',   group = '+LSP' },
  { ' lh',  vim.lsp.buf.hover,                                                                                                              desc = 'Hover' },
  { ' ld',  vim.lsp.buf.definition,                                                                                                         desc = 'Jump to definition' },
  { ' lD',  vim.lsp.buf.declaration,                                                                                                        desc = 'Jump to declaration' },
  { ' lca', vim.lsp.buf.code_action,                                                                                                        desc = 'Code action' },
  { ' lcl', vim.lsp.codelens.run,                                                                                                           desc = 'Code lens' },
  { ' lf',  vim.lsp.buf.format,                                                                                                             desc = 'Format' },
  { ' lr',  vim.lsp.buf.rename,                                                                                                             desc = 'Rename' },
  { ' lt',  vim.lsp.buf.type_definition,                                                                                                    desc = 'Jump to type definition' },
  { ' ln',  function() vim.diagnostic.goto_next({ float = false }) end,                                                                     desc = 'Jump to next diagnostic' },
  { ' lN',  function() vim.diagnostic.goto_prev({ float = false }) end,                                                                     desc = 'Jump to previous diagnostic' },
  -- LSP Lists
  { ' ll',  group = '+Lists' },
  { ' lla', '<Cmd>Telescope lsp_code_actions<CR>',                                                                                          desc = 'Code actions' },
  { ' llA', '<Cmd>Telescope lsp_range_code_actions<CR>',                                                                                    desc = 'Code actions (range)' },
  { ' llr', '<Cmd>Telescope lsp_references<CR>',                                                                                            desc = 'References' },
  { ' lls', '<Cmd>Telescope lsp_document_symbols<CR>',                                                                                      desc = 'Document symbols' },
  { ' llS', '<Cmd>Telescope lsp_workspace_symbols<CR>',                                                                                     desc = 'Workspace symbols' },

  -- Searching with telescope.nvim
  { ' s',   group = '+Search' },
  { ' sb',  '<Cmd>Telescope file_browser<CR>',                                                                                              desc = 'File Browser' },
  { ' sf',  '<Cmd>Telescope find_files_workspace<CR>',                                                                                      desc = 'Files in workspace' },
  { ' sF',  '<Cmd>Telescope find_files<CR>',                                                                                                desc = 'Files in cwd' },
  { ' sg',  '<Cmd>Telescope live_grep_workspace<CR>',                                                                                       desc = 'Grep in workspace' },
  { ' sG',  '<Cmd>Telescope live_grep<CR>',                                                                                                 desc = 'Grep in cwd' },
  { ' sl',  '<Cmd>Telescope current_buffer_fuzzy_find<CR>',                                                                                 desc = 'Buffer lines' },
  { ' so',  '<Cmd>Telescope oldfiles<CR>',                                                                                                  desc = 'Old files' },
  { ' st',  '<Cmd>Telescope builtin<CR>',                                                                                                   desc = 'Telescope lists' },
  { ' sw',  '<Cmd>Telescope grep_string_workspace<CR>',                                                                                     desc = 'Grep word in workspace' },
  { ' sW',  '<Cmd>Telescope grep_string<CR>',                                                                                               desc = 'Grep word in cwd' },
  -- Telescope Vim
  { ' sv',  group = '+Vim' },
  { ' sva', '<Cmd>Telescope autocommands<CR>',                                                                                              desc = 'Autocommands' },
  { ' svb', '<Cmd>Telescope buffers<CR>',                                                                                                   desc = 'Buffers' },
  { ' svc', '<Cmd>Telescope commands<CR>',                                                                                                  desc = 'Commands' },
  { ' svC', '<Cmd>Telescope command_history<CR>',                                                                                           desc = 'Command history' },
  { ' svh', '<Cmd>Telescope highlights<CR>',                                                                                                desc = 'Highlights' },
  { ' svq', '<Cmd>Telescope quickfix<CR>',                                                                                                  desc = 'Quickfix list' },
  { ' svl', '<Cmd>Telescope loclist<CR>',                                                                                                   desc = 'Location list' },
  { ' svm', '<Cmd>Telescope keymaps<CR>',                                                                                                   desc = 'Keymaps' },
  { ' svs', '<Cmd>Telescope spell_suggest<CR>',                                                                                             desc = 'Spell suggest' },
  { ' svo', '<Cmd>Telescope vim_options<CR>',                                                                                               desc = 'Options' },
  { ' svr', '<Cmd>Telescope registers<CR>',                                                                                                 desc = 'Registers' },
  { ' svt', '<Cmd>Telescope filetypes<CR>',                                                                                                 desc = 'Filetypes' },
  -- Other searches
  { ' ss',  function() require 'telescope.builtin'.symbols(require 'telescope.themes'.get_dropdown({ sources = { 'emoji', 'math' } })) end, desc = 'Symbols' },
  { ' sz',  '<Cmd>Telescope zoxide list<CR>',                                                                                               desc = 'Z' },
  { ' s?',  '<Cmd>Telescope help_tags<CR>',                                                                                                 desc = 'Vim help' },
})

-- Visual mode mappings
wk.add({
  { ' la', vim.lsp.buf.range_code_action, desc = 'Code action (range)', mode = 'v' },
})

-- Misc ---------------------------------------------------------------------------------------- {{{

-- vim-commentary
-- Comment stuff out (easily)
-- https://github.com/tpope/vim-commentary
keymaps { modes = 'n', opts = {}, maps = {
  { '<leader>c', 'gcc' },
} }
keymaps { modes = 'v', opts = {}, maps = {
  { '<leader>c', 'gc' },
} }

-- lexima.vim
-- Auto close pairs
-- https://github.com/cohama/lexima.vim
g.lexima_enable_basic_rules   = 1
g.lexima_enable_newline_rules = 1
g.lexima_enable_endwise_rules = 1
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
g.rooter_change_directory_for_non_project_files = 'current'
g.rooter_cd_cmd                                 = 'lcd' -- change directory for the current window only
g.rooter_resolve_links                          = 1     -- resolve symbolic links
g.rooter_patterns                               = { '.git'
, '.git/'
, 'Makefile'
, 'Rakefile'
, 'package.json'
, 'manifest.json'
, 'tsconfig.json'
, 'package.yaml'
, 'stack.yaml'
, '.root'
}

-- }}}

-- Custom mappings ------------------------------------------------------------------------------- {{{
keymaps { modes = 'c', opts = { noremap = true }, maps = {
  -- Moving around in the command window
  { '<C-A>', '<Home>' },
  { '<C-E>', '<End>' },
} }
keymaps { modes = 'i', opts = {}, maps = {
  -- New line below, above
  { '<S-CR>', '<ESC>o' },
  { '<C-CR>', '<ESC>O' },
} }
keymaps { modes = 'n', opts = { noremap = true }, maps = {
  -- Substitute the word under the cursor
  { '<leader>s', [[:%s/\C\<<C-r><C-w>\>//gc<Left><Left><Left>]] },
} }
keymaps { modes = 'v', opts = { noremap = true }, maps = {
  -- Substitute the visually selected word
  { '<leader>s', [[y:%s/\C\<<C-r>"\>//gc<Left><Left><Left>]] },
} }

-- }}}
