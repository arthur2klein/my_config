local M = {}

local function get_latest_tag()
	local tag = vim.fn.system("git describe --tags --abbrev=0"):gsub("%s+", "")
	if tag ~= "" and tag:sub(0, 5) ~= "fatal" then
		return tag
	else
		return "v0.0.0"
	end
end

local function get_commits_since(tag)
	local cmd = string.format("git log %s..HEAD --pretty=format:%%s", tag)
	if tag == "v0.0.0" then
		cmd = "git log HEAD --pretty=format:%s"
	end
	return vim.fn.systemlist(cmd)
end

local function determine_bump(commits)
	local bump = "patch"
	for _, c in ipairs(commits) do
		if c:match("BREAKING CHANGE") then
			return "major"
		elseif c:match("^feat") then
			bump = "minor"
		end
	end
	return bump
end

local function bump_version(version, level)
	local major, minor, patch = version:match("v?(%d+)%.(%d+)%.(%d+)")
	major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)

	if level == "major" then
		major = major + 1
		minor = 0
		patch = 0
	elseif level == "minor" then
		minor = minor + 1
		patch = 0
	else
		patch = patch + 1
	end

	return string.format("v%d.%d.%d", major, minor, patch)
end

local function write_changelog(new_version, commits)
	local f = io.open("CHANGELOG.md", "a")
	if not f then
		return
	end

	f:write("## " .. new_version .. " - " .. os.date("%Y-%m-%d") .. "\n\n")
	for _, c in ipairs(commits) do
		f:write("- " .. c .. "\n")
	end
	f:close()
	vim.fn.system(
		'git add CHANGELOG.md && git commit -m "docs(CHANGELOG.md): Add changelog for version ' .. new_version .. '"'
	)
end

local function confirm(prompt)
	local answer = vim.fn.input(prompt .. " (y/n): ")
	return answer:lower() == "y"
end

function M.create_version_tag()
	local latest_tag = get_latest_tag()
	print(latest_tag)
	local commits = get_commits_since(latest_tag)

	if #commits == 0 then
		print("No new commits since " .. latest_tag)
		return
	end

	local bump = determine_bump(commits)
	local new_version = bump_version(latest_tag, bump)

	print("Latest tag: " .. latest_tag)
	print("Proposed new version: " .. new_version)
	print("Commit messages:")
	for _, c in ipairs(commits) do
		print("  " .. c)
	end

	if confirm("Create tag " .. new_version .. "?") then
		local tag_cmd = "git tag " .. new_version .. " && git push origin " .. new_version
		local result = vim.fn.system(tag_cmd)
		print(result)
		write_changelog(new_version, commits)
		print("Changelog updated.")
	else
		print("Tagging cancelled.")
	end
end

return M
