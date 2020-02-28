scriptencoding=utf-8

" Comments and Context {{{
" ====================
"
" Keyboard shortcut philosophy:
" * Don't change default shortcuts unless there a consistent model for the change.
" * Use <space> prefixed shortcuts are for commands that don't fit nicely into Vim's shortcut grammar.
"   * Avoid single key shortcuts. Have the first key be some mnemonic for what the command does.
"   * <space>l for language server related commands.
"   * <space>w for split/window related commands.
"   * <space>s for search (CocList) related commands.
"   * <space>t for tab related commands.
"   * <space>q for quit/close related commands.
"   * <space>g for git related commands.
" }}}

" Basic Vim Config {{{
" ================

let mapleader = ','
let timeouttlen = 1500 " extend time-out on leader key
set scrolloff=5        " start scrolling when cursor is within 5 lines of the edge
set linebreak          " soft wraps on words not individual chars
set mouse=a            " enable mouse support in all modes
" set autochdir
set nofoldenable       " disable folding

" Search and replace
set ignorecase         " make searches with lower case characters case insensative
set smartcase          " search is case sensitive only if it contains uppercase chars
set inccommand=nosplit " show preview in buffer while doing find and replace
set incsearch       " while typing a search, show matches
set hlsearch        " show search matches

" Tab key behavior
set expandtab 	 " Convert tabs to spaces
set tabstop=2    " Width of tab character
set shiftwidth=2 " Width of auto-indents

" Check if file has changed on disk, if it has and buffer has no changes, reload it
augroup checktime
  au!
  au BufEnter,FocusGained,CursorHold,CursorHoldI * checktime
augroup END

" Function to create mappings in all modes
function! Anoremap(arg, lhs, rhs)
  for map_command in ['noremap', 'noremap!', 'tnoremap']
    execute map_command a:arg a:lhs a:rhs
  endfor
endfunction

" python
let g:python_host_prog = glob('~').'/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = glob('~').'/.pyenv/versions/neovim3/bin/python'

" Restore cursor position
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

set exrc   " searching the current directory for a .vimrc file and load it

" }}}

" UI General {{{
" ==========

" Misc basic vim ui config
set colorcolumn=100 " show column boarder
set cursorline      " highlight current line
set noshowmode      " don't show --INSERT-- etc.
set number          " … with absolute line number on current line
set relativenumber  " relative line numbers
set signcolumn=yes  " always have signcolumn open to avoid thing shifting around all the time
set termguicolors   " truecolor support

" Setup color scheme
" https://github.com/icymind/NeoSolarized
let g:neosolarized_italic           = 1 " enable italics (must come before colorcheme command)
let g:neosolarized_termBoldAsBright = 0 " don't change color of text when bolded in terminal
colorscheme NeoSolarized                " version of solarized that works better with truecolors
hi! link SignColumn Normal

" Variables for symbol used in config
let error_symbol      = ''
let warning_symbol    = ''
let info_symbol       = ''

let ibar_symbol       = ''
let git_branch_symbol = ''
let list_symbol       = ''
let lock_symbol       = ''
let pencil_symbol     = ''
let question_symbol   = ''
let spinner_symbol    = ''
let term_symbol       = ''
let vim_symbol        = ''
let wand_symbol       = ''
" }}}

" UI Status Line {{{
" ==============
" https://github.com/vim-airline/vim-airline

" General configuration
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]' " only show unusual file encoding
let g:airline#extensions#hunks#non_zero_only   = 1             " only git stats when there are changes
let g:airline_skip_empty_sections              = 1             " don't show sections if they're empty
let g:airline_extensions =
\ [ 'ale'
\ , 'branch'
\ , 'coc'
\ , 'fugitiveline'
\ , 'keymap'
\ , 'netrw'
\ , 'quickfix'
\ , 'tabline'
\ , 'whitespace'
\ , 'wordcount'
\ ]

" Tabline configuration
"let g:airline#extensions#tabline#enabled           = 1 " needed since it isn't on by default
let g:airline#extensions#tabline#show_tabs         = 1 " always show tabs in tabline
let g:airline#extensions#tabline#show_buffers      = 0 " don't show buffers in tabline
let g:airline#extensions#tabline#show_splits       = 0 " don't number of splits
let g:airline#extensions#tabline#tab_nr_type       = 2 " tabs show [tab num].[num of splits in tab]
let g:airline#extensions#tabline#show_tab_type     = 0 " don't show tab or buffer labels in bar
let g:airline#extensions#tabline#show_close_button = 0 " don't display close button in top right

