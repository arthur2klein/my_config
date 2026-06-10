-- Manual diff-review helpers, built on top of diffview.nvim.
--
-- The goal is a comfortable local code-review flow: diff against any
-- revision or range, edit while you review, mark files as reviewed, and
-- keep track of what is left. No remote service, no AI.
--
-- Reviewed-state is persisted on disk, keyed by repository + review base,
-- so closing and reopening Neovim (or diffview) keeps your progress.
--
-- Keymaps (all under the <leader>g git namespace):
--   <leader>gh  diffview: history of the current file
--   <leader>gl  diffview: history of the whole repository
--   <leader>gm  diffview: review the branch against its base (base...HEAD)
--   <leader>go  diffview: diff against a prompted revision/range
--   <leader>gx  toggle the current file as reviewed, then jump to next file
--   <leader>gs  review status: changed files with [x]/[ ] in the quickfix
--   <leader>gX  clear all reviewed marks for the current base
--
-- Commands:
--   :ReviewBase [rev]   show or set ghe revision to review against
--   :ReviewToggle       toggle the current file's reviewed mark
--   :ReviewStatus       quickfix list of changed files with reviewed marks
--   :ReviewReset        clear reviewed marks for the current base
--
-- Editing while reviewing:
--   In <leader>gd / <leader>gm / <leader>go the right-hand window IS the
--   real working tree file: edit it and `:w`, the diff against the left
--   (old) side updates live. <leader>gh (file history) shows past commits
--   and is read-only by nature; press `gf` on a file there (diffview's
--   default goto_file_edit) to open the real file, or `<C-w><C-f>` to open
--   it in a split next to the diff.

local M = {}

-- Cached review base (the revision the branch is reviewed against). When
-- nil it is auto-detected on first use.
M.base = nil

local function git_root()
  local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 or root == nil or root == "" then
    return nil
  end
  return root
end

local function current_branch()
  local branch = vim.fn.systemlist({ "git", "rev-parse", "--abbrev-ref", "HEAD" })[1]
  if vim.v.shell_error ~= 0 or branch == nil then
    return "HEAD"
  end
  return branch
end

