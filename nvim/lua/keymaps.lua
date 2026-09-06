-- Ported 1:1 from vim/workman.map.vimrc (Workman layout).
-- vim `noremap` = all modes (normal/visual/op-pending/select);
--     `nnoremap` = normal only.
local function noremap(lhs, rhs) vim.keymap.set("", lhs, rhs) end
local function nnoremap(lhs, rhs) vim.keymap.set("n", lhs, rhs) end

-- write / quit
noremap("<leader>x", ":q!<CR>")
noremap("<leader>q", ":q<CR>")
noremap("<leader>s", ":w<CR>")
noremap("<leader><leader>s", ":wq<CR>")

-- motion (Workman home row: u/e/n/o = up/down/left/right)
noremap("u", "k")
noremap("e", "j")
noremap("n", "h")
noremap("o", "l")
noremap("N", "o")
noremap("k", "u")
noremap("K", "<C-r>")
noremap("0", "^")
noremap("^", "0")
noremap("'", "`")

-- search
noremap("s", "*")
noremap("S", "#")
noremap("h", "f")
noremap("H", "F")
noremap("gs", '"jye/<C-r>j<CR>')
noremap("gS", '"jy$/<C-r>j<CR>')
noremap("#", '"jyy/<C-r>j<CR>')
noremap("l", "//<CR>")
noremap("L", "??<CR>")
noremap(">", "yiwq/p<CR>")

-- quickfix (Telescope/LSP supersede later)
noremap("<C-n>", ":cn<CR>")
noremap("<C-p>", ":cp<CR>")

-- buffers (Space prefix; fzf switcher planned Phase 7)
noremap("<Space>!", ":ls!<CR>")
noremap("<Space>d", ":bp<CR>:bd #<CR>")
noremap("<Space>u", ":vert sbprevious<CR>")
noremap("<Space>n", ":bprevious<CR>")
noremap("<Space>\\", ":vert sbnext<CR>")
noremap("<Space>-", ":sbnext<CR>")
noremap("<Space>o", ":bnext<CR>")
noremap("<Space>g", "<C-^>")
noremap("<Space>s", "<C-W>^<C-W>H")

-- windows (leader = Tab): lowercase = focus, uppercase = move
noremap("<leader>w", "<C-w>")
noremap("<leader>e", "<C-w><C-j>")
noremap("<leader>u", "<C-w><C-k>")
noremap("<leader>n", "<C-w><C-h>")
noremap("<leader>o", "<C-w><C-l>")
noremap("<leader>E", "<C-w><C-J>")
noremap("<leader>U", "<C-w><C-K>")
noremap("<leader>O", "<C-w><C-L>")
noremap("<leader><leader>w", "<C-W>T")
noremap("<leader>wV", "<C-w>H")
noremap("<leader>wH", "<C-w>K")
noremap("<leader>wh", "<C-w>s")
noremap("<leader>ws", "<C-w>v")
noremap("<leader>wv", ":vnew<CR>")
noremap("<leader>wt", ":vert sf ")

-- tabs
noremap("<leader>N", ":tabnew ")
noremap("<leader>h", ":tabnext<CR>")
noremap("<leader>a", ":tabprev<CR>")

-- misc / edit
noremap("gp", "a<C-r>0<Esc>")
noremap("<leader>p", "ciw<C-r>0<Esc>")
nnoremap("<leader>/", ":%s/<C-r><C-w>//ng<CR>")
noremap("<leader>y", '"+y')
nnoremap("<leader>Y", 'mpgg"+yG`p')
noremap("<leader>l", ":set noma<CR>")
noremap("<leader>L", ":set ma<CR>")
noremap("<leader><Space>", ":set list!<CR>")
noremap("cm", ":sh<CR>")

-- shadow

-- Disabled builtins. gh / gH / g<C-h> start Select mode -- a mode this
-- config never uses, and gh is wanted as the git prefix (see git.lua).
-- These are builtins, not mappings, so there is nothing to unmap;
-- <Nop> shadows them. They still work as prefixes: ghs matches the longer
-- mapping, while bare gh times out into <Nop> instead of entering Select mode.
noremap("gh", "<Nop>")
noremap("gH", "<Nop>")
noremap("g<C-h>", "<Nop>")
