return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"nvim-telescope/telescope-symbols.nvim",
		},
		config = function()
			require("telescope").load_extension("dap")
			require("telescope").load_extension("notify")
			local builtin = require("telescope.builtin")
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local utils = require("telescope.utils")
			local telescope_dap = require("telescope").extensions.dap
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fa", builtin.diagnostics, {})
			vim.keymap.set("n", "<leader>fc", builtin.git_commits, {})
			vim.keymap.set("n", "<leader>fC", builtin.git_bcommits, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>ft", builtin.treesitter, {})
			vim.keymap.set("n", "<leader>f<leader>", builtin.git_status, {})
			vim.keymap.set("n", "<leader>fb", builtin.git_branches, {})
			vim.keymap.set("n", "<leader>fh", builtin.command_history, {})
			vim.keymap.set("n", "<leader>fm", builtin.marks, {})
			vim.keymap.set("n", "<leader>fj", builtin.jumplist, {})
			vim.keymap.set("n", "<leader>fs", builtin.spell_suggest, {})
			vim.keymap.set("n", "<leader>fr", builtin.lsp_references, {})
			vim.keymap.set("n", "<leader>fn", require("telescope").extensions.notify.notify, {})
			-- vim.keymap.set("n", "<leader>fy", builtin.registers, {})

			vim.keymap.set("n", "<leader>fq", require("telescope").extensions.macroscope.default, {})
			vim.keymap.set("n", "<leader>fy", require("telescope").extensions.neoclip.default, {})
			vim.keymap.set("n", "<leader>fe", function()
				builtin.symbols({ sources = { "emoji", "kaomoji", "gitmoji" } })
			end, {})
			vim.keymap.set("n", "<leader>fm", function()
				builtin.symbols({ sources = { "math", "latex" } })
			end, {})
			vim.keymap.set("n", "<leader>fo", function()
				builtin.symbols({ sources = { "julia", "nerd" } })
			end, {})

			vim.keymap.set("n", "<leader>fda", telescope_dap.commands, {})
			vim.keymap.set("n", "<leader>fdc", telescope_dap.configurations, {})
			vim.keymap.set("n", "<leader>fdb", telescope_dap.list_breakpoints, {})
			vim.keymap.set("n", "<leader>fdv", telescope_dap.variables, {})
			vim.keymap.set("n", "<leader>fdf", telescope_dap.frames, {})

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-e>"] = function(prompt_bufnr)
								actions.git_merge_branch(prompt_bufnr)
								vim.cmd("checktime")
							end,
							["<C-r>"] = function(prompt_bufn)
								actions.git_rebase_branch(prompt_bufn)
								vim.cmd("checktime")
							end,
							["<C-h>"] = function(prompt_bufnr)
								local selection = action_state.get_selected_entry()
								local current_picker = action_state.get_current_picker(prompt_bufnr)
								if selection == nil then
									utils.__warn_no_selection("git_rollback")
									return
								end
								utils.get_os_command_output(
									{ "git", "checkout", "--", selection.value },
									current_picker.cwd
								)
								current_picker:delete_selection(function()
									local _, ret, _ = utils.get_os_command_output(
										{ "git", "rev-parse", "--verify", "MERGE_HEAD" },
										current_picker.cwd
									)
									return not (ret == 0)
								end)
								vim.cmd("checktime")
							end,
							["<C-l>"] = function(prompt_bufnr)
								local selection = action_state.get_selected_entry()
								local current_picker = action_state.get_current_picker(prompt_bufnr)
								if selection == nil then
									utils.__warn_no_selection("git_checkout_theirs")
									return
								end
								utils.get_os_command_output(
									{ "git", "checkout", "--theirs", selection.value },
									current_picker.cwd
								)
								vim.cmd("checktime")
							end,
						},
					},
				},
				pickers = {
					git_status = {
						theme = "dropdown",
					},
					find_files = {
						hidden = true,
						file_ignore_patterns = { ".git/" },
					},
				},
			})
		end,
	},
}
