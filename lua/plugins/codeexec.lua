return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
			"nvim-neotest/neotest-jest",
			"sidlatau/neotest-dart",
			"olimorris/neotest-phpunit",
			"stevanmilic/neotest-scala",
			"rcasia/neotest-java",
		},
		config = function()
			local neotest = require("neotest")
			neotest.setup({
				adapters = {
					require("neotest-python"),
					require("neotest-jest"),
					require("neotest-dart"),
					require("neotest-phpunit"),
					require("neotest-scala"),
					require("neotest-java"),
				},
			})
			vim.keymap.set("n", "<leader>tt", neotest.run.run)
			vim.keymap.set("n", "<leader>tf", function()
				neotest.run.run(vim.fn.expand("%"))
			end)
			vim.keymap.set("n", "<leader>td", function()
				require("neotest").run.run({ strategy = "dap" })
			end)
			vim.keymap.set("n", "<leader>ts", neotest.run.stop)
			vim.keymap.set("n", "<leader>to", neotest.summary.toggle)
		end,
	},
}
