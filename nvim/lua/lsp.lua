-- LSP is core in 0.12 (vim.lsp.config / vim.lsp.enable). nvim-lspconfig is
-- installed only to supply lsp/<server>.lua defaults -- no setup() call.
--
-- Merge order, most specific winning per key (:h lsp-config):
--   1. lsp/<name>.lua on runtimepath   (nvim-lspconfig)
--   2. vim.lsp.config('*', {...})      (our base, below)
--   3. vim.lsp.config('<name>', {...}) (our per-server overrides)

-- Safety net for any server whose config forgets root_markers.
vim.lsp.config("*", {
  root_markers = { ".git" },
})

-------------------------------------------------------------------------------
-- Go
-------------------------------------------------------------------------------

vim.lsp.config("gopls", {
  -- No root_markers here: nvim-lspconfig's lsp/gopls.lua defines root_dir as a
  -- function, and root_markers is "unused if root_dir is defined"
  -- (:h lsp-root_markers). Its function does go.work -> go.mod -> .git in
  -- priority order AND reuses the existing client for files under $GOROOT/src
  -- or $GOMODCACHE, which static markers can't express.
  settings = {
    gopls = {
      -- Never walk into Bazel's output symlinks -- they point into
      -- ~/.cache/bazel and hold generated copies of the whole tree.
      -- Inert in repos that have no such directories.
      directoryFilters = {
        "-bazel-bin", "-bazel-out", "-bazel-main", "-bazel-testlogs",
        "-3party", "-node_modules",
      },
      staticcheck = true,
      analyses = {
        unusedparams = true,
        unusedwrite = true,
        nilness = true,
        useany = true,
      },
      -- Rendered only when inlay hints are switched on (keymap below).
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      usePlaceholders = true,     -- fill argument placeholders on completion
      completeUnimported = true,  -- complete symbols from packages not yet imported
    },
  },
})
vim.lsp.enable("gopls")


-------------------- gopls: keymaps --------------------

-- gopls exposes goimports as a code action, not as formatting.
vim.keymap.set("n", "<leader>ci", function()
  vim.lsp.buf.code_action({
    context = { only = { "source.organizeImports" } },
    apply = true,
  })
end, { desc = "LSP: organize imports" })

-- Inlay hints shift text sideways, so keep them on a toggle.
vim.keymap.set("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Format on save --
-- gopls implements textDocument/formatting as gofmt, so no formatter plugin
-- is needed.
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.go",
--   callback = function(ev)
--     vim.lsp.buf.format({ bufnr = ev.buf, timeout_ms = 3000 })
--   end,
-- })

-------------------------------------------------------------------------------
-- clangd
-------------------------------------------------------------------------------

vim.lsp.config("clangd", {
  -- cmd REPLACES lspconfig's list wholesale (lists don't deep-merge), so
  -- "clangd" itself has to be element one. All flags verified present in
  -- clangd 22.1.6 via `clangd --help`.
  cmd = {
    "clangd",
    "--background-index",           -- index the project in the background
    "--clang-tidy",                 -- inline clang-tidy diagnostics
    "--completion-style=detailed",
    "--header-insertion=never",     -- auto-inserted #includes are usually wrong
    "--pch-storage=memory",         -- faster; costs RAM
    -- "--all-scopes-completion",   -- offer symbols from not-yet-included headers
    "-j", "4",                      -- async workers, and background-index threads
  },
  -- REPLACE root_markers from lspconfig to control clangd root closely
  -- if needed (root_markers is a flat, ordered list :h lsp-root_markers).
  --
  -- lspconfig's lsp/clangd.lua negotiates "--offset-encoding"
  -- properly via capabilities.offsetEncoding + an on_init hook.
  --
  -- Not overriding filetypes either: lspconfig's covers objc/objcpp/cuda and
  -- the .doxygen variants, plus get_language_id mapping.
})
vim.lsp.enable("clangd")

-------------------- clangd: keymaps --------------------

-- clangd implements textDocument/formatting by running clang-format
-- internally, honouring the nearest .clang-format. This one call replaces the
-- whole FormatCpp() shell-out in vim/workman.basic.vimrc:81-91.
-- Unlike gopls, clangd DOES support range formatting -- so in visual mode this
-- formats only the selection.
vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  vim.lsp.buf.format({ timeout_ms = 3000 })
end, { desc = "LSP: format buffer or selection" })

-- switchSourceHeader is a clangd extension, not standard LSP. lspconfig wires
-- it to this buffer-local command for you.
vim.keymap.set("n", "<leader>ch", "<Cmd>LspClangdSwitchSourceHeader<CR>",
  { desc = "C++: switch source/header" })

-------------------------------------------------------------------------------
-- Protobuf
-------------------------------------------------------------------------------

-- Also nothing. lspconfig's lsp/buf_ls.lua already uses
-- `buf lsp serve --log-format=text` and adds a reuse_client function for
-- multi-workspace use -- both of which an explicit `cmd` override would throw
-- away, since lists replace rather than merge.
vim.lsp.enable("buf_ls")

-- buf's own config files aren't a filetype nvim detects. Registering them
-- makes buf_ls attach to them, and clears the health warning about the
-- unknown "buf-config" filetype in its filetypes list.
vim.filetype.add({
  filename = {
    ["buf.yaml"] = "buf-config",
    ["buf.gen.yaml"] = "buf-config",
    ["buf.lock"] = "buf-config",
  },
})
vim.treesitter.language.register("yaml", "buf-config")

-------------------------------------------------------------------------------
-- Python
-------------------------------------------------------------------------------

-------------------- Python: types + navigation --------------------

-- Replaceable with astral/ty?

-- lspconfig's lsp/basedpyright.lua already provides cmd, filetypes,
-- root_markers, autoSearchPaths, diagnosticMode, disableTaggedHints, and the
-- :LspPyrightOrganizeImports / :LspPyrightSetPythonPath commands.
-- `analysis` is a map, so these merge INTO theirs rather than replacing it.
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        -- "recommended" / "all" are extremely strict; noisy
        -- if the codebase wasn't written that way.
        typeCheckingMode = "standard",
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
        },
      },
    },
  },
})
vim.lsp.enable("basedpyright")

-------------------- Python: lint + format --------------------

-- Nothing to configure. lspconfig's lsp/ruff.lua already has
-- cmd = { "ruff", "server" }, filetypes and root_markers.
-- If you ever need ruff server options, they go under init_options.settings,
-- NOT settings.
vim.lsp.enable("ruff")

---------- Python: make 2 LSPs co-exist (ruff/basedpyright) ----------

-- ruff and basedpyright both attach to Python. basedpyright's hover is far
-- better (types, docstrings), so silence ruff's to avoid duplicate popups.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- Auto-triggered Completion (built-in, 0.12) ---------------------------------
vim.opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    end
  end,
})

-------------------------------------------------------------------------------
-- Keymaps
-------------------------------------------------------------------------------

-- 0.11+ already binds gra gri grn grr grt grx gO and insert-mode <C-s>.
-- g, r and O are unmapped in keymaps.lua, so those all survive untouched.
-- K is redo (keymaps.lua:20), so hover goes on <leader>k.
vim.keymap.set("n", "<leader>k", function()
  vim.lsp.buf.hover({ border = "rounded" })
end, { desc = "LSP: hover" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: definition" })