" Cutomtomize symbols
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_symbols.branch    = git_branch_symbol
let g:airline_symbols.readonly  = lock_symbol
let g:airline_symbols.notexists = question_symbol
let g:airline_symbols.dirty     = pencil_symbol
let g:airline_mode_map =
\ { '__': '-'
\ , 'c' : term_symbol
\ , 'i' : pencil_symbol
\ , 'ic': pencil_symbol.' '.list_symbol
\ , 'ix': pencil_symbol.' '.list_symbol
\ , 'n' : vim_symbol
\ , 'ni': 'N'
\ , 'no': spinner_symbol
\ , 'R' : 'R'
\ , 'Rv': 'R VIRTUAL'
\ , 's' : 'S'
\ , 'S' : 'S LINE'
\ , '': 'S BLOCK'
\ , 't' : term_symbol
\ , 'v' : ibar_symbol
\ , 'V' : ibar_symbol.' LINE'
\ , '': ibar_symbol.' BLOCK'
\ }
let airline#extensions#ale#error_symbol         = error_symbol.':'
let airline#extensions#ale#warning_symbol       = warning_symbol.':'
let airline#extensions#coc#error_symbol         = error_symbol.':'
let airline#extensions#coc#warning_symbol       = warning_symbol.':'
let g:airline#extensions#quickfix#quickfix_text = wand_symbol
let g:airline#extensions#quickfix#location_text = list_symbol

" Patch in missing colors for terminal status line
let g:airline_theme_patch_func = 'AirlineThemePatch'
function! AirlineThemePatch(palette)
  if g:airline_theme ==# 'solarized'
    for key in ['normal', 'insert', 'replace', 'visual', 'inactive']
      let a:palette[key].airline_term = a:palette[key].airline_x
    endfor
    let a:palette.inactive.airline_choosewin = [g:terminal_color_7, g:terminal_color_2, 2, 7, 'bold']
  endif
endfunction
" }}}

" UI Window Chooser {{{
" =================

" vim-choosewin
" mimic tmux's display-pane feature
" https://github.com/t9md/vim-choosewin
" color setting in BASIC VIM CONFIG section
nmap <silent><space><space> <Cmd>call ActiveChooseWin()<CR>
let g:choosewin_active = 0
let g:choosewin_label = 'TNERIAODH' " alternating on homerow for colemak (choosewin uses 'S')
let g:choosewin_tabline_replace = 0    " don't use ChooseWin tabline since Airline provides numbers
let g:choosewin_statusline_replace = 0 " don't use ChooseWin statusline, since we make our own below

" Setup autocommands to customize status line for ChooseWin
augroup choosevim_airline
  au!
  au User AirlineAfterInit call airline#add_statusline_func('ChooseWinAirline')
  au User AirlineAfterInit call airline#add_inactive_statusline_func('ChooseWinAirline')
augroup END

" Create custom status line when ChooseWin is trigger
function! ChooseWinAirline(builder, context)
  if g:choosewin_active == 1
    " Define label
    let label_pad = "      "
    let label = label_pad . g:choosewin_label[a:context.winnr-1] . label_pad

    " Figure out how long sides need to be
    let total_side_width = (winwidth(a:context.winnr)) - 2 - strlen(label) " -2 is for separators
    let side_width = total_side_width / 2

    " Create side padding
    let right_pad = ""
    for i in range(1, side_width) | let right_pad = right_pad . " " | endfor
    let left_pad = (total_side_width % 2 == 1) ? right_pad . " " : right_pad

    if a:context.active == 0
      " Define status line for inactive windows
      call a:builder.add_section('airline_a', left_pad)
      call a:builder.add_section('airline_choosewin', label)
      call a:builder.split()
      call a:builder.add_section('airline_z', right_pad)
    else
      " Define status line of active windows
      call a:builder.add_section('airline_b', left_pad)
      call a:builder.add_section('airline_x', label)
      call a:builder.split()
      call a:builder.add_section('airline_y', right_pad)
    endif
    return 1
  endif

  return 0
endfunction

" Custom function to launch ChooseWin
function! ActiveChooseWin() abort
  let g:choosewin_active = 1 " Airline doesn't see when ChooseWin toggles this
  AirlineRefresh
  ChooseWin
  AirlineRefresh
