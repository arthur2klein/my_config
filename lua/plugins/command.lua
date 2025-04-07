return {
	"vim-scripts/loremipsum",
	{
		"junegunn/vim-easy-align",
		config = function()
			vim.api.nvim_set_keymap("x", "ga", "<Plug>(EasyAlign)", {})
			vim.api.nvim_set_keymap("n", "ga", "<Plug>(EasyAlign)", {})
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	"numToStr/Comment.nvim",
	{
		"andrewferrier/debugprint.nvim",
		dependencies = { "echasnovski/mini.nvim" },
		opts = {
			keymaps = {
				normal = {
					plain_below = "<leader>pp",
					plain_above = "<leader>pP",
					variable_below = "<leader>pv",
					variable_above = "<leader>pV",
					textobj_below = "<leader>po",
					textobj_above = "<leader>pO",
				},
				visual = {
					variable_below = "<leader>pv",
					variable_above = "<leader>pV",
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["it"] = "@comment.inner",
							["if"] = "@function.inner",
							["ic"] = "@class.inner",
							["il"] = "@loop.inner",
							["ir"] = "@return.inner",
							["ii"] = "@conditional.inner",
							["ia"] = "@parameter.inner",
							["at"] = "@comment.outer",
							["af"] = "@function.outer",
							["ac"] = "@class.outer",
							["al"] = "@loop.outer",
							["ar"] = "@return.outer",
							["ai"] = "@conditional.outer",
							["aa"] = "@parameter.outer",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							[")t"] = "@comment.outer",
							[")f"] = "@function.outer",
							[")c"] = "@class.outer",
							[")l"] = "@loop.outer",
							[")r"] = "@return.inner",
							[")i"] = "@conditional.outer",
							[")a"] = "@parameter.outer",
						},
						goto_next_end = {
							[")T"] = "@comment.outer",
							[")F"] = "@function.outer",
							[")C"] = "@class.outer",
							[")L"] = "@loop.outer",
							[")R"] = "@return.inner",
							[")I"] = "@conditional.outer",
							[")A"] = "@parameter.outer",
						},
						goto_previous_start = {
							["(t"] = "@comment.outer",
							["(f"] = "@function.outer",
							["(c"] = "@class.outer",
							["(l"] = "@loop.outer",
							["(r"] = "@return.inner",
							["(i"] = "@conditional.outer",
							["(a"] = "@parameter.outer",
						},
						goto_previous_end = {
							["(T"] = "@comment.outer",
							["(F"] = "@function.outer",
							["(C"] = "@class.outer",
							["(L"] = "@loop.outer",
							["(R"] = "@return.inner",
							["(I"] = "@conditional.outer",
							["(A"] = "@parameter.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>sa"] = "@parameter.inner",
							["<leader>sf"] = "@function.outer",
							["<leader>sc"] = "@class.outer",
						},
						swap_previous = {
							["<leader>sA"] = "@parameter.inner",
							["<leader>sF"] = "@function.outer",
							["<leader>sC"] = "@class.outer",
						},
					},
				},
			})
		end,
	},
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = {
			{ "nvim-telescope/telescope.nvim" },
		},
		config = function()
			require("neoclip").setup()
		end,
	},
	"christoomey/vim-tmux-navigator",
	{
		"danymat/neogen",
		config = function()
			local neogen = require("neogen")
			neogen.setup()
			vim.keymap.set("n", "<leader>lg", neogen.generate)
		end,
	},
}
