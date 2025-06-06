return {
	"folke/neodev.nvim",
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
	"nvim-lua/plenary.nvim",
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				background_colour = "#000000",
				timeout = 2000,
				fps = 24,
				max_width = 50,
				max_height = 5,
			})
		end,
	},
}
