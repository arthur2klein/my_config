local M = {}

M.create_version_tag = require("version").create_version_tag
M.create_commit = require("create_commit").create_commit
M.git_add = require("git_add").git_add

--- Pushes the local commits.
--- Also pull remote changes if any.
function M.push()
  local function run_git_cmd(cmd, desc, on_done)
    vim.notify(vim.fn.system(cmd), vim.log.levels.TRACE)
    local status = vim.v.shell_error
    if status == 0 then
      vim.notify(string.format("✅ %s succeeded", desc), vim.log.levels.INFO)
    else
      vim.notify(string.format("❌ %s failed (exit code %s)", desc, status), vim.log.levels.ERROR)
    end
    if on_done then
      on_done()
    end
  end
  run_git_cmd("git pull --rebase", "Git pull", function()
    run_git_cmd("git push", "Git push")
  end)
end

return M
