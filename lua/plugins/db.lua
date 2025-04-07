return {
	"tpope/vim-dadbod",
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{
				"kristijanhusak/vim-dadbod-completion",
				ft = { "sql", "mysql", "plsql", "mariadb", "mongodb" },
				lazy = true,
			},
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
		end,
		config = function()
			vim.g.dbs = require("dbs").dbs
			vim.keymap.set("n", "<leader>D", function()
				vim.cmd("DBUIToggle")
			end, {})
		end,
	},
}
