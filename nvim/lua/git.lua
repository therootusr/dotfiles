-- Git integration: native diff settings, gitsigns for in-buffer hunk work,
-- telescope's git pickers for status/history.
-- Requires finder.lua to have loaded (uses telescope.builtin).

---------------------- Native diff rendering (no plugin) ----------------------

-- 0.12 default is:
--   internal,filler,closeoff,indent-heuristic,inline:char,linematch:40
-- Two values are worth changing, and diffopt REPLACES rather than merges, so
-- the whole list is restated.
--   inline:word  -- word-wise intra-line diff, merging gaps of <=5 non-word
--                   bytes, so a rename reads as one change not confetti
--   linematch:60 -- align changed line blocks more aggressively than 40
vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "indent-heuristic",
  "inline:word",
  "linematch:60",
}

-- Bundled, not loaded by default.
-- :DiffTool {left} {right} -- side-by-side file AND directory diffing with
-- rename detection (:h difftool).
vim.cmd.packadd("nvim.difftool")

------------------------------ Keymap namespace -------------------------------
-- Change this 1 line to move every git command. "gh" defaults to Select mode.
-- bare gh still fires after a timeoutlen pause, since nvim falls back when no
-- longer mapping completes.
-- local X = "gh"

---------------- gitsigns: hunks in the gutter, staging, blame ----------------
require("gitsigns").setup({
  signs = {
    add          = { text = "+" },
    change       = { text = "~" },
    topdelete    = { text = "‾" },
    delete       = { text = "_" },
    changedelete = { text = "≃" },
    untracked    = { text = "┆" },
  },

  signs_staged = {
    add          = { text = "++" },
    change       = { text = "~~" },
    topdelete    = { text = "▔▔" },
    delete       = { text = "▁▁" },
    changedelete = { text = "≃≃" },
  },

  current_line_blame = false,   -- always-on is distracting; toggled below
  current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
  preview_config = { border = "rounded" },

  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Git: " .. desc })
    end

    -- ]h joins the bracket family:
    --   ]d diagnostics, ]f functions, ]t types, ]n treesitter siblings.
    map("n", "]h", function() gs.nav_hunk("next") end, "next hunk")
    map("n", "[h", function() gs.nav_hunk("prev") end, "prev hunk")

    -- Hunk as a textobject: `dih` deletes the hunk under the cursor.
    map({ "o", "x" }, "ih", gs.select_hunk, "hunk textobject")

    -- `gha` toggles: on an unstaged sign it stages, on a staged sign, unstages
    map("n", "ghp", gs.preview_hunk, "preview hunk")
    map("n", "gha", gs.stage_hunk,   "stage / unstage hunk")
    map("n", "ghr", gs.reset_hunk,   "reset hunk")
    map("n", "ghA", gs.stage_buffer, "stage whole buffer")
    map("n", "ghR", gs.reset_buffer, "reset whole buffer")

    -- Visual mode stages or resets only the selected lines
    -- partial-hunk staging, i.e. `git add -p` case that actually matters.
    map("x", "gha", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "stage selected lines")
    map("x", "ghr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "reset selected lines")

    map("n", "ghB", function() gs.blame_line({ full = true }) end, "blame line")
    map("n", "ghb", gs.toggle_current_line_blame,                  "toggle inline blame")
    map("n", "ghd", gs.diffthis,                                   "diff vs index")
    map("n", "ghD", function() gs.diffthis("~") end,               "diff vs HEAD~")
    map("n", "ghw", gs.toggle_word_diff,                           "toggle word diff")
  end,
})

---------------------------- Telescope git pickers ----------------------------
-- git_bcommits lists commits for current buffer WITH a diff preview,
-- and inside it <C-v>/<C-x>/<C-t> open that diff in a split or tab.
-- git_status stages/unstages with <Tab> and opens with <CR>.
local b = require("telescope.builtin")
local function map(lhs, fn, desc)
  vim.keymap.set("n", lhs, fn, { desc = "Git: " .. desc })
end

map("ghs", b.git_status,   "status (<Tab> stages)")
map("ghl", b.git_commits,  "log (repo commits)")
map("ghL", b.git_bcommits, "log (this file, diff preview)")
map("ghc", b.git_branches, "branches (checkout)")

-- lazygit covers the multi-file review and arbitrary-revision-range cases
-- gitsigns cannot. It already renders through delta via
-- git/delta/delta.gitconfig:2-8, so diffs match the command line.
map("ghg", function()
  vim.cmd("tabnew | terminal lazygit")
  vim.cmd("startinsert")
end, "lazygit (new tab)")
