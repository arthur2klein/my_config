-- File explorer (oil.nvim): edit the filesystem like a normal buffer.
--
-- Keymaps:
--   è            open the parent directory in oil
--
-- Inside oil, `-` goes up a directory and `:w` applies any
-- create / rename / delete / move you typed into the buffer.

return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        view_options = {
          show_hidden = true,
        },
      })
      vim.keymap.set("n", "è", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end,
  },
}
