local M = {}
local notify = require("notify")

---@class PushConfig Configuration of the push() function.
---@field should_pull boolean? If true, will pull before pushing. Default to true.
---@field open_pipeline boolean? If true, will open a browser with the new ci. Default to true.

--- Parse a remote url to determine its hosting site, the user and the name of the repo.
---@param remote string Remote to parse.
---@return string?, string?, string?: "github", "gitlab" or nil for the first argument, followed
---by the user and the repo of the project if hosting site not nil.
local function parse_remote(remote)
	local user, repo = remote:match("git@github%.com:(.-)/(.-)%.git")
	if user and repo then
		return "github", user, repo
	end
	user, repo = remote:match("https://github%.com/(.-)/(.-)%.git")
	if user and repo then
		return "github", user, repo
	end
	user, repo = remote:match("git@gitlab%.com:(.-)/(.-)%.git")
	if user and repo then
		return "gitlab", user, repo
	end
	user, repo = remote:match("https://gitlab%.com/(.-)/(.-)%.git")
	if user and repo then
		return "gitlab", user, repo
	end
	return nil, nil, nil
end

--- Returns the pipeline url of the current commit.
--- Works for both github and gitlab.
--- Returns nil if no url could be determined.
---@return string?: Url of the pipeline of the current commit if could be determined.
local function get_commit_pipeline_url()
	local remote = vim.fn.system("git remote get-url origin"):gsub("\n", "")
	local sha = vim.fn.system("git rev-parse HEAD"):gsub("\n", "")
	local source, user, repo = parse_remote(remote)
	if source == "github" then
		return string.format("https://github.com/%s/%s/commit/%s/checks", user, repo, sha)
	end
	if source == "gitlab" then
		return string.format("https://gitlab.com/%s/%s/-/commit/%s/pipelines", user, repo, sha)
	end
	notify("❓ Could not determine commit-specific pipeline URL", vim.log.levels.WARN)
	return nil
end

--- Opens the given url.
--- Uses xdg-open on linux and cmd.exe if in wsl.
---@param url string: Url to open
local function open_url(url)
	local cmd
	if vim.fn.has("wsl") == 1 then
		url = url:gsub("&", "^&")
		cmd = { "/mnt/c/Windows/System32/cmd.exe", "/C", "start", "", url }
	else
		cmd = { "xdg-open", url }
	end
	vim.fn.jobstart(cmd, { detach = true })
end

--- Pushes the local commits.
--- Also pull remote changes if any.
--- @param config PushConfig? Configuration of the command.
function M.push(config)
	if config == nil then
		config = {}
	end
	local function run_git_cmd(cmd, desc, on_done, is_skipped)
		if not is_skipped then
			notify(vim.fn.system(cmd), vim.log.levels.TRACE)
			local status = vim.v.shell_error
			if status == 0 then
				notify(string.format("✅ %s succeeded", desc), vim.log.levels.INFO)
			else
				notify(string.format("❌ %s failed (exit code %s)", desc, status), vim.log.levels.ERROR)
			end
		end
		if on_done then
			on_done()
		end
	end
	run_git_cmd("git pull --rebase", "Git pull", function()
		run_git_cmd("git push", "Git push")
		if config.open_pipeline == nil or config.open_pipeline then
			local ref = get_commit_pipeline_url()
			if ref then
				open_url(ref)
			end
		end
	end, config.should_pull == nil or config.should_pull)
end

return M
