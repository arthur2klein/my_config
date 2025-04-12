return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
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
	"udalov/kotlin-vim",
	"memgraph/cypher.vim",
	"ap/vim-css-color",
	"evanleck/vim-svelte",
	"andreshazard/vim-freemarker",
}
