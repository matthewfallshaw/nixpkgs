" Package manager initialization
" if empty(glob(stdpath('config') . '/autoload/plug.vim'))
"   silent execute "!curl -fLo " . stdpath('config') . "/autoload/plug.vim
"     \ --create-dirs
"     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
"   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" endif
" call plug#begin(stdpath('config') . '/site/pack')
" Plug 'junegunn/vim-plug'        " Enable help for vim-plug itself

" Plug 'rafcamlet/nvim-luapad'
" Plug 'jiangmiao/auto-pairs'
" Plug 'airblade/vim-rooter'
" Plug 'sirtaj/vim-openscad'


" vim-rooter
" for non-project files/directories, change to file's directory (similar to autochdir).
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_cd_cmd = "lcd"        " change directory for the current window only
let g:rooter_resolve_links = 1     " resolve symbolic links
let g:rooter_patterns =
      \ [ '.git'
      \ , '.git/'
      \ , 'Rakefile'
      \ , 'package.json'
      \ , 'manifest.json'
      \ , 'tsconfig.json'
      \ , 'package.yaml'
      \ , 'stack.yaml'
      \ , '.root']

" vim-openscad
let g:openscad_space_errors = 1

" Markdown
" vim-markdown (comes in vim-polyglot)
" https://github.com/plasticboy/vim-markdown
let g:vim_markdown_folding_disabled     = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_fenced_languages = ['viml=vim', 'ruby', 'python', 'bash=sh', 'html', 'help']
" let g:vim_markdown_frontmatter = 1
" let g:vim_markdown_strikethrough = 1

" Markdown
" vim-markdown (comes in vim-polyglot)
" https://github.com/plasticboy/vim-markdown
let g:vim_markdown_folding_disabled     = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_fenced_languages = ['viml=vim', 'ruby', 'python', 'bash=sh', 'html', 'help']
" let g:vim_markdown_frontmatter = 1
" let g:vim_markdown_strikethrough = 1

" vim-fugitive
" A Git wrapper so awesome, it should be illegal
" https://github.com/tpope/vim-fugitive
nnoremap <silent><space>gb  <Cmd>Gblame<CR>
nnoremap <silent><space>gs  <Cmd>Gstatus<CR>
nnoremap <silent><space>gds <Cmd>Ghdiffsplit<CR>
nnoremap <silent><space>gdv <Cmd>Gvdiffsplit<CR>
