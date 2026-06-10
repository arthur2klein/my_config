-- Diagnostics, symbols and list views (trouble.nvim).
--
-- Keymaps:
--   <leader>xx   toggle the diagnostics list
--   <leader>xe   toggle the diagnostics list, errors only
--   <leader>xs   toggle the symbols outline
--   <leader>xl   toggle LSP definitions / references / ...
--   <leader>xL   toggle the location list
--   <leader>xQ   toggle the quickfix list

return {
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle win.wo.wrap=true win.position=right win.size.width=40 win.relative=win<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xe",
        "<cmd>Trouble diagnostics toggle win.wo.wrap=true win.position=right win.size.width=40 win.relative=win filter.severity=vim.diagnostic.severity.ERROR<cr>",
        desc = "Errors only (Trouble)",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
}
