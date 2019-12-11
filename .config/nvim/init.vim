let mapleader =","

call plug#begin('~/.local/share/nvim/plugged')
Plug 'tpope/vim-sensible'
Plug 'lervag/vimtex'
Plug 'sirver/ultisnips'
Plug 'kaicataldo/material.vim'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'PotatoesMaster/i3-vim-syntax'
call plug#end()

"----------------GENERAL------------------"

set scrolloff=5
set noswapfile
set number relativenumber

set autoindent
set tabstop=2
set shiftwidth=2

set mouse=a
set autochdir
if (has('termguicolors'))
	set termguicolors
endif

let g:python3_host_prog = '/usr/bin/python'

" As lightline plugin is installed, showmode is no longer necessary
set noshowmode
filetype plugin on

"-------------KEYBINDINGS--------------"

inoremap <C-v> <ESC>"+pa
vnoremap <C-c> "+y
vnoremap <C-d> "+d

"------------THEME & STYLE-------------"

" First, set lightline theme
let g:lightline = {
	\ 'colorscheme' : 'material',
	\ }
colorscheme material
let g:material_theme_style = 'palenight'
highlight MatchParen guibg=NONE

"------------vimtex configs---------------"

let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

"------------UtilSnips configs------------"

let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsSnippetDirectories = ["UltiSnips", "my_snippets"]

highlight Conceal ctermbg=0 ctermfg=255

"---------------AUTOCMDS--------------------"

" Runs a script that cleans out tex build files at closing a .tex file
autocmd VimLeave *.tex !latex-clean %