endfunction
" }}}

" UI Welcome Screen {{{
" =================

" Startify
" Start screen configuration
" https://github.com/mhinz/vim-startify
let g:startify_files_number        = 10 " max number of files/dirs in lists
let g:startify_relative_path       = 1  " use relative path if file is below current directory
let g:startify_update_oldfiles     = 1  " update old file list whenever Startify launches
let g:startify_fortune_use_unicode = 1  " use unicode rather than ASCII in fortune

" Define Startify lists
let g:startify_lists =
\ [ {'type': 'files'    , 'header': ['    🕘  Recent']}
\ , {'type': 'dir'      , 'header': ['    🕘  Recent in '. getcwd()]}
\ , {'type': 'bookmarks', 'header': ['    🔖  Bookmarks']}
\ , {'type': 'commands' , 'header': ['    🔧  Commands']}
\ ]

" Define bookmarks and commands
" Remember that Startify uses h, j, k, l, e, i, q, b, s, v, and t.
let g:startify_bookmarks =
\ [ {'n': '~/.config/nixpkgs/configs/nvim/init.vim'}
\ , {'c': '~/.config/nixpkgs/configs/nvim/coc-settings.json'}
\ , {'f': '~/.config/fish/config.fish'}
\ ]
let g:startify_commands =
\ [ {'t': ['Open Terminal',  'term']}
\ , {'r':
\     [ 'Resource NeoVim config'
\     , ' let newVimConfig=system("nix-store --query --references (which nvim) | grep vimrc")
\       | execute "source" newVimConfig
\       | redraw
\       '
\     ]
\   }
\ ]
" }}}

" Window/Tab Creation/Navigation {{{
" =============================

" Make escape more sensible in terminal mode
" enter normal mode
tnoremap <ESC> <C-\><C-n>
" send escape to terminal
tnoremap <leader><ESC> <ESC>

" Start new terminals in insert mode
augroup nvimTerm
  au TermOpen * if &buftype == 'terminal' | :startinsert | :setlocal nonumber | :setlocal norelativenumber | :setlocal signcolumn=no | endif
augroup END

" Set where splits open
set splitbelow " open horizontal splits below instead of above which is the default
set splitright " open vertical splits to the right instead of the left with is the default

" Tab creation/destruction
" new Startify tab
nmap <silent><space>tt <Cmd>tabnew +Startify<CR>
" close other tabs
nmap <silent><space>to <Cmd>tabonly<CR>
" close current tab
nmap <silent><space>tq <Cmd>tabclose<CR>

" Tab navigation
" focus next tab
nmap <silent><space>tn <Cmd>tabnext<CR>
" focus previous tab
nmap <silent><space>tN <Cmd>tabprevious<CR>
if has('macunix')
  " focus next tab
  noremap <S-D-}> <Cmd>tabnext<CR>
  noremap <S-D-{> <Cmd>tabprevious<CR>       " focus previous tab
  inoremap <S-D-}> <Esc><Cmd>tabnext<CR>     " focus next tab
  inoremap <S-D-{> <Esc><Cmd>tabprevious<CR> " focus previous tab
  cnoremap <S-D-}> <Esc><Cmd>tabnext<CR>     " focus next tab
  cnoremap <S-D-{> <Esc><Cmd>tabprevious<CR> " focus previous tab
end

" Split creation/destruction
" open terminal below
nmap <silent><space>_  <Cmd>new +term<CR>
" open terminal at bottom
nmap <silent><space>-  <Cmd>botright new +term<CR>
" open terminal to right" open terminal below
nmap <silent><space>_  <Cmd>new +term<CR>
" open terminal at bottom
nmap <silent><space>-  <Cmd>botright new +term<CR>
" open terminal to right
nmap <silent><space>\  <Cmd>vnew +term<CR>
" open terminal at right, full height
nmap <silent><space>\| <Cmd>botright vnew +term<CR>
" open split below
nmap <silent><space>ws <Cmd>split<CR>
" open split to right
nmap <silent><space>wv <Cmd>vsplit<CR>
" close current window
nmap <silent><space>wq <Cmd>q<CR>
" close other windows
nmap <silent><space>wo <Cmd>only<CR>
nmap <silent><space>\  <Cmd>vnew +term<CR>
" open terminal at right, full height
nmap <silent><space>\| <Cmd>botright vnew +term<CR>
" open split below
nmap <silent><space>ws <Cmd>split<CR>
" open split to right
nmap <silent><space>wv <Cmd>vsplit<CR>
" close current window
nmap <silent><space>wq <Cmd>q<CR>
" close other windows
nmap <silent><space>wo <Cmd>only<CR>

" Split movement
" current window to top
nnoremap <silent><space>wk <C-w>K
" current window to bottom
nnoremap <silent><space>wj <C-w>J
" current window to left
nnoremap <silent><space>wh <C-w>H
" current window to right
nnoremap <silent><space>wl <C-w>L
" current window to new tab
nnoremap <silent><space>wt <C-w>T

" Various quit/close commands
" close one help window
nmap <silent><space>qh <Cmd>helpclose<CR>
" close any open "Preview" window
nmap <silent><space>qp <Cmd>pclose<CR>
" close the quickfix window
nmap <silent><space>qc <Cmd>cclose<CR>
"" }}}

