-- Syntax: treesitter (parsers + highlighting) and extra language plugins
-- (kotlin, cypher, css-color, svelte, freemarker). No keymaps.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "bibtex",
        "c",
        "cmake",
        "cpp",
        "dart",
        "elixir",
        "html",
        "http",
        "glsl",
        "go",
        "latex",
        "java",
        "javascript",
        "lua",
        "markdown",
        "markdown_inline",
        "php",
        "python",
        "query",
        "rust",
        "scala",
        "slint",
        "typescript",
        "vim",
        "vimdoc",
      })

      local highlight_disabled_filetypes = { php = true }
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if ft == "" or highlight_disabled_filetypes[ft] then
            return
          end
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  "udalov/kotlin-vim",
  "memgraph/cypher.vim",
  "ap/vim-css-color",
  "evanleck/vim-svelte",
  "andreshazard/vim-freemarker",
}
