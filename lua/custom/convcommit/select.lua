local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.select(items, opts, on_choice)
  pickers
      .new({}, {
        prompt_title = opts.prompt or "Select an option",
        layout_config = { height = 15, width = 50 },
        finder = finders.new_table({
          results = items,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
          actions.select_default:replace(function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              on_choice(selection[1])
            else
              print("❌ Cancelled.")
            end
          end)
          map("i", "<C-c>", actions.close)
          map("n", "<C-c>", actions.close)
          return true
        end,
      })
      :find()
end

return M
