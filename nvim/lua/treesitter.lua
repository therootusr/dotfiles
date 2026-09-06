-- On 0.12 the *core* does highlighting (vim.treesitter.start); the plugin only
-- supplies parsers + queries. Declared in lua/plugins.lua.
--
-- Needs a C compiler + git, both present.
--
-- Our explicit parser set (the `ensure_installed` equivalent). Parsers already
-- on disk are a local no-op -- no network, no recompile. :wait() makes the
-- one-time compile finish before we start opening files. Nothing outside this
-- list is ever installed.

require("nvim-treesitter").install({
  -- languages in the tree
  "c", "cpp", "go", "gomod", "gowork", "python", "bash", "proto", "java",
  -- nvim's own languages (config editing, reading :help, writing queries)
  "lua", "vim", "vimdoc", "query",
  -- build systems
  "starlark", "cmake", "make",
  -- data / config formats
  "yaml", "json", "toml", "gotmpl",
  -- git buffers -- makes commit messages, rebase todos and diffs readable
  "diff", "gitcommit", "git_rebase",
  -- docs, plus TODO/FIXME highlighting inside comments of every language
  "markdown", "markdown_inline", "comment",
}):wait(600000)

-- bzl filetype (BUILD, BUILD.bazel, *.bzl) uses the starlark parser.
vim.treesitter.language.register("starlark", "bzl")

-- Enable highlighting for any buffer whose parser we installed. start()
-- derives the language from the filetype (the plugin maps sh -> bash itself);
-- pcall means an un-installed filetype falls back to default syntax
-- highlighting.
-- b:bigfile is set by the guard added in a later phase; harmless until then.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if vim.b[ev.buf].bigfile then return end
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-------------------------------------------------------------------------------
-- nvim-treesitter-textobjects
-------------------------------------------------------------------------------

-- Semantic textobjects and function/type motions. The base plugin ships no
-- textobjects.scm, so these queries come from nvim-treesitter-textobjects.
--
-- lookahead: if the cursor isn't inside a match, search forward for the next
-- one. Default is false, which makes `vaf` fail unless you're already inside
-- the function. move.set_jumps is already true by default, so it's not set here.
require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },   -- jump fwd to next obj if not inside one
})

-- Textobjects: usable after an operator (`daf`) or in visual mode (`vaf`).
-- f, c, a, i are all unmapped in keymaps.lua, so these are free.
-- require() sits inside the callback so select.lua loads on first use rather
-- than at startup; require caches, so repeating it costs nothing.
for lhs, query in pairs({
  ["af"] = "@function.outer",
  ["if"] = "@function.inner",
  ["ac"] = "@class.outer",
  ["ic"] = "@class.inner",
  ["aa"] = "@parameter.outer",
  ["ia"] = "@parameter.inner",
}) do
  vim.keymap.set({ "x", "o" }, lhs, function()
    require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
  end, { desc = "Textobject " .. query })
end

-- Motions between functions and types -- this is what .move is for. The native
-- ]n / [n are visual-mode sibling-node moves, not function motions.
for lhs, spec in pairs({
  ["]f"] = { "goto_next_start",     "@function.outer", "Next function" },
  ["[f"] = { "goto_previous_start", "@function.outer", "Prev function" },
  ["]t"] = { "goto_next_start",     "@class.outer",    "Next class/type" },
  ["[t"] = { "goto_previous_start", "@class.outer",    "Prev class/type" },
}) do
  local fn, query, desc = spec[1], spec[2], spec[3]
  vim.keymap.set({ "n", "x", "o" }, lhs, function()
    require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
  end, { desc = desc })
end
