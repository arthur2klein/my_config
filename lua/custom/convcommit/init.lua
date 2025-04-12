local M = {}

local input = require("custom.convcommit.input").input
local multiline = require("custom.convcommit.input").multiline_input
local select = require("custom.convcommit.select").select

local commit_data = {}

local function get_message()
	if commit_data.ticket_id and #commit_data.ticket_id > 0 then
		commit_data.subject = string.format("[%s] %s", commit_data.ticket_id, commit_data.subject)
		table.insert(commit_data.footers, string.format("Ticket-Id: %s", commit_data.ticket_id))
	end
	if commit_data.ticket_link and #commit_data.ticket_link > 0 then
		table.insert(commit_data.footers, string.format("Ticket-Link: %s", commit_data.ticket_link))
	end
	if commit_data.scope then
		commit_data.type = string.format("%s(%s)", commit_data.type, commit_data.scope)
	end
	if commit_data.breaking then
		commit_data.type = string.format("%s!", commit_data.type)
		table.insert(commit_data.breaking, string.format("\nBREAKING CHANGE: : %s", commit_data.breaking))
	end
	local message = string.format("%s: %s", commit_data.type, commit_data.subject)
	if commit_data.body and #commit_data.body > 0 then
		message = message .. "\n\n" .. commit_data.body
	end
	if commit_data.footers and #commit_data.footers > 0 then
		message = message .. "\n\n" .. table.concat(commit_data.footers, "\n")
	end
	return message
end

local function open_commit_buffer()
	multiline({ prompt = "Confirm message:", default = get_message() }, function(message)
		vim.fn.system('git commit -m "' .. message .. '"')
		print("✅ Commit created!")
	end)
end

local function add_footer()
	commit_data.footers = {}
	input({ prompt = "Add a footer (key: value) or leave empty to continue:" }, function(footer)
		if footer and footer ~= "" then
			table.insert(commit_data.footers, footer)
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

local function ticket_id_from_link(link, type)
	if type == "jira" then
		-- Example: https://<domain>.atlassian.net/browse/PROJ-123
		return link:match("/browse/([A-Z]+%-%d+)")
	elseif type == "gitlab" then
		-- Example: https://gitlab.com/<group>/<project>/-/issues/456
		return link:match("/issues/(%d+)")
	elseif type == "github" then
		-- Example: https://github.com/<user>/<repo>/issues/789
		return link:match("/issues/(%d+)")
	else
		return nil
	end
end

local function input_ticket(type, after)
	input({ prompt = string.format("Enter %s ticket link:", type) }, function(link)
		if not link or link == "" then
			print("❌ Commit cancelled.")
		end
		commit_data.ticket_link = link
		commit_data.ticket_id = ticket_id_from_link(link, type)
		after()
	end)
end

local function select_first_info()
	local ticket_options = {
		"none",
		"jira",
		"github",
		"gitlab",
	}
	select(ticket_options, { prompt = "Ticket" }, function(choice)
		if choice and #choice ~= 0 and choice ~= "none" then
			input_ticket(choice, select_commit_type)
		else
			select_commit_type()
		end
	end)
end

function M.create_commit()
	commit_data = {}
	select_first_info()
end

M.create_version_tag = require("custom.convcommit.version").create_version_tag

function M.push()
	vim.fn.system("git pull --rebase && git push")
end

return M
