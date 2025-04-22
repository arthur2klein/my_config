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
			notify.setup({ background_colour = "#000000" })
		end,
	},
}
