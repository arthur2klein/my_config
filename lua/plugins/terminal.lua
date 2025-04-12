return {
	{
		name = "floaterminal",
		dir = "~/.config/nvim/lua/custom/floaterminal",
		lazy = false,
		config = function()
			vim.keymap.set("t", "<F3>", "<c-\\><c-n>")
			local floaterminal = require("custom.floaterminal")

			vim.api.nvim_create_user_command("Floaterminal", floaterminal.toggle_terminal, {})
			vim.api.nvim_set_keymap("n", "<F3>", ":Floaterminal<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "<leader>c", ":Rest run<CR>", { noremap = true })
		end,
	},
}
