local M = {}

local commit_data = {}
local temp_file = vim.fn.tempname()
local buf, win

local function get_message()
  local message = string.format(
    "%s%s%s: %s%s",
    commit_data.type,
    commit_data.scope and "(" .. commit_data.scope .. ")" or "",
    commit_data.breaking and "!" or "",
    commit_data.subject,
    commit_data.body and "\n\n" .. commit_data.body or ""
  )
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

local function cancel_commit()
  -- Close buffer & window without committing
  os.remove(temp_file)
  vim.api.nvim_win_close(win, true)
  vim.api.nvim_buf_delete(buf, { force = true })

  print("❌ Commit cancelled.")
end

local function confirm_commit()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local final_message = table.concat(lines, "\n")

  local file = io.open(temp_file, "w")
  if file then
    file:write(final_message)
    file:close()
  end

  -- Run git commit
  vim.fn.system("git commit -F " .. temp_file)
  os.remove(temp_file)

  -- Close buffer & window
  vim.api.nvim_win_close(win, true)
  vim.api.nvim_buf_delete(buf, { force = true })

  print("✅ Commit created!")
end

local function open_commit_buffer()
  local message = get_message()

  -- Write to temporary file
  local file = io.open(temp_file, "w")
  if file then
    file:write(message)
    file:close()
  end

  -- Create floating buffer
  buf = vim.api.nvim_create_buf(false, true)
  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 80,
    height = 15,
    row = math.floor((vim.o.lines - 15) / 2),
    col = math.floor((vim.o.columns - 80) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(message, "\n"))
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")

  -- Keybindings
  vim.keymap.set("n", "<leader>yy", confirm_commit)
  vim.keymap.set("n", "<leader>yn", cancel_commit)

  print("Press <leader>yy to commit, <leader>yn to cancel")
end

local function add_footer()
  vim.ui.input({ prompt = "Add a footer (key: value) or leave empty to continue:" }, function(footer)
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
  vim.ui.select({ "No", "Yes" }, { prompt = "Is this a breaking change?" }, function(choice)
    if choice == "Yes" then
      vim.ui.input({ prompt = "Describe the breaking change:" }, function(breaking_desc)
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
  vim.ui.input({ prompt = "Enter commit body (optional):", default = "" }, function(body)
    commit_data.body = body
    ask_breaking_change()
  end)
end

local function enter_subject()
  vim.ui.input({ prompt = "Enter commit subject:" }, function(subject)
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
  vim.ui.select(scopes, { prompt = "Select scope (or none):" }, function(choice)
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
  vim.ui.select(commit_types, { prompt = "Select commit type:" }, function(choice)
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
