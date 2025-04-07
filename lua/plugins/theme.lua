return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = { theme = "palenight" },
			})
			vim.g.airline_powerline_fonts = 1
			vim.g["airline#extensions#tabline#enabled"] = 1
			vim.g.SignatureMarkTextHLDynamic = 1
		end,
	},
	{
		"catppuccin/nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
			vim.cmd("highlight NonText guibg=NONE ctermbg=NONE")
			vim.cmd("try | colorscheme catppuccin-mocha | catch | endtry")
		end,
	},
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require("dashboard").setup({})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},
}
