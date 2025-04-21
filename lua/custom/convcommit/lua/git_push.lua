local M = {}

--- Checks whether the given flag is set in a value.
---@param value integer Value to search the flag in.
---@param flag integer Flag to check in the value.
---@return boolean: True iff the given flag is set in the value.
local function check_flag(value, flag)
	return bit.band(value, flag) == value
end

--- Returns the pipeline url of the current commit.
--- Works for both github and gitlab.
--- Returns nil if no url could be determined.
---@return string?: Url of the pipeline of the current commit if could be determined.
local function get_commit_pipeline_url()
	local remote = vim.fn.system("git remote get-url origin"):gsub("\n", "")
	local sha = vim.fn.system("git rev-parse HEAD"):gsub("\n", "")
	local github_pattern = "[/:]github%.com[:/](.-)/(.-)%.git"
	local gitlab_pattern = "[/:]gitlab%.com[:/](.-)/(.-)%.git"
	local user, repo = remote:match(github_pattern)
	if user and repo then
		return string.format("https://github.com/%s/%s/commit/%s/checks", user, repo, sha)
	end
	user, repo = remote:match(gitlab_pattern)
	if user and repo then
		return string.format("https://gitlab.com/%s/%s/-/commit/%s/pipelines", user, repo, sha)
	end
	vim.notify("❓ Could not determine commit-specific pipeline URL", vim.log.levels.WARN)
	return nil
end

--- Opens the given url.
--- Uses xdg-open on linux and cmd.exe if in wsl.
---@param url string: Url to open
local function open_url(url)
	local cmd
	if vim.fn.has("wsl") == 1 then
		url = url:gsub("&", "^&")
		cmd = { "cmd.exe", "/C", "start", "", url }
	else
		cmd = { "xdg-open", url }
	end
	vim.fn.jobstart(cmd, { detach = true })
end

--- If set, will pull before pushing.
M.SHOULD_PULL = 1
--- If set, will try to open a browser to view the new pipeline.
M.OPEN_PIPELINE = 2

--- Pushes the local commits.
--- Also pull remote changes if any.
--- @param flags integer? Flags to pass to the function. Defaults to 3.
function M.push(flags)
	if flags == nil then
		flags = 3
	end
	local function run_git_cmd(cmd, desc, on_done, is_skipped)
		if not is_skipped then
			vim.notify(vim.fn.system(cmd), vim.log.levels.TRACE)
			local status = vim.v.shell_error
			if status == 0 then
				vim.notify(string.format("✅ %s succeeded", desc), vim.log.levels.INFO)
			else
				vim.notify(string.format("❌ %s failed (exit code %s)", desc, status), vim.log.levels.ERROR)
			end
		end
		if on_done then
			on_done()
		end
	end
	run_git_cmd("git pull --rebase", "Git pull", function()
		run_git_cmd("git push", "Git push")
		if check_flag(flags, M.OPEN_PIPELINE) then
			local ref = get_commit_pipeline_url()
			if ref then
				open_url(ref)
			end
		end
	end, check_flag(flags, M.SHOULD_PULL))
end

return M