" Coc.vim, linting, completion, language server {{{
" =======

" General Config {{{

" Vim setting recommended by Coc.nvim
set hidden         " if not set, TextEdit might fail
set nobackup       " some lang servers have issues with backups, should be default, set just in case
set nowritebackup
set updatetime=300 " smaller update time for CursorHold and CursorHoldI
set shortmess+=c   " don't show ins-completion-menu messages.

" Extensions to load
let g:coc_global_extensions =
\ [ 'coc-eslint'
\ , 'coc-fish'
\ , 'coc-import-cost'
\ , 'coc-json'
\ , 'coc-git'
\ , 'coc-lists'
\ , 'coc-markdownlint'
\ , 'coc-sh'
\,  'coc-smartf'
\ , 'coc-tabnine'
\ , 'coc-tsserver'
\ , 'coc-vimlsp'
\ , 'coc-yaml'
\ , 'coc-yank'
\ , 'coc-prettier'
\ , 'coc-pairs'
\ , 'coc-python'
\ , 'coc-solargraph'
\ , 'coc-emoji'
\ ]

" Hack to use coc-settings.json file with Nix
let g:coc_user_config = json_decode(readfile($HOME . '/.config/nixpkgs/configs/nvim/coc-settings.json'))

" Other basic Coc.nvim config
let g:coc_status_error_sign   = error_symbol
let g:coc_status_warning_sign = warning_symbol
let g:markdown_fenced_languages = ['vim', 'help']

" Autocommands
augroup coc_autocomands
  au!
  " Setup formatexpr specified filetypes (default binding is gq)
  au FileType typescript,json,haskell setl formatexpr=CocAction('formatSelected')
  " Highlight symbol under cursor on CursorHold
  au CursorHold * silent call CocActionAsync('highlight')
  " Update signature help on jump placeholder
  " TODO: understand what this does
  au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  " Close preview window when completion is done
  au CompleteDone * if pumvisible() == 0 | pclose | endif
augroup end

" Make highlights fit in with colorscheme
hi link CocErrorSign NeomakeErrorSign
hi link CocWarningSign NeomakeWarningSign
hi link CocInfoSign NeomakeInfoSign
hi link CocHintSign NeomakeMessagesSign
hi link CocErrorHighlight SpellBad
hi link CocWarningHighlight SpellLocal
hi link CocInfoHighlight CocUnderline
hi link CocHintHighlight SpellRare
hi link CocHighlightText SpellCap
hi link CocCodeLens Comment
hi link HighlightedyankRegion Visual
" }}}

" Keybindings {{{

