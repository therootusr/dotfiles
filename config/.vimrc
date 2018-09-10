" vundle
set nocompatible
filetype off

" set the runtime path to include Vundle and init
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'

call vundle#end()
filetype plugin indent on
" ~vundle

syntax on
set relativenumber
set autoindent
set smartindent
set cursorline
set ruler
set laststatus=2
set wrap textwidth=0 wrapmargin=0 linebreak

let mapleader="\<tab>"

" noremap
noremap i k
noremap ; i
noremap j h
noremap k j
noremap q b
noremap <CR> o<ESC>k

" noremap tabs
noremap tn :tabnew<SPACE>
noremap tj :tabprev<CR>
noremap tl :tabnext<CR>
noremap ti :tabfirst<CR>
noremap tk :tablast<CR>
noremap tx :q!<CR>
noremap ts :wq<CR>
noremap tq :q<CR>
noremap tw :w<CR>
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt

" noremap NERDTree
noremap t1 :NERDTreeToggle<CR>


