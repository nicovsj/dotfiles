" Autoinstall vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'hzchirs/vim-material'
Plug 'altercation/vim-colors-solarized'
call plug#end()


"Search settings
set incsearch
set ignorecase

"Colorscheme and syntax
set background=dark
colorscheme material-theme
syntax on 

" Mouse support
" set mouse=a

" Encoding
set encoding=utf-8

" Numberlines
set number
set relativenumber

" Set correct splitting
set splitbelow
set splitright

" Faster split navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-l>l

"No backup and swap files
set nobackup
set nowritebackup
set noswapfile
