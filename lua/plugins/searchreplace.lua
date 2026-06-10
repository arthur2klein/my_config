-- Project-wide search and replace (grug-far.nvim): a dedicated buffer where
-- you edit search/replace/filter fields and apply the change across every
-- matching file at once (ripgrep under the hood).
--
-- Keymaps:
--   <leader>R    open search & replace
--   <leader>R    (visual) search & replace, scoped to the selection
--   <leader>rw   search & replace the word under the cursor

return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>R",
        function()
          require("grug-far").open()
        end,
        mode = "n",
        desc = "Search & replace (project)",
      },
      {
        "<leader>R",
        function()
          require("grug-far").with_visual_selection()
        end,
        mode = "v",
        desc = "Search & replace (selection)",
      },
      {
        "<leader>rw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        mode = "n",
        desc = "Search & replace word under cursor",
      },
    },
    opts = {},
  },
}
