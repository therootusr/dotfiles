" noremap w anad q
noremap <leader>x :q!<CR>
noremap <leader>q :q<CR>
noremap <leader>s :w<CR>
noremap <leader><leader>s :wq<CR>

" noremap motion
noremap u k
noremap n h
noremap e j
noremap o l
noremap N o
noremap k u
noremap 0 ^
noremap ^ 0
noremap ' `
noremap K <C-r>

" noremap search
noremap s *
noremap S #
" noremap gs "jyeq/"jp<CR>
noremap gs "jye/<C-r>j<CR>
noremap gS "jy$/<C-r>j<CR>
noremap # "jyy/<C-r>j<CR>
noremap h f
noremap H F

" , -> always to next match and not relative to direction from '#/s'
" noremap , //<CR> " , is dead
noremap l //<CR>
noremap L ??<CR>
noremap > yiwq/p<CR>

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
" nnoremap <leader>y "+y
noremap <leader>y "+y
nnoremap <leader>Y mpgg"+yG`p

noremap <leader>l :set noma<CR>
noremap <leader>L :set ma<CR>
noremap <leader>f :set ic!
noremap <leader><space> :set list!<CR>
" noremap ` :sh<CR>
noremap cm :sh<CR>
