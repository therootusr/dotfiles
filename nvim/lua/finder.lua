-- Telescope. Plugins declared in lua/plugins.lua;
-- telescope-fzf-native is compiled by the PackChanged hook there.

local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    -- vimgrep_arguments NOT set. Telescope's default is already
    --   rg --color=never --no-heading --with-filename --line-number --column --smart-case
    -- Verified: it skips .gitignore'd dirs, skips hidden files, and does not
    -- follow symlinks. Correct as-is.
    path_display = { "truncate" },
    sorting_strategy = "ascending",       -- best match at the top...
    layout_config = { prompt_position = "top" },

    mappings = {
      i = {
        ["<C-e>"] = actions.preview_scrolling_down,
        ["<C-d>"] = false,  -- :h telescope.mappings -- false unmaps a default

        -- smart_ sends the multi-selection if there is one, else all results.
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
      },
      n = {
        ["<C-e>"] = actions.preview_scrolling_down,
        ["<C-d>"] = false,

        -- Global e/u are noremap, so they feed the builtin j/k (raw cursor)
        -- rather than telescope's buffer-local selection actions.
        ["e"] = actions.move_selection_next,
        ["u"] = actions.move_selection_previous,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
      },
    },
  },

  pickers = {
    -- hidden=true makes telescope append --hidden itself (__files.lua:323),
    -- so it must NOT be in the list below.
    -- -g '!.git' excludes .git/, which --hidden would otherwise pull in.
    --   glob_pattern is a live_grep option, not a find_files one
    --   The full cmd is the only way to get dotfiles WITHOUT .git internals.
    find_files = {
      hidden = true,
      -- rg beats telescope's default `find` walk by a wide margin.
      find_command = { "rg", "--files", "--color", "never", "--glob", "!.git" },
    },
    buffers = { sort_mru = true, ignore_current_buffer = true },
  },

  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,   -- both required, or the C sorter is
      override_file_sorter = true,      -- registered but never used
      case_mode = "smart_case",
    },
  },
})
telescope.load_extension("fzf")

----------------------------------- Keymaps -----------------------------------
-- Prefix is `gt`. This shadows builtin gt (next tab page), but only after a
-- timeoutlen pause -- bare gt still works, and <leader>h/<leader>a are your
-- real tab keys anyway.
local b = require("telescope.builtin")
local function map(lhs, fn, desc)
  vim.keymap.set("n", lhs, fn, { desc = "Find: " .. desc })
end

-- Files. git_files is primary: `git ls-files` is one index read rather than a
-- walk of some monorepo. It errors outside a git repo -- that's what gtF is for.
map("gtf", b.git_files,  "files (git-tracked)")
map("gtF", b.find_files, "files (all, via rg)")
map("gtb", b.buffers,    "buffers")
map("gto", b.oldfiles,   "recent files (MRU)")

-- Content
map("gtg", b.live_grep,   "live grep")
map("gtw", b.grep_string, "grep word under cursor")
map("gtr", b.resume,      "resume last picker")

-- LSP results. These OVERRIDE the 0.11 defaults and the maps in lsp.lua --
-- finder.lua loads later, so it wins. In a monorepo, references on a common
-- symbol return thousands of hits; a picker lets you filter them live against
-- a preview, which a static quickfix list cannot.
map("grr", b.lsp_references,      "LSP references")
map("gri", b.lsp_implementations, "LSP implementations")
map("gO",  b.lsp_document_symbols, "LSP symbols (file)")
map("gts", b.lsp_dynamic_workspace_symbols, "LSP symbols (workspace)")

-- Meta
map("gtd", b.diagnostics, "diagnostics")
map("gtq", b.quickfix,    "quickfix list")
map("gth", b.help_tags,   "help tags")
map("gtk", b.keymaps,     "keymaps")
map("gtc", b.commands,    "commands")
