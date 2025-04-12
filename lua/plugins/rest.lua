return {
	{
		"rest-nvim/rest.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("rest-nvim").setup({})
		end,
	},
}
