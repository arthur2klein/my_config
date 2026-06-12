-- Floating terminal (custom, in lua/custom/floaterminal) plus a couple of
-- top-level keymaps.
--
-- Keymaps:
--   <F3>         toggle the floating terminal (in the terminal, leave
--                terminal mode)
--   <leader>R    run the REST request under the cursor (:Rest run)
--
-- Commands: Floaterminal.

return {
  {
    name = "floaterminal",
    dir = "~/.config/nvim/lua/custom/floaterminal",
    lazy = false,
    config = function()
      vim.keymap.set("t", "<F3>", "<c-\\><c-n>", { desc = "Leave terminal mode" })
      local floaterminal = require("custom.floaterminal")

      vim.api.nvim_create_user_command("Floaterminal", floaterminal.toggle_terminal, {})
      vim.api.nvim_set_keymap("n", "<F3>", ":Floaterminal<CR>", { noremap = true, desc = "Toggle floating terminal" })
      vim.api.nvim_set_keymap("n", "<leader>R", ":Rest run<CR>", { noremap = true, desc = "Run REST request under cursor" })
    end,
  },
}
