local Input = require("nui.input")
local Popup = require("nui.popup")

local M = {}

---@class InputOptions Props for input fields.
---@field prompt string Prompt for the user.
---@field default string | nil (Default to "") Default value if none given.

--- Allows the user to input some information.
--- Pressing C-c will cancel the input as well as the on_submit call.
---@param opts InputOptions Props of the field.
---@param on_submit fun(value: string): nil Action that requires the inputed value.
function M.input(opts, on_submit)
	local input = Input({
		position = "50%",
		size = {
			width = 60,
			height = 10,
		},
		border = {
			style = "rounded",
			text = {
				top = opts.prompt,
				top_align = "left",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	}, {
		prompt = "> ",
		default_value = opts.default or "",
		on_submit = on_submit,
	})
	input:map("n", "<C-c>", function()
		input:unmount()
		print("❌ Cancelled.")
	end)
	input:mount()
end

--- Allows the user to input mutliple lines of informations.
--- Pressing <leader><cr> in insert mode insert a line break.
--- Pressing C-c will cancel the input as well as the on_submit call.
---@param opts InputOptions Props of the field.
---@param on_submit fun(value: string): nil Action that requires the inputed value.
function M.multiline_input(opts, on_submit)
	local default = opts.default or ""
	local lines = vim.split(default, "\n")
	local popup = Popup({
		position = "50%",
		size = {
			width = 80,
			height = 10,
		},
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = opts.prompt,
				top_align = "left",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
		buf_options = {
			modifiable = true,
			buftype = "acwrite",
		},
	})
	popup:mount()
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
	vim.keymap.set("n", "<leader><CR>", function()
		local result = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
		popup:unmount()
		on_submit(table.concat(result, "\n"))
	end, { buffer = popup.bufnr })
	vim.keymap.set("n", "<C-c>", function()
		popup:unmount()
		print("❌ Cancelled.")
	end, { buffer = popup.bufnr })
end

return M
