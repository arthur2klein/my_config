local M = {}

M.create_version_tag = require("version").create_version_tag
M.create_commit = require("create_commit").create_commit
M.git_add = require("git_add").git_add

--- Pushes the local commits.
--- Also pull remote changes if any.
function M.push()
	local function run_git_cmd(cmd, desc, on_done)
		local stdout = {}
		vim.system(cmd, {
			text = true,
			stdout = function(_, data)
				if data then
					table.insert(stdout, data)
					print(data)
				end
			end,
			stderr = function(_, data)
				if data then
					vim.schedule(function()
						vim.notify(data, vim.log.levels.ERROR)
					end)
				end
			end,
		}, function(obj)
			if obj.code == 0 then
				print("✅ " .. desc .. " succeeded")
			else
				print("❌ " .. desc .. " failed (exit code " .. obj.code .. ")")
			end
			if on_done then
				on_done()
			end
		end)
	end
	run_git_cmd({ "git", "pull", "--rebase" }, "Git pull", function()
		run_git_cmd({ "git", "push" }, "Git push")
	end)
end

return M
