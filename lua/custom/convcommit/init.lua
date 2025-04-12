local M = {}

M.create_version_tag = require("version").create_version_tag
M.create_commit = require("create_commit").create_commit

--- Pushes the local commits.
--- Also pull remote changes if any.
function M.push()
	print(vim.fn.system("git pull --rebase && git push"))
	print("✅ Push successful!")
end

return M
