vim.keymap.set("n", "<leader>ga", function()
	vim.cmd("!git add %")
end)
return {
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			local gitsigns = require("gitsigns")
			gitsigns.setup({})
			vim.keymap.set("n", "<leader>gb", function()
				vim.cmd("Gitsigns blame_line")
			end)
		end,
	},
	{
		"sindrets/diffview.nvim",
		config = function()
			require("diffview").setup({})
			vim.keymap.set("n", "<leader>gd", function()
				vim.cmd("DiffviewOpen")
			end)
			vim.keymap.set("n", "<leader>gc", function()
				vim.cmd("DiffviewClose")
			end)
		end,
	},
	{
		name = "convcommit",
		lazy = false,
		dir = "~/.config/nvim/lua/custom/convcommit",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function()
			local convcommit = require("custom.convcommit")
			vim.keymap.set("n", "<leader>gg", convcommit.create_commit)
			vim.keymap.set("n", "<leader>gv", convcommit.create_version_tag)
			vim.keymap.set("n", "<leader>gp", convcommit.push)
			vim.keymap.set("n", "<leader>ga", convcommit.git_add)
		end,
	},
	"kshenoy/vim-signature",
}
