local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")

--- Displays a telescope picker to add files.
--- Press y to add a file, and n to skip it.
function M.git_add()
	local files = vim.fn.systemlist("git ls-files --others --exclude-standard --modified")
	local function refresh_picker(picker, new_results)
		picker:refresh(
			finders.new_table({
				results = new_results,
			}),
			{ reset_prompt = false }
		)
	end
	pickers
		.new({}, {
			prompt_title = "Stage Files (y = stage, n = skip)",
			finder = finders.new_table({
				results = files,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewers.git_file_diff.new({}),
			attach_mappings = function(prompt_bufnr, map)
				local picker = action_state.get_current_picker(prompt_bufnr)
				map("i", "y", function()
					local entry = action_state.get_selected_entry()
					local file = entry[1]
					vim.fn.system({ "git", "add", file })
					for i, f in ipairs(files) do
						if f == file then
							table.remove(files, i)
							break
						end
					end
					refresh_picker(picker, files)
					if files == nil or #files == 0 then
						actions.close(prompt_bufnr)
					end
				end)
				map("i", "n", function()
					local entry = action_state.get_selected_entry()
					local file = entry[1]
					for i, f in ipairs(files) do
						if f == file then
							table.remove(files, i)
							break
						end
					end
					refresh_picker(picker, files)
					if files == nil or #files == 0 then
						actions.close(prompt_bufnr)
					end
				end)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
				end)
				return true
			end,
		})
		:find()
end
return M
