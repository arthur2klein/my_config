-- Git: signs (gitsigns), diff/merge views (diffview), conventional
-- commits (convcommit) and merge-conflict navigation.
--
-- Local-review helpers (diff against any revision, mark files reviewed)
-- live in review.lua, also under the <leader>g namespace.
--
-- Keymaps:
--   <leader>gb   blame the current line
--   <leader>gB   blame the whole buffer
--   <leader>gd   open diffview on the uncommitted changes
--   <leader>gc   close diffview
--   <leader>gg   create a conventional commit
--   <leader>gv   create a version tag (changelog stored in the tag message;
--                staging pre-release "-<branch>.<n>" off the default branch)
--   <leader>gV   rebuild the changelog from tag messages (scratch buffer)
--   <leader>gp   push (refuses if git-tracked buffers are unsaved)
--   <leader>ga   git add
--   <leader>gn   jump to the next merge-conflicted file
--
-- Hunks (gitsigns, buffer-local):
--   ]h / [h      next / previous hunk
--   <leader>hs   stage hunk (visual: stage selected lines)
--   <leader>hr   reset hunk (visual: reset selected lines)
--   <leader>hS   stage the whole buffer
--   <leader>hR   reset the whole buffer
--   <leader>hu   undo the last hunk stage
--   <leader>hp   preview the hunk in a popup
--   <leader>hd   diff the buffer against the index
--   <leader>hD   diff the buffer against the last commit
--   <leader>ht   toggle showing deleted lines inline
--
-- Commands: CheckModifiedGitBuffers, NextConflictFile.

local function is_git_tracked(filepath)
  local handle = io.popen("git ls-files --error-unmatch " .. vim.fn.shellescape(filepath) .. " 2>/dev/null")
  if handle == nil then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

local function check_modified_git_buffers()
  local modified_git_buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
      local filepath = vim.api.nvim_buf_get_name(bufnr)
      if filepath ~= "" and is_git_tracked(filepath) then
        table.insert(modified_git_buffers, filepath)
      end
    end
  end

  if #modified_git_buffers > 0 then
    print("Modified Git-tracked files:")
    for _, path in ipairs(modified_git_buffers) do
      print(" - " .. path)
    end
    return true
  end
  return false
end

vim.api.nvim_create_user_command("CheckModifiedGitBuffers", check_modified_git_buffers, {})

local function open_next_conflict_file()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or root == nil or root == "" then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local files = vim.fn.systemlist({ "git", "-C", root, "diff", "--name-only", "--diff-filter=U" })
  if vim.v.shell_error ~= 0 or #files == 0 then
    vim.notify("No conflicted files", vim.log.levels.INFO)
    return
  end

  local current = vim.api.nvim_buf_get_name(0)
  local target_index = 1
  for i, rel in ipairs(files) do
    if root .. "/" .. rel == current then
      target_index = (i % #files) + 1
      break
    end
  end

  vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. files[target_index]))
end

vim.api.nvim_create_user_command("NextConflictFile", open_next_conflict_file, {})
vim.keymap.set("n", "<leader>gn", open_next_conflict_file, { desc = "Open next conflicted file" })

return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Hunk navigation. ]c / [c are diagnostics (see lsp.lua), so hunks
          -- live on ]h / [h. Fall back to native diff motions inside diffview.
          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gitsigns.nav_hunk("next")
            end
          end, "Next hunk")
          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end, "Previous hunk")

          -- Stage / reset hunks (visual mode acts on the selected lines).
          map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
          map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
          map("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Stage selected lines")
          map("v", "<leader>hr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Reset selected lines")
          map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
          map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
          map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo stage hunk")

          -- Inspect.
          map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
          map("n", "<leader>hd", gitsigns.diffthis, "Diff this (vs index)")
          map("n", "<leader>hD", function()
            gitsigns.diffthis("~")
          end, "Diff this (vs last commit)")
          map("n", "<leader>ht", gitsigns.toggle_deleted, "Toggle deleted lines")
        end,
      })
      vim.keymap.set("n", "<leader>gb", function()
        vim.cmd("Gitsigns blame_line")
      end, { desc = "Blame current line" })
      vim.keymap.set("n", "<leader>gB", function()
        vim.cmd("Gitsigns blame")
      end, { desc = "Blame whole buffer" })
    end,
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({})
      vim.keymap.set("n", "<leader>gd", function()
        vim.cmd("DiffviewOpen")
      end, { desc = "Open diffview (uncommitted)" })
      vim.keymap.set("n", "<leader>gc", function()
        vim.cmd("DiffviewClose")
      end, { desc = "Close diffview" })
    end,
  },
  {
    "arthur2klein/convcommit",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "rcarriga/nvim-notify",
    },
    branch = "master",
    config = function()
      local convcommit = require("convcommit")
      convcommit.setup({ validate_input_key = "<CR>" })
      vim.keymap.set("n", "<leader>gg", convcommit.create_commit, { desc = "Create conventional commit" })
      vim.keymap.set("n", "<leader>gv", convcommit.create_version_tag, { desc = "Create version tag" })
      vim.keymap.set("n", "<leader>gV", convcommit.generate_changelog, { desc = "Rebuild changelog from tags" })
      vim.keymap.set("n", "<leader>gp", function()
        if not check_modified_git_buffers() then
          convcommit.push()
        end
      end, { desc = "Push (guard unsaved buffers)" })
      vim.keymap.set("n", "<leader>ga", convcommit.git_add, { desc = "Git add" })
    end,
  },
  "kshenoy/vim-signature",
}
