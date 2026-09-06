-- Plugin declarations. vim.pack is nvim 0.12's built-in manager (:h vim.pack).
-- add() blocks until each plugin is cloned and on runtimepath, so a require()
-- after this returns is safe on a cold first launch.
--
-- Managing them:
--   :lua vim.pack.update()                     download, review diff, :w to accept
--   :lua vim.pack.update(nil, {offline=true})  inspect without network
--   :lua vim.pack.del({ 'name' })              remove (after deleting its spec)
--   :restart  /  ZR                            reload nvim

local function gh(repo) return "https://github.com/" .. repo end

-- Generic build hook: any spec carrying data.build gets it run on
-- install/update. Must be registered before add().
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local build = vim.tbl_get(ev.data, "spec", "data", "build")
    if build and (ev.data.kind == "install" or ev.data.kind == "update") then
      vim.system(build, { cwd = ev.data.path }):wait()
    end
  end,
})

vim.pack.add({
  -- Parsers + queries. `main` is the live branch; `master` is frozen for 0.11.
  { src = gh("nvim-treesitter/nvim-treesitter"),             version = "main" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },

  -- Used purely as a data source of lsp/<server>.lua defaults.
  -- nvim 0.12 ships none of its own. No setup() call needed.
  { src = gh("neovim/nvim-lspconfig"), version = "master" },

  -- Fuzzy finding. plenary is telescope's dependency; fzf-native is the C
  -- sorter that replaces telescope's Lua one.
  { src = gh("nvim-lua/plenary.nvim"), version = "master" },
  { src = gh("nvim-telescope/telescope.nvim"), version = "master" },
  {
    src = gh("nvim-telescope/telescope-fzf-native.nvim"),
    data = { build = { "make" } },
    version = "main",
  },

  { src = gh("lewis6991/gitsigns.nvim"), version = "main" },
})

