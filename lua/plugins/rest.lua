-- HTTP client (rest.nvim): send the request under the cursor in a .http
-- file. Bound to <leader>c (`:Rest run`) in terminal.lua.

return {
  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("rest-nvim").setup({})
    end,
  },
}
