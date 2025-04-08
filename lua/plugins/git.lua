return {
	{
		"lewis6991/gitsigns.nvim",
		setup = function()
			require("gitsigns").setup({})
		end,
	},
	"sindrets/diffview.nvim",
	{
		name = "convcommit",
		lazy = false,
		dir = "~/.config/nvim/lua/custom/convcommit",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			local convcommit = require("custom.convcommit")
			vim.keymap.set("n", "<leader>gg", convcommit.create_commit)
		end,
	},
	"kshenoy/vim-signature",
}
