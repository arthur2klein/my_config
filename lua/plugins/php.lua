-- PHP-specific glue: branch-switch cache invalidation for intelephense.
--
-- Intelephense indexes the project on first attach and updates incrementally
-- after that. The index goes out of sync after a `git checkout` that moves
-- many files (renames, large diffs, version-bump branches). Restarting the
-- LSP forces a fresh scan; purging its cache forces a full rebuild from
-- scratch when even a restart misses a stale entry.

local M = {}

local intelephense_cache_dir = vim.fn.stdpath("cache") .. "/intelephense"

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "intelephense" })
end

local function restart_intelephense()
  local clients = vim.lsp.get_clients({ name = "intelephense" })
  if #clients == 0 then
    return false
  end
  for _, c in ipairs(clients) do
    vim.lsp.stop_client(c.id, true)
  end
  -- LspStart is provided by nvim-lspconfig; schedule so the stop completes
  -- before we re-attach.
  vim.defer_fn(function()
    pcall(vim.cmd, "LspStart intelephense")
  end, 200)
  return true
end

local function purge_intelephense_cache()
  local clients = vim.lsp.get_clients({ name = "intelephense" })
  for _, c in ipairs(clients) do
    vim.lsp.stop_client(c.id, true)
  end
  if vim.fn.isdirectory(intelephense_cache_dir) == 1 then
    local ok, err = pcall(vim.fn.delete, intelephense_cache_dir, "rf")
    if not ok then
      notify("Failed to delete cache: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    notify("Cache wiped at " .. intelephense_cache_dir)
  end
  vim.defer_fn(function()
    pcall(vim.cmd, "LspStart intelephense")
  end, 200)
end

-- One filesystem watcher per git dir; restart all matching LSPs when HEAD
-- changes. fs_event needs to be re-armed after each fire on some platforms.
local watchers = {}

local function arm_watcher(git_dir)
  if watchers[git_dir] then
    return
  end
  local head_path = git_dir .. "/HEAD"
  if vim.fn.filereadable(head_path) ~= 1 then
    return
  end
  local w = vim.uv.new_fs_event()
  if not w then
    return
  end
  watchers[git_dir] = w
  local ok = w:start(
    head_path,
    {},
    vim.schedule_wrap(function(err)
      watchers[git_dir] = nil
      pcall(function()
        w:stop()
        w:close()
      end)
      if err then
        return
      end
      local clients = vim.lsp.get_clients({ name = "intelephense" })
      if #clients > 0 then
        notify("Branch changed, restarting LSP")
        restart_intelephense()
      end
      -- Re-arm after a short delay so chained checkouts still trigger.
      vim.defer_fn(function()
        arm_watcher(git_dir)
      end, 500)
    end)
  )
  if not ok then
    watchers[git_dir] = nil
    pcall(function()
      w:close()
    end)
  end
end

local function setup_branch_watcher_for_buf(buf)
  local fname = vim.api.nvim_buf_get_name(buf)
  if fname == "" then
    return
  end
  local found = vim.fs.find(".git", { upward = true, path = vim.fs.dirname(fname) })[1]
  if not found then
    return
  end
  -- .git can be a directory (normal repo) or a file (worktree / submodule).
  local git_dir = found
  if vim.fn.isdirectory(found) == 0 then
    local ok_read, lines = pcall(vim.fn.readfile, found)
    if ok_read and lines[1] then
      local pointed = lines[1]:match("^gitdir:%s*(.+)$")
      if pointed then
        if pointed:sub(1, 1) ~= "/" then
          pointed = vim.fs.dirname(found) .. "/" .. pointed
        end
        git_dir = pointed
      end
    end
  end
  arm_watcher(git_dir)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function(args)
    setup_branch_watcher_for_buf(args.buf)
    -- PSR-12 / PhpStorm default. Only forced when the project ships no
    -- .editorconfig (Neovim's built-in editorconfig support otherwise wins).
    if vim.b[args.buf].editorconfig == nil or vim.tbl_isempty(vim.b[args.buf].editorconfig) then
      vim.bo[args.buf].tabstop = 4
      vim.bo[args.buf].shiftwidth = 4
      vim.bo[args.buf].softtabstop = 4
      vim.bo[args.buf].expandtab = true
    end
  end,
})

-- Toggle between a PHP source file and its PHPUnit counterpart.
-- Tries the common PSR-4-style trees: src/ <-> tests/, app/ <-> tests/Unit/,
-- etc. When multiple candidates exist (e.g. tests/Unit and tests/Feature both
-- have a counterpart), shows a picker.
local SRC_DIRS = { "/src/", "/app/", "/lib/" }
local TEST_DIRS = { "/tests/Unit/", "/tests/Feature/", "/tests/Integration/", "/tests/", "/Tests/" }

local function counterparts_for(file)
  local out = {}
  local seen = {}
  local function add(p)
    if not seen[p] and vim.fn.filereadable(p) == 1 then
      seen[p] = true
      table.insert(out, p)
    end
  end
  if file:match("Test%.php$") then
    local base = file:gsub("Test%.php$", ".php")
    for _, from in ipairs(TEST_DIRS) do
      for _, to in ipairs(SRC_DIRS) do
        local c = base:gsub(from, to, 1)
        if c ~= base then
          add(c)
        end
      end
    end
  else
    local base = file:gsub("%.php$", "Test.php")
    for _, from in ipairs(SRC_DIRS) do
      for _, to in ipairs(TEST_DIRS) do
        local c = base:gsub(from, to, 1)
        if c ~= base then
          add(c)
        end
      end
    end
  end
  return out
end

local function toggle_source_test()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or not file:match("%.php$") then
    vim.notify("Not a PHP file", vim.log.levels.WARN)
    return
  end
  local candidates = counterparts_for(file)
  if #candidates == 0 then
    vim.notify("No counterpart found for " .. vim.fs.basename(file), vim.log.levels.WARN)
    return
  end
  if #candidates == 1 then
    vim.cmd.edit(vim.fn.fnameescape(candidates[1]))
    return
  end
  vim.ui.select(candidates, { prompt = "Open counterpart:" }, function(choice)
    if choice then
      vim.cmd.edit(vim.fn.fnameescape(choice))
    end
  end)
end

vim.keymap.set("n", "<leader>tg", toggle_source_test, { desc = "Toggle PHP source/test file" })

-- Run every test in the project (neotest equivalent of PhpStorm's "Run all tests").
vim.keymap.set("n", "<leader>tT", function()
  require("neotest").run.run(vim.fn.getcwd())
end, { desc = "Run all tests in project" })

-- Run last test invocation.
vim.keymap.set("n", "<leader>tl", function()
  require("neotest").run.run_last()
end, { desc = "Re-run last test" })

-- Open output of last test under cursor.
vim.keymap.set("n", "<leader>tp", function()
  require("neotest").output.open({ enter = true, last_run = true })
end, { desc = "Open last test output" })

vim.api.nvim_create_user_command("IntelephenseRestart", function()
  if not restart_intelephense() then
    notify("No running intelephense client", vim.log.levels.WARN)
  end
end, { desc = "Restart intelephense (keep cache)" })

vim.api.nvim_create_user_command("IntelephensePurgeCache", function()
  purge_intelephense_cache()
end, { desc = "Stop intelephense, wipe its cache, restart (full reindex)" })

vim.keymap.set("n", "<leader>lR", function()
  restart_intelephense()
end, { desc = "Restart intelephense" })

return {}
