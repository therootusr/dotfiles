-- Launched via `nvim -u <this>/init.lua` (no ~/.config/nvim).
-- -u doesn't add this dir to runtimepath, so do it ourselves — then require()/after/ resolve from the repo.
local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.runtimepath:prepend(here)
vim.opt.runtimepath:append(here .. "/after")

-- Must precede any <leader> mapping.
vim.g.mapleader = "\t"
vim.g.maplocalleader = "\t"

require("options")
require("bundled")
require("plugins")
require("treesitter")
require("lsp")
-- finder loads after lsp; its grr/gri/gO mappings need to win/override.
require("finder")
-- after finder; git.lua uses telescope.builtin
require("git")
require("keymaps")  -- last: can override plugin and default maps