" Language server keybinding
nmap <silent><space>le <Cmd>CocList diagnostics<CR>
nmap <silent><space>ln <Plug>(coc-diagnostic-next)
nmap <silent><space>lN <Plug>(coc-diagnostic-prev)
nmap <silent>       ]c <Plug>(coc-diagnostic-next)
nmap <silent>       [c <Plug>(coc-diagnostic-prev)

nmap <silent><space>ld <Plug>(coc-definition)
nmap <silent>       gd <Cmd>call CocAction('jumpDefinition', 'edit')<CR>
nmap <silent><space>lh <Cmd>call CocAction('doHover')<CR>
nmap <silent><space>K  <Cmd>call CocAction('doHover')<CR>
nmap <silent><space>li <Plug>(coc-implementation)
nmap <silent>       gi <Cmd>call CocAction('jumpImplementation', 'edit')<CR>
nmap <silent><space>lt <Plug>(coc-type-definition)
nmap <silent>       gy <Cmd>call CocAction('jumpTypeDefinition', 'edit')<CR>
nmap <silent><space>lR <Plug>(coc-references)
nmap <silent><space>lr <Plug>(coc-rename)

nmap <silent><space>lf <Plug>(coc-format)
nmap <silent><space>lF <Plug>(coc-format-selected)

nmap <silent><space>la <Plug>(coc-codeaction)
nmap <silent><space>lc <Plug>(coc-codelens-action)
nmap <silent><space>lq <Plug>(coc-fix-current)

" List keybindings
" Coc.nvim
nmap <silent><space>lA  <Cmd>CocList actions<CR>
nmap <silent><space>ls  <Cmd>CocList symbols<CR>
nmap <silent><space>scc <Cmd>CocList commands<CR>
nmap <silent><space>sce <Cmd>CocList extensions<CR>
nmap <silent><space>scl <Cmd>CocList lists<CR>
nmap <silent><space>scs <Cmd>CocList sources<CR>
" buffers
nmap <silent><space>sb  <Cmd>CocList buffers<CR>
" files
" TODO: find easy way to search hidden files (in Denite prepending with "." works)
" TODO: find a way to move up path
nmap <silent><space>sf  <Cmd>CocList files<CR>
nmap <silent><space>sp  <Cmd>CocList files -F<CR>
" filetypes
nmap <silent><space>st  <Cmd>CocList filetypes<CR>
" git
nmap <silent><space>sgb <Cmd>CocList branches<CR>
nmap <silent><space>sgc <Cmd>CocList commits<CR>
nmap <silent><space>sgi <Cmd>CocList issues<CR>
nmap <silent><space>sgs <Cmd>CocList gstatus<CR>
" grep
nmap <silent><space>sg  <Cmd>CocList --interactive grep -F<CR>
nmap <silent><space>sw  <Cmd>execute "CocList --interactive --input=".expand("<cword>")." grep -F"<CR>
" help tags
nmap <silent><space>s?  <Cmd>CocList helptags<CR>
" lines of buffer
nmap <silent><space>sl  <Cmd>CocList lines<CR>
nmap <silent><space>s*  <Cmd>execute "CocList --interactive --input=".expand("<cword>")." lines"<CR>
" maps
nmap <silent><space>sm  <Cmd>CocList maps<CR>
" search history
nmap <silent><space>ss  <Cmd>CocList searchhistory<CR>
" Vim commands
nmap <silent><space>sx  <Cmd>CocList vimcommands<CR>
" Vim commands history
nmap <silent><space>sh  <Cmd>CocList cmdhistory<CR>
" yank history
nmap <silent><space>sy  <Cmd>CocList --normal yank<CR>
" resume previous search
nmap <silent><space>sr  <Cmd>CocListResume<CR>


" Other keybindings

" Git related
nmap <silent><space>gw  <Cmd>CocCommand git.browserOpen<CR>
nmap <silent><space>gcd <Plug>(coc-git-chunkinfo)
nmap <silent><space>gcj <Plug>(coc-git-nextchunk)
nmap <silent><space>gck <Plug>(coc-git-prevchunk)
nmap                ]g  <Plug>(coc-git-nextchunk)
nmap                [g  <Plug>(coc-git-prevchunk)
nmap <silent><space>gcs <Cmd>CocCommand git.chunkStage<CR>
nmap <silent><space>gcu <Cmd>CocCommand git.chunkUndo<CR>

" Smartf
nmap f <Plug>(coc-smartf-forward)
nmap F <Plug>(coc-smartf-backward)
nmap ; <Plug>(coc-smartf-repeat)
nmap , <Plug>(coc-smartf-repeat-opposite)

augroup Smartf
  autocmd User SmartfEnter :hi Conceal ctermfg=220 guifg=#6638F0
  autocmd User SmartfLeave :hi Conceal ctermfg=239 guifg=#504945
augroup end

" use tab to navigate completion menu and jump in snippets
inoremap <expr> <Tab>
\ pumvisible()
\ ? '<C-n>'
\ : coc#jumpable()
\   ? '<C-r>=coc#rpc#request("doKeymap", ["snippets-expand-jump",""])<CR>'
\   : '<Tab>'
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

command! -nargs=0 Prettier :CocCommand prettier.formatFile
" }}}

" }}}

" Linter/Fixer {{{
" ============
" Asyncronous Linting Engine (ALE)
" Used for linting when no good language server is available
" https://github.com/w0rp/ale

" Disable linters for languges that have defined language servers above
let g:ale_linters =
\ { 'c'         : []
\ , 'haskell'   : []
\ , 'javascript': []
\ , 'lua'       : []
\ , 'sh'        : []
\ , 'typescript': []
\ , 'vim'       : []
\ }

" Configure and enable fixer
let g:ale_fix_on_save = 1
let g:ale_fixers =
\ { 'markdown'   : ['remove_trailing_lines']
\ , '*'          : ['trim_whitespace']
\ }

" Customize symbols
let g:ale_sign_error         = error_symbol
let g:ale_sign_warning       = warning_symbol
let g:ale_sign_info          = info_symbol
let g:ale_sign_style_error   = pencil_symbol
let g:ale_sign_style_warning = g:ale_sign_style_error
" }}}

" Writing {{{
" =======

" vim-pencil
" Adds a bunch of really nice features for writing
" https://github.com/reedes/vim-pencil
let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'
let g:airline_section_x = '%{PencilMode()}'
augroup pencil
  au!
  au FileType markdown,mkd,text call pencil#init() | set spell
augroup END

" Goyo
" Distraction free writing mode for vim
" https://github.com/junegunn/goyo.vim
" }}}

" Filetype Specific {{{
" =================

" Most filetypes
" vim-polyglot
" A solid language pack for Vim
" https://github.com/sheerun/vim-polyglot

" Haskell
" haskell-vim (comes in vim-polyglot)
" https://github.com/neovimhaskell/haskell-vim.git
" indenting options
let g:haskell_indent_if               = 3
let g:haskell_indent_case             = 2
let g:haskell_indent_let              = 4
let g:haskell_indent_where            = 6
let g:haskell_indent_before_where     = 2
let g:haskell_indent_after_bare_where = 2
let g:haskell_indent_do               = 3
let g:haskell_indent_in               = 1
let g:haskell_indent_guard            = 2
" turn on extra highlighting
let g:haskell_backpack                = 1 " to enable highlighting of backpack keywords
let g:haskell_enable_arrowsyntax      = 1 " to enable highlighting of `proc`
let g:haskell_enable_quantification   = 1 " to enable highlighting of `forall`
let g:haskell_enable_recursivedo      = 1 " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_static_pointers  = 1 " to enable highlighting of `static`
let g:haskell_enable_typeroles        = 1 " to enable highlighting of type roles

" Javascript
" vim-javascript (comes in vim-polyglot)
" https://github.com/pangloss/vim-javascript
let g:javascript_plugin_jsdoc = 1

" Markdown
" vim-markdown (comes in vim-polyglot)
" https://github.com/plasticboy/vim-markdown
let g:vim_markdown_folding_disabled     = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_fenced_languages = ['viml=vim', 'ruby', 'python', 'bash=sh', 'html', 'help']
" let g:vim_markdown_frontmatter = 1
" let g:vim_markdown_strikethrough = 1

" Typescript
" yats.vim
" https://github.com/herringtondarkholme/yats.vim
let g:polyglot_disabled = ['typescript', 'jsx']
" }}}

" Misc {{{
" ====

" vim-fugitive
" A Git wrapper so awesome, it should be illegal
" https://github.com/tpope/vim-fugitive
nnoremap <silent><space>gb  <Cmd>Gblame<CR>
nnoremap <silent><space>gs  <Cmd>Gstatus<CR>
nnoremap <silent><space>gds <Cmd>Ghdiffsplit<CR>
nnoremap <silent><space>gdv <Cmd>Gvdiffsplit<CR>


" tabular
" Helps vim-markdown with table formatting amoung many other things
" https://github.com/godlygeek/tabular

" vim-commentary
" Comment stuff out (easily)
" https://github.com/tpope/vim-commentary
nmap <leader>c gcc
nmap <leader>C gcc
vmap <leader>c gc
vmap <leader>C gc

" vim-surround
" Quoting/parenthesizing made simple
" https://github.com/tpope/vim-surround
" }}}


" Commands {{{
" ========

" Tidy
command! -range=% Tidy :<line1>,<line2>!tidy -quiet -indent -clean -bare -wrap 0 --show-errors 0 --show-body-only auto

" CDC = Change to Directory of Current file
command! CDC cd %:p:h

" Visual mode copy to pastebuffer
" kudos to Brad: http://xtargets.com/2010/10/13/cutting-and-pasting-source-code-from-vim-to-skype/
function! CopyWithLineNumbers() range
    redir @*
    sil echomsg "----------------------"
    sil echomsg expand("%")
    sil echomsg "----------------------"
    exec 'sil!' . a:firstline . ',' . a:lastline . '#'
    redir END
endfunction
command! -range CopyWithLineNumbers <line1>,<line2>call CopyWithLineNumbers()

" w!! to save with root permissions
cmap w!! w !sudo tee % > /dev/null

" Quickly change tab width etc.
command! -nargs=1 TabWidth setlocal shiftwidth=<args> | set tabstop=<args>

" }}}

" Mappings {{{
" ========
" turn off search hilight
nmap <silent> <leader>n :silent :nohlsearch<CR>

" Substitute the word under the cursor
nnoremap <Leader>s :%s/\C\<<C-r><C-w>\>//gc<Left><Left><Left>
vnoremap <Leader>s y:%s/\C\<<C-r>"\>//gc<Left><Left><Left>

" Search for the visually selected word
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Make moving around in Command-mode less painful
" move to start of command window
cnoremap <C-A> <Home>
" move to end of command window
cnoremap <C-E> <End>

" ## Input mappings
" New line below, above  TODO: fix this in graphical clients
" insert on line below
inoremap <S-CR> <ESC>o
" insert on line above
inoremap <C-CR> <ESC>O

" forward delete in insert mode
inoremap <C-d> <Delete>

" Refactoring: rename local variable
"   gd - jump to definition of word under cursor
"   [{ - jump to start of block
"   V  - visual block mode
"   %  - jump to end of block
"   :  - command mode
"   s/ - substitude
"   <C-R>/ - insert text of last search
"   //gd<left><left><left> - finish subtitute command and move cursor
" rename local variable (current scope)
nmap gr gd[{V%:s/<C-R>///gc<left><left><left>
" Refactoring: rename variable across whole file
"   [{ - jump to start of block
"   V  - visual block mode
"   %  - jump to end of block
"   :  - command mode
"   s/ - substitude
"   <C-R>/ - insert text of last search
"   //gd<left><left><left> - finish subtitute command and move cursor
" rename local variable (whole file)
nnoremap gR gD:%s/<C-R>///gc<left><left><left>

" Command mode shortcuts
" insert ~/code/
cmap ~c/ ~/code/
" insert ~/source/
cmap ~s/ ~/source/

command! PROF profile start profile.log | profile func * | profile file *
command! PROFSTOP profile stop
" == =>

" Searchable list of mappings
function! s:ShowMaps()
  let old_reg = getreg("a")                  " save the current content of register a
  let old_reg_type = getregtype("a")         " save the type of the register as well
  try
    redir @a                                 " redirect output to register a
    " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
    silent map | call feedkeys("\<CR>        ")
    redir END                                " end output redirection
    vnew                                     " new buffer in vertical window
    put a                                    " put content of register
                                             " Sort on 4th character column which is the key(s)
    %!sort --key 1,14
  finally                                    " Execute even if exception is raised
    call setreg("a", old_reg, old_reg_type)  " restore register a
  endtry
endfunction
command! ShowMaps call s:ShowMaps()              " Enable :ShowMaps to call the function
" Map keys to call the function
nnoremap <leader>m :ShowMaps<CR>

function! MoveToPrevTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() != 1
    close!
    if l:tab_nr == tabpagenr('$')
      tabprev
    endif
    sp
  else
    close!
    exe "0tabnew"
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

function! MoveToNextTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() < tab_nr
    close!
    if l:tab_nr == tabpagenr('$')
      tabnext
    endif
    sp
  else
    close!
    tabnew
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

" }}}

" Source vimrc
command! VS source $MYVIMRC | filetype detect | redraw | echo "vimrc reloaded"
" Source vimrc when it changes
augroup myvimrc
  autocmd!
  autocmd BufWritePost $MYVIMRC :VS
augroup END
" Edit vimrc
command! VE tabedit $MYVIMRC
