" spell-checker: disable

set autoindent cindent
set cmdheight=1
set cursorline cursorcolumn
set concealcursor=nc conceallevel=3
set expandtab tabstop=2 shiftwidth=2
set foldmethod=syntax foldlevel=100
set hidden
set ignorecase smartcase
set list listchars=tab:\ \ →,trail:-,extends:»,precedes:«,nbsp:+
set nowrap scrolloff=5 sidescrolloff=5 linebreak
set number relativenumber signcolumn=number
set pumblend=15
set shortmess-=T "shortmess+=c
set suffixes-=.h wildignore+=.class,.o,.obj,.swp,~ wildmenu wildmode=longest:full,full
set termguicolors
set timeoutlen=800  " Speed your fingers up, man~
set title
set updatetime=100

"set viminfo='1000        " TODO: What's this?

call plug#begin(stdpath('data') . '/plugged')
Plug 'chrisbra/Colorizer'
Plug 'exafunction/codeium.vim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'honza/vim-snippets'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'joshdick/onedark.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'rcarriga/nvim-notify'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
call plug#end()

" onedark
" The next two lines give onedark a transparent background.
let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white }) " `bg` will not be styled since there is no `bg` setting
let g:onedark_terminal_italics = 1
colorscheme onedark

"lua require("tokyonight").setup({ transparent = true })
"colorscheme tokyonight-night

" Used to make vim-notify happy, needed only when the Normal group has no
" guibg set, e.g., the default colorscheme.
"highlight Normal guibg=black

" vim-airline
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#fzf#enabled = 1
let g:airline#extensions#hunks#coc_git = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='onedark'

" Codeium
" Disalbe the default mapping of <Tab> from codeium, we will do it ourselves
let g:codeium_no_map_tab = v:true
let g:codeium_idle_delay = 100

" coc.nvim
let g:coc_global_extensions = [
\  'coc-clangd',
\  'coc-cmake',
\  'coc-explorer',
\  'coc-fzf-preview',
\  'coc-git',
\  'coc-java',
\  'coc-json',
\  'coc-lists',
\  'coc-markdownlint',
\  'coc-marketplace',
\  'coc-pairs',
\  'coc-pyright',
\  'coc-sh',
\  'coc-snippets',
\  'coc-sql',
\  'coc-spell-checker',
\  'coc-vimlsp',
\]

" coc-explorer
let g:coc_explorer_global_presets = {
\   'floating': {
\     'position': 'floating',
\     'open-action-strategy': 'sourceWindow',
\   }
\ }

let g:fzf_preview_grep_cmd = 'rg --line-number --no-heading --color=never'
let g:fzf_preview_command = 'bat --color=always --plain {-1}'
let g:fzf_preview_lines_command = 'bat --color=always --plain --number'

"hi CocSearch ctermfg=12 guifg=#18A3FF
"hi CocMenuSel ctermbg=109 guibg=#13354A

augroup default
  autocmd!
  autocmd FocusGained,BufEnter * :silent! checktime
  autocmd FileType c,cpp,objc,objcpp,java setlocal listchars+=leadmultispace:\|\  foldmethod=syntax foldlevel=100

  " Set these if the corresponding highlight group of current colorscheme is uglg.
  "autocmd FileType c,cpp,objc,objcpp,java :highlight Folded guibg=gray guifg=lightgreen
  "autocmd FileType c,cpp,objc,objcpp,java :highlight NonText guifg=gray

  autocmd FileType c,cpp setlocal colorcolumn=81
  autocmd FileType objc,objcpp,java setlocal colorcolumn=101

  " Highlight the symbol and its references when holding the cursor
  autocmd CursorHold * silent call CocActionAsync('highlight')

  autocmd BufWritePost *.vim,*.lua source %
augroup END

runtime! map.vim
runtime! coc-notify-integration.vim
