set nocompatible
set hidden
filetype off

syntax on
"color scheme
:color desert
:hi Comment ctermfg=grey
:hi Folded ctermbg=Blue ctermfg=White
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

" set spell
set spell spelllang=en

" Set spellfile to local file if present
let workman_basic_vimrc_dir = expand('<sfile>:p:h')
let local_spellfile = workman_basic_vimrc_dir . '/vim-spellfile.en.utf-8.add'
if filereadable(local_spellfile)
  let &spellfile = local_spellfile
endif

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

  " format code noremap
  " (unlike ":%!clang-format" doesn't add to undo/redo change list)
  autocmd Filetype cpp noremap <buffer> <leader>f :!clang-format -i --style=file --fallback-style=google %<CR><CR>

  " code dispatch noremap; #run
  autocmd Filetype python noremap <buffer> <leader>r :vert rightb term python3 %<CR>
  autocmd Filetype go noremap <buffer> <leader>r :vert rightb term go run %<CR>
  autocmd Filetype cpp noremap <buffer> <leader>r :!g++ --std=c++17 -o %.out %<CR> :vert rightb term ./%.out<CR>
  autocmd Filetype cpp noremap <buffer> <leader><leader>r :!g++ -g --std=c++17 -o %.out %<CR> :vert rightb term ./%.out<CR>

  " Auto mkview and loadview
  autocmd BufWinLeave *
  \ if expand('%') != '' && &buftype !~ 'nofile'
  \|  mkview
  \|endif

  autocmd BufRead *
  \ if expand('%') != '' && &buftype !~ 'nofile'
  \|  silent loadview
  \|endif

  autocmd BufWritePost * :redraw!

  " Disable spell check for help files
  autocmd FileType help setlocal nospell
augroup END

" commands
command FormatJSON %!python -m json.tool

" noremap
noremap u k
noremap n h
noremap e j
noremap o l
noremap l o
noremap L O
noremap k u
noremap 0 ^
noremap h e
noremap ^ 0
noremap ' `
noremap K <C-r>

noremap <leader>l :set noma<CR>
noremap <leader>L :set ma<CR>
noremap <leader>f :set ic!
noremap <leader><space> :set list!<CR>
noremap ` :sh<CR>

" noremap search
noremap s *
noremap S #
" , -> always to next match and not relative to direction from '#/s'
noremap , //<CR>
noremap < ??<CR>
noremap > yiwq/p<CR>

" noremap w anad q
noremap <leader>x :q!<CR>
noremap <leader>q :q<CR>
noremap <leader>s :w<CR>
noremap <leader><leader>s :wq<CR>

" noremap quickfix
noremap <C-n> :cn<CR>
noremap <C-p> :cp<CR>

" noremap buffers
noremap <expr>j ":<C-U>".nr2char(getchar())."b<CR>"
noremap jb :ls<CR>
noremap j! :ls!<CR>
" noremap jd :bp<bar>sp<bar>bn<bar>bd<CR>
noremap jd :bp<CR>:bd #<CR>
noremap ju :vert sbprevious<CR>
noremap jn :bprevious<CR>
noremap j\ :vert sbnext<CR>
noremap j- :sbnext<CR>
noremap jo :bnext<CR>
noremap jg <C-^>
noremap js <C-W>^<C-W>H

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
" inoremap hh <ESC>
nnoremap <leader>/ :%s/<c-r><c-w>//ng<cr>
" vnoremap <leader>/ :<c-u>%s/<c-r>*//ng<cr>
nnoremap <leader>y "+y
nnoremap <leader>Y mpgg"+yG`p

" macros
let @p = "a \<Esc>p"

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
