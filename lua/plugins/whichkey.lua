-- Keymap discovery popup (which-key.nvim): after pressing a prefix such as
-- <leader>g, a popup lists the keys that can follow and what they do. It
-- reads the `desc` set on each mapping; the group labels below name the
-- prefixes this config uses.
--
-- which-key adds no keymaps of its own; it only documents the existing ones.

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "find (telescope)" },
        { "<leader>fd", group = "find: dap" },
        { "<leader>g", group = "git / review" },
        { "<leader>h", group = "git hunks" },
        { "<leader>c", group = "copy" },
        { "<leader>d", group = "debug (DAP)" },
        { "<leader>b", group = "database" },
        { "<leader>x", group = "diagnostics & lists" },
        { "<leader>l", group = "lsp / code" },
        { "<leader>r", group = "refactor" },
        { "<leader>s", group = "search & replace" },
        { "<leader>t", group = "test" },
        { "<leader>p", group = "debugprint / paste" },
        { "<leader>n", group = "mnemonic" },
      })
    end,
  },
}
