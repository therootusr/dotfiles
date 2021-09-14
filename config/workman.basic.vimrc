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

" Source mappings now!
if filereadable(expand('~/.map.vimrc'))
  source ~/.map.vimrc
endif

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
