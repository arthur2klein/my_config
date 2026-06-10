-- LaTeX editing (vimtex), previewed with zathura. vimtex provides its own
-- <localleader>l... keymaps (e.g. \ll to compile, \lv to view).

return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
    end,
  },
}
