local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true   -- 24-bit color (tmux must pass it through)

-- Two sign columns: gitsigns (2-char signs) and diagnostics compete for the
-- same gutter, and diagnostics have higher priority (10 vs 6), so with a
-- single column an error silently hides the git sign on that line.
opt.signcolumn = "yes:2" -- reserve the gutter so diagnostics don't shift txt

opt.undofile = true        -- persistent undo across sessions
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 5
opt.autoread = true

opt.cursorline = true
opt.colorcolumn = "80"
opt.list = true
opt.listchars = { tab = "> ", trail = "-", extends = ">", precedes = "<", nbsp = "+" }
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 2
opt.softtabstop = 2
opt.wrap = true
opt.linebreak = true
opt.textwidth = 0
opt.switchbuf = "useopen"
opt.wrapscan = false

-- opt.confirm = true          -- prompt on :q with unsaved changes instead of failing
opt.updatetime = 250        -- CursorHold-driven features feel responsive
opt.timeoutlen = 1000       -- default; leader chords need the room
opt.spelloptions = "camel"  -- split camelCase into words
vim.g.clipboard = "osc52"
