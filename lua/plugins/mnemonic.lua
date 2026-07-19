return {
  "Yeijon/mnemonic.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "stevearc/dressing.nvim", -- optional but recommended
  },
  config = function()
    require("mnemonic").setup({
      -- Path to your notes vault, backlinks selector root path
      vault = "~/notes",

      -- Max cards you can create per topic per day
      daily_limit = 5,

      -- FSRS target retrievability (0.9 = review at 90% recall probability)
      target_retrievability = 0.9,

      -- Keymaps (customize as needed)
      keymaps = {
        new_card = "<leader>nca", -- Add a new card
        review = "<leader>ncr", -- Start a review session
        manage = "<leader>nct", -- Manage topics
        cards = "<leader>ncm", -- Browse / edit / delete cards
      },
    })
  end,
}
