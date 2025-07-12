vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("i", "<c-l>", "<c-g>u<Esc>[s1z=]a<c-g>u", { noremap = true })
vim.api.nvim_set_keymap("n", "<c-l>", "[s1z=<c-o>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>y", ':call system("tmux load-buffer -", getreg(\'"\'))', { noremap = true })

if os.getenv("TMUX") then
	vim.g.clipboard = {
		name = "tmux",
		copy = {
			["+"] = "tmux load-buffer -",
			["*"] = "tmux load-buffer -",
		},
		paste = {
			["+"] = "tmux save-buffer -",
			["*"] = "tmux save-buffer -",
		},
		cache_enabled = true,
	}
end

return {
	{
		"vim-scripts/loremipsum",
		config = function()
			vim.keymap.set("n", "gl", function()
				vim.cmd("Loremipsum")
			end)
		end,
	},
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
	"mg979/vim-visual-multi",
	{
		"jbyuki/venn.nvim",
		config = function()
			function _G.Toggle_venn()
				local venn_enabled = vim.inspect(vim.b.venn_enabled)
				if venn_enabled == "nil" then
					vim.b.venn_enabled = true
					vim.cmd([[setlocal ve=all]])
					vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", { noremap = true })
					vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", { noremap = true })
					vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", { noremap = true })
					vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", { noremap = true })
					vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
					vim.api.nvim_buf_set_keymap(0, "v", "m", "jlokh", { noremap = true })
				else
					vim.cmd([[setlocal ve=]])
					vim.api.nvim_buf_del_keymap(0, "n", "J")
					vim.api.nvim_buf_del_keymap(0, "n", "K")
					vim.api.nvim_buf_del_keymap(0, "n", "L")
					vim.api.nvim_buf_del_keymap(0, "n", "H")
					vim.api.nvim_buf_del_keymap(0, "v", "f")
					vim.api.nvim_buf_del_keymap(0, "v", "m")
					vim.b.venn_enabled = nil
				end
			end
			vim.api.nvim_set_keymap("n", "<leader>v", ":lua Toggle_venn()<CR>", { noremap = true })
		end,
	},
}