-- Best-effort detection of the branch the current work should be reviewed against.
local function default_base()
  local head = vim.fn.systemlist({
    "git", "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD",
  })[1]
  if vim.v.shell_error == 0 and head and head ~= "" then
    return head
  end
  for _, candidate in ipairs({ "origin/master", "origin/main", "master", "main" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", candidate })
    if vim.v.shell_error == 0 then
      return candidate
    end
  end
  return "HEAD~1"
end

local function get_base()
  if not M.base then
    M.base = default_base()
  end
  return M.base
end

-- Repo-relative paths of every file changed between the base and HEAD.
local function changed_files()
  local files = vim.fn.systemlist({ "git", "diff", "--name-only", get_base() .. "...HEAD" })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  return files
end

----------------------------------------------------------------------------
-- Reviewed-state persistence.
----------------------------------------------------------------------------

local store_path = vim.fn.stdpath("state") .. "/diffreview.json"

local function load_store()
  local f = io.open(store_path, "r")
  if not f then
    return {}
  end
  local raw = f:read("*a")
  f:close()
  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= "table" then
    return {}
  end
  return decoded
end

local function save_store(store)
  local ok, encoded = pcall(vim.json.encode, store)
  if not ok then
    return
  end
  vim.fn.writefile({ encoded }, store_path)
end

-- Storage key: a review is scoped to "this repo, this branch, this base".
local function store_key()
  return table.concat({ git_root() or "?", current_branch(), get_base() }, "::")
end

-- Returns the reviewed set (path -> true) for the current key, and the
-- whole store so the caller can mutate and save.
local function reviewed_set()
  local store = load_store()
  local key = store_key()
  store[key] = store[key] or {}
  return store[key], store, key
end

----------------------------------------------------------------------------
-- Resolving the file under the cursor.
----------------------------------------------------------------------------

-- Repo-relative path of the file currently under review: the entry under
-- the cursor in a diffview, or the real file in the current buffer.
local function current_file()
  local ok, lib = pcall(require, "diffview.lib")
  if ok then
    local view = lib.get_current_view()
    if view and view.infer_cur_file then
      local entry = view:infer_cur_file()
      if entry and entry.path then
        return entry.path
      end
    end
  end

  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return nil
  end
  local root = git_root()
  local abs = vim.fn.fnamemodify(name, ":p")
  if root and abs:sub(1, #root + 1) == root .. "/" then
    return abs:sub(#root + 2)
  end
  return nil
end

local function advance_to_next_file()
  local ok, actions = pcall(require, "diffview.actions")
  if ok and type(actions.select_next_entry) == "function" then
    pcall(actions.select_next_entry)
  end
end

----------------------------------------------------------------------------
-- Public actions.
----------------------------------------------------------------------------

local function toggle_reviewed()
  if not git_root() then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  local path = current_file()
  if not path then
    vim.notify("No reviewable file under the cursor", vim.log.levels.WARN)
    return
  end

  local reviewed, store, key = reviewed_set()
  local now_reviewed
  if reviewed[path] then
    reviewed[path] = nil
    now_reviewed = false
  else
    reviewed[path] = true
    now_reviewed = true
  end
  store[key] = reviewed
  save_store(store)

  local total = #changed_files()
  local done = 0
  for _ in pairs(reviewed) do
    done = done + 1
  end
  vim.notify(
    string.format("%s %s  (%d/%d reviewed)", now_reviewed and "✓" or "○", path, done, total),
    vim.log.levels.INFO
  )

  if now_reviewed then
    advance_to_next_file()
  end
end

local function review_status()
  if not git_root() then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  local files = changed_files()
  if #files == 0 then
    vim.notify("No changes against " .. get_base(), vim.log.levels.INFO)
    return
  end

  local reviewed = reviewed_set()
  local root = git_root()
  local items = {}
  local done = 0
  for _, path in ipairs(files) do
    local mark = reviewed[path] and "[x]" or "[ ]"
    if reviewed[path] then
      done = done + 1
    end
    table.insert(items, {
      filename = root .. "/" .. path,
      lnum = 1,
      col = 1,
      text = mark .. " " .. path,
    })
  end

  vim.fn.setqflist({}, " ", {
    title = string.format("Review %s (%d/%d reviewed)", get_base(), done, #files),
    items = items,
  })
  vim.cmd("copen")
end

local function review_reset()
  local _, store, key = reviewed_set()
  store[key] = nil
  save_store(store)
  vim.notify("Cleared reviewed marks for " .. key, vim.log.levels.INFO)
end

local function set_base(rev)
  if rev == nil or rev == "" then
    vim.notify("Review base: " .. get_base(), vim.log.levels.INFO)
    return
  end
  M.base = rev
  vim.notify("Review base set to " .. rev, vim.log.levels.INFO)
end

----------------------------------------------------------------------------
-- Commands.
----------------------------------------------------------------------------

vim.api.nvim_create_user_command("ReviewBase", function(opts)
  set_base(opts.args)
end, { nargs = "?", desc = "Show or set the revision to review against" })

vim.api.nvim_create_user_command("ReviewToggle", toggle_reviewed, {
  desc = "Toggle the current file's reviewed mark",
})

vim.api.nvim_create_user_command("ReviewStatus", review_status, {
  desc = "Quickfix list of changed files with reviewed marks",
})

vim.api.nvim_create_user_command("ReviewReset", review_reset, {
  desc = "Clear reviewed marks for the current base",
})

----------------------------------------------------------------------------
-- Keymaps.
----------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gh", function()
  vim.cmd("DiffviewFileHistory %")
end, { desc = "Diffview: current file history" })

vim.keymap.set("n", "<leader>gl", function()
  vim.cmd("DiffviewFileHistory")
end, { desc = "Diffview: repository history" })

vim.keymap.set("n", "<leader>gm", function()
  vim.cmd("DiffviewOpen " .. get_base() .. "...HEAD")
end, { desc = "Diffview: review branch against base" })

vim.keymap.set("n", "<leader>go", function()
  vim.ui.input({ prompt = "Diff against (rev or range): " }, function(input)
    if input and input ~= "" then
      vim.cmd("DiffviewOpen " .. input)
    end
  end)
end, { desc = "Diffview: diff against a revision/range" })

vim.keymap.set("n", "<leader>gx", toggle_reviewed, { desc = "Review: toggle file reviewed" })
vim.keymap.set("n", "<leader>gs", review_status, { desc = "Review: status (quickfix)" })
vim.keymap.set("n", "<leader>gX", review_reset, { desc = "Review: clear reviewed marks" })

return {}
