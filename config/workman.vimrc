" vundle
set nocompatible
set hidden
filetype off

" set the runtime path to include Vundle and init
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'jeaye/color_coded'
Plugin 'roxma/nvim-yarp'
Plugin 'roxma/vim-hug-neovim-rpc'
" To use in vim8: python3 -m pip install pynvim (roxma/vim-hug-neovim-rpc)
Plugin 'Shougo/deoplete.nvim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'tomtom/tcomment_vim'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'VundleVim/Vundle.vim'
Plugin 'w0rp/ale'
" cd ~/.vim/bundle/command-t/ruby/command-t/ext/command-t
" ruby extconf.rb && make clean && make
Plugin 'wincent/command-t'

call vundle#end()
filetype plugin indent on
" ~vundle

syntax on
"color scheme
:color desert
:hi Comment ctermfg=grey
:hi Search ctermbg=White ctermfg=Red

" set
set number relativenumber
set autoindent
set autoread
set smartindent
set cursorline
set ruler
set laststatus=2
set wrap textwidth=0 wrapmargin=0 linebreak
set tabstop=4 expandtab shiftwidth=2
set visualbell
set noerrorbells
set list
set t_Co=256
set colorcolumn=80
" '100 - save <=100 files' info.
" f1 - save global marks (A-Z).
" set viminfo='100,f1

" vim search
set incsearch
set hlsearch
set ignorecase
set smartcase
set nowrapscan

" vim buffers
set switchbuf=useopen

" From sensible.vim (tpope/vim-sensible)
set backspace=indent,eol,start
"set complete-=i
set wildmenu
set scrolloff=5

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

let mapleader="\<tab>"

augroup vimrc
  " auto switch window local current directory in accordance with the current file.
  autocmd BufEnter * lcd %:p:h

  " clang-format
  function FormatCpp()
    let git_check = system("git diff " . bufname("%"))
    if v:shell_error == 0
      set shellcmdflag=-ic
      silent !clang-format-git %
      set shellcmdflag&
    else
      silent !clang-format -i --style=file --fallback-style=google %
    endif
  endfunction
  autocmd BufWritePost *.h,*.hpp,*.cc,*.cpp call FormatCpp()

  " code dispatch noremap; #run
  autocmd Filetype python noremap <buffer> <leader>r :vert rightb term python3 %<CR>
  autocmd Filetype go noremap <buffer> <leader>r :vert rightb term go run %<CR>
  autocmd Filetype cpp noremap <buffer> <leader>r :!g++ -g --std=c++17 -o %.out %<CR> :vert rightb term ./%.out<CR>
augroup END

" commands
command FormatJSON %!python -m json.tool

" noremap
noremap u k
noremap n h
noremap e j
noremap q b
noremap o l
noremap l o
noremap L O
noremap k u
" , -> always to next match and not relative to direction from '#/s'
noremap , //<CR>
noremap < ??<CR>
noremap r e
noremap h r
noremap s *
noremap S #
noremap # q
noremap 0 ^
noremap ^ 0
noremap ' `
noremap K <C-r>

noremap <leader>l :set noma<CR>
noremap <leader>L :set ma<CR>
noremap <leader>f :set ic!
noremap <leader><space> :set list!<CR>
noremap ` :sh<CR>

" noremap w anad q
noremap <leader>x :q!<CR>
noremap <leader>q :q<CR>
noremap <leader>s :w<CR>
noremap <leader><leader>s :wq<CR>

" noremap buffers
" noremap <expr>bn ":".nr2char(getchar())."bprevious<CR>"
noremap bb :ls<CR>
noremap b! :ls!<CR>
" noremap bd :bp<bar>sp<bar>bn<bar>bd<CR>
noremap bd :bp<CR>:bd #<CR>
noremap bu :vert sbprevious<CR>
noremap bn :bprevious<CR>
noremap b\ :vert sbnext<CR>
noremap b- :sbnext<CR>
noremap bo :bnext<CR>
noremap bg <C-^>
noremap bs <C-W>^<C-W>H

" noremap windows
noremap <Leader>w <C-w>
noremap <Leader>e <C-w><C-j>
noremap <Leader>u <C-w><C-k>
noremap <Leader>n <C-w><C-h>
noremap <Leader>o <C-w><C-l>
noremap <Leader>E <C-w><C-J>
noremap <Leader>U <C-w><C-K>
noremap <Leader>N <C-w><C-H>
noremap <Leader>O <C-w><C-L>
noremap <Leader><Leader>w <C-W>T

noremap <Leader>wV <C-w>H
noremap <Leader>wH <C-w>K

noremap <Leader>wh <C-w>s
noremap <Leader>ws <C-w>v
noremap <Leader>wv :vnew<CR>
noremap <Leader>wt :vert sf<space>

" noremap tabs
noremap <leader>N :tabnew<SPACE>
noremap <leader>h :tabnext<CR>
noremap <leader>a :tabprev<CR>

" noremap misc
noremap gp a<C-r>0<ESC>
noremap <leader>p ciw<C-r>0<ESC>
inoremap hh <ESC>
nnoremap <leader>/ :%s/<c-r><c-w>//ng<cr>
" vnoremap <leader>/ :<c-u>%s/<c-r>*//ng<cr>
nnoremap <leader>y "+y
nnoremap <leader>Y mpgg"+yG`p

" functions
function! JumpInFile(back, forw)
  let [n, i] = [bufnr('%'), 1]
  let p = [n] + getpos('.')[1:]
  sil! exe 'norm!1' . a:forw
  while 1
    let p1 = [bufnr('%')] + getpos('.')[1:]
    if n == p1[0] | break | endif
    if p == p1
      sil! exe 'norm!' . (i-1) . a:back
      break
    endif
    let [p, i] = [p1, i+1]
    sil! exe 'norm!1' . a:forw
  endwhile
endfunction
nnoremap <silent> <C-n> :call JumpInFile("\<c-i>", "\<c-o>")<cr>
nnoremap <silent> <C-o> :call JumpInFile("\<c-o>", "\<c-i>")<cr>

" NERDTree
noremap <leader>1 :NERDTreeToggle<CR>
noremap <leader><leader>1 :NERDTreeFind<CR>
let NERDTreeMapOpenExpl = 'd'
let NERDTreeMapUpdir = 'k'
let NERDTreeMapUpdirKeepOpen = 'K'

" deoplete
let g:deoplete#enable_at_startup = 1
inoremap <expr> <leader> pumvisible() ? "\<C-n>" : "\<leader>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled = 1

" different cursor shape in different modes
if exists('$TMUX')
  " changes take effect tmux wide (not confined to the vim pane).
  " Fix possible by having a setting in ~/.tmux.conf
  " https://gist.github.com/andyfowler/1195581#gistcomment-1190742
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_SR = "\<Esc>]50;CursorShape=2\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Source custom .vimrc
if filereadable(expand('~/.custom.vimrc'))
  source ~/.custom.vimrc
endif

" Netrw
"let g:netrw_banner = 0
"let g:netrw_winsize = 25
"let g:netrw_liststyle = 3
"let g:netrw_browse_split = 4
"let g:netrw_altv = 1

"noremap <leader>1 :Lexplore<CR>

"augroup netrw_mapping
"    autocmd!
"    autocmd filetype netrw call NetrwMapping()
"augroup END

"function! NetrwMapping()
"    noremap <buffer> u k
"endfunction

