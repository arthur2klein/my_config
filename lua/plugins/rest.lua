-- HTTP client (rest.nvim): send the request under the cursor in a .http
-- file. Bound to <leader>R (`:Rest run`) in terminal.lua.
--
-- Keymaps:
--   <leader>R    run the REST request under the cursor (:Rest run)

return {
  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("rest-nvim").setup({})
      vim.api.nvim_set_keymap(
        "n",
        "<leader>R",
        ":Rest run<CR>",
        { noremap = true, desc = "Run REST request under cursor" }
      )
    end,
  },
}
