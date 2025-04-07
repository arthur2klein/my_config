return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			dap.adapters.php = {
				type = "executable",
				command = "node",
				args = { "/root/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
			}
			dap.configurations.php = {
				{
					type = "php",
					request = "launch",
					name = "Listen for Xdebug",
					port = "9003",
					pathMapping = {
						["/var/www/html"] = "${workspaceFolder}",
					},
				},
			}
			local dap_widgets = require("dap.ui.widgets")
			vim.keymap.set("n", "<leader>dd", dap.continue)
			vim.keymap.set("n", "<leader>du", dap.step_over)
			vim.keymap.set("n", "<leader>di", dap.step_into)
			vim.keymap.set("n", "<leader>do", dap.step_out)
			vim.keymap.set("n", "<Leader>dm", dap.toggle_breakpoint)
			vim.keymap.set("n", "<Leader>dl", dap.repl.open)
			vim.keymap.set("n", "<Leader>dp", dap.run_last)
			vim.keymap.set({ "n", "v" }, "<Leader>dj", dap_widgets.hover)
			vim.keymap.set({ "n", "v" }, "<Leader>dk", dap_widgets.preview)
			vim.keymap.set("n", "<Leader>dy", function()
				dap_widgets.centered_float(dap_widgets.frames)
			end)
			vim.keymap.set("n", "<Leader>dh", function()
				dap_widgets.centered_float(dap_widgets.scopes)
			end)
		end,
	},
	{ "theHamsta/nvim-dap-virtual-text", config = true },
}
