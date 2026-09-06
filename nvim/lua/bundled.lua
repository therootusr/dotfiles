-- nvim/lua/bundled.lua
-- Plugins nvim ships but does not load by default (:h standard-plugin-list).

-- Interactive undo tree over edit history. Replaces undotree.nvim outright.
vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<leader>tu", function()
  require("undotree").open()
end, { desc = "Toggle undotree" })
