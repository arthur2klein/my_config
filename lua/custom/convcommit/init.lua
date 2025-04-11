local M = {}

local input = require("lua.custom.convcommit.input").input
local multiline = require("lua.custom.convcommit.input").multiline_input
local select = require("lua.custom.convcommit.select").select
local create_version_tag = require("lua.custom.convcommit.version").create_version_tag

local commit_data = {}

local function get_message()
	local message = string.format(
		"%s%s%s: %s",
		commit_data.type,
		commit_data.scope and "(" .. commit_data.scope .. ")" or "",
		commit_data.breaking and "!" or "",
		commit_data.subject
	)
	if commit_data.body and #commit_data.body > 0 then
		message = message .. "\n\n" .. commit_data.body
	end
	if commit_data.breaking or (commit_data.footers and #commit_data.footers > 0) then
		message = message .. "\n"
	end
	if commit_data.breaking then
		message = message .. "\nBREAKING CHANGE: " .. commit_data.breaking
	end
	if commit_data.footers and #commit_data.footers > 0 then
		message = message .. "\n" .. table.concat(commit_data.footers, "\n")
	end
	return message
end

local function open_commit_buffer()
	multiline({ prompt = "Confirm message:", default = get_message() }, function(message)
		vim.fn.system('git commit -m "' .. message .. '"')
		create_version_tag()
		print("✅ Commit created!")
	end)
end

local function add_footer()
	input({ prompt = "Add a footer (key: value) or leave empty to continue:" }, function(footer)
		if footer and footer ~= "" then
			if commit_data.footers == nil then
				commit_data.footers = { footer }
			else
				table.insert(commit_data.footers, footer)
			end
			add_footer()
		else
			open_commit_buffer()
		end
	end)
end

local function ask_breaking_change()
	select({ "No", "Yes" }, { prompt = "Is this a breaking change?" }, function(choice)
		if choice == "Yes" then
			input({ prompt = "Describe the breaking change:" }, function(breaking_desc)
				commit_data.breaking = breaking_desc
				add_footer()
			end)
		else
			commit_data.breaking = nil
			add_footer()
		end
	end)
end

local function enter_body()
	multiline({ prompt = "Enter commit body (optional):", default = "" }, function(body)
		commit_data.body = body
		ask_breaking_change()
	end)
end

local function enter_subject()
	input({ prompt = "Enter commit subject:" }, function(subject)
		if not subject or subject == "" then
			print("❌ Commit cancelled.")
		end
		commit_data.subject = subject
		enter_body()
	end)
end

local function select_scope()
	local scopes = vim.fn.systemlist("git diff --name-only --cached | sed 's:/:\\n:g' | sort -u")
	table.insert(scopes, "none")
	select(scopes, { prompt = "Select scope (or none):" }, function(choice)
		commit_data.scope = choice ~= "none" and choice or nil
		enter_subject()
	end)
end

local function select_commit_type()
	local commit_types = {
		"build",
		"chore",
		"ci",
		"docs",
		"feat",
		"fix",
		"perf",
		"refactor",
		"revert",
		"style",
		"test",
		"merge",
	}
	select(commit_types, { prompt = "Select commit type:" }, function(choice)
		if not choice or choice == "" then
			print("❌ Commit cancelled.")
		else
			commit_data.type = choice
			select_scope()
		end
	end)
end

function M.create_commit()
	commit_data = {}
	select_commit_type()
end

return M
