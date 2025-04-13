local commit_builder = require("lua.commit_builder")

describe("commit_builder", function()
	it("creates an empty commit", function()
		local commit = commit_builder.new()
		assert.equal("feat", commit.type)
		assert.equal("No message", commit.subject)
		assert.are.same({}, commit.footers)
		assert.equal(nil, commit.scope)
		assert.equal(nil, commit.body)
		assert.equal(nil, commit.breaking)
		assert.equal(nil, commit.ticket_id)
		assert.equal(nil, commit.ticket_link)
	end)

	it("extracts ticket id from link", function()
		local commit = commit_builder.new()
		commit_builder.setTicket(commit, "https://<domain>.atlassian.net/browse/PROJ-123", "jira")
		assert.are.same("PROJ-123", commit.ticket_id)
		assert.are.same("https://<domain>.atlassian.net/browse/PROJ-123", commit.ticket_link)
		commit_builder.setTicket(commit, "https://gitlab.com/<group>/<project>/-/issues/456", "gitlab")
		assert.are.same("456", commit.ticket_id)
		assert.are.same("https://gitlab.com/<group>/<project>/-/issues/456", commit.ticket_link)
		commit_builder.setTicket(commit, "https://github.com/<user>/<repo>/issues/789", "github")
		assert.are.same("789", commit.ticket_id)
		assert.are.same("https://github.com/<user>/<repo>/issues/789", commit.ticket_link)
	end)

	it("adds a footer", function()
		local commit = commit_builder.new()
		assert.are.same({}, commit.footers)
		commit_builder.addFooter(commit, "key: value")
		assert.are.same({ "key: value" }, commit.footers)
		commit_builder.addFooter(commit, "lorem: ipsum")
		assert.are.same({ "key: value", "lorem: ipsum" }, commit.footers)
	end)

	it("builds a commit message", function()
		---@type CommitBuilder
		local commit = {
			ticket_link = "https://github.com/example/repo/issues/123",
			ticket_id = "123",
			type = "feat",
			scope = "core",
			subject = "add new command parser",
			body = "Allow to build more complete and responsive apis using our tool.",
			breaking = "removed old parser system",
			footers = { "Changelog-Entry: new command parser" },
		}
		local message = commit_builder.build(commit)
		local expected = "feat(core)!: [123] add new command parser\
\
Allow to build more complete and responsive apis using our tool.\
\
BREAKING CHANGE: removed old parser system\
\
Changelog-Entry: new command parser\
Ticket-Id: 123\
Ticket-Link: https://github.com/example/repo/issues/123"
		assert.equal(expected, message)
	end)
end)
