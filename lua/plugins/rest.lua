return {
	{
		"rest-nvim/rest.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			opts = function(_, opts)
				opts.ensure_installed = opts.ensure_installed or {}
				table.insert(opts.ensure_installed, "http")
			end,
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"bash",
						"bibtex",
						"c",
						"cmake",
						"cpp",
						"dart",
						"elixir",
						"html",
						"http",
						"glsl",
						"go",
						"latex",
						"java",
						"javascript",
						"lua",
						"markdown",
						"markdown_inline",
						"php",
						"python",
						"query",
						"rust",
						"scala",
						"slint",
						"typescript",
						"vim",
						"vimdoc",
					},
					highlight = {
						enable = true,
					},
				})
			end,
		},
	},
}
