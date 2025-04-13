local M = {}

local input = require("input").input
local multiline = require("input").multiline_input
local select = require("select").select
local CommitBuilder = require("commit_builder")

---@type CommitBuilder
local commit_builder

--- Displays the commit message a last time, allowing for modifications before creating the commit.
local function preview()
	multiline({ prompt = "Confirm message:", default = CommitBuilder.build(commit_builder) }, function(message)
		vim.fn.system('git commit -m "' .. message .. '"')
		print("✅ Commit created!")
	end)
end

--- Adds footers recursively
local function add_footer()
	input({ prompt = "Add a footer (key: value) or leave empty to continue:" }, function(footer)
		if footer and footer ~= "" then
			CommitBuilder.add_footer(commit_builder, footer)
			add_footer()
		else
			preview()
		end
	end)
end

--- Asks if the commit is breaking, and asks for additional information.
--- This will add a ! in the first line, as well as a BREAKING CHANGE footer.
local function ask_breaking_change()
	select({ "No", "Yes" }, { prompt = "Is this a breaking change?" }, function(choice)
		if choice == "Yes" then
			input({ prompt = "Describe the breaking change:" }, function(breaking_desc)
				commit_builder.breaking = breaking_desc
				add_footer()
			end)
		else
			commit_builder.breaking = nil
			add_footer()
		end
	end)
end

--- Enters the longer optional commit description.
local function enter_body()
	multiline({ prompt = "Enter commit body (optional):", default = "" }, function(body)
		commit_builder.body = body
		ask_breaking_change()
	end)
end

--- Enters the commit subject: short, main description of the commit.
local function enter_subject()
	input({ prompt = "Enter commit subject:" }, function(subject)
		if not subject or subject == "" then
			print("❌ Commit cancelled.")
		end
		commit_builder.subject = subject
		enter_body()
	end)
end

--- Inputs the optional scope of the commit.
--- Acceptable values are amongst the part of path of staged changes.
local function select_scope()
	local scopes = vim.fn.systemlist("git diff --name-only --cached | sed 's:/:\\n:g' | sort -u")
	table.insert(scopes, "none")
	select(scopes, { prompt = "Select scope (or none):" }, function(choice)
		if choice ~= "none" then
			commit_builder.scope = choice
		else
			commit_builder.scope = nil
		end
		enter_subject()
	end)
end

--- Inputs the commit type.
--- Affects the first line of the commit.
--- Acceptable values are: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test,
--- merge
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
			commit_builder.type = choice
			select_scope()
		end
	end)
end

--- Creates the ticket information knowing the source of the ticket.
---@param type string Type of the ticket amongst jira, github and gitlab.
local function input_ticket(type)
	input({ prompt = string.format("Enter %s ticket link:", type) }, function(link)
		if not link or link == "" then
			print("❌ Commit cancelled.")
		end
		CommitBuilder.setTicket(commit_builder, link, type)
		select_commit_type()
	end)
end

--- Gets information about the related ticket.
--- Affects the subject, Ticket-Id and Ticket-Link footer.
local function get_ticket_info()
	local ticket_options = {
		"none",
		"jira",
		"github",
		"gitlab",
	}
	select(ticket_options, { prompt = "Ticket" }, function(choice)
		if choice and #choice ~= 0 and choice ~= "none" then
			input_ticket(choice)
		else
			select_commit_type()
		end
	end)
end

--- Ask for information to build a commit for the currently staged changes.
function M.create_commit()
	commit_builder = CommitBuilder.new()
	get_ticket_info()
end

return M
