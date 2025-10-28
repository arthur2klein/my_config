return {
  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      local conform = require("conform")
      conform.setup({
        default_format_opts = {
          async = false,
          timeout_ms = 5000,
          lsp_fallback = true,
        },
        formatters = {
          markdownlint = {
            command = "markdownlint",
            stdin = true,
          },
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          c = { "clang_format" },
          cl = { "clang_format" },
          glsl = { "clang_format" },
          php = { "pretty-php" },
          rust = { "rustfmt" },
          sql = { "sql_formatter" },
          tex = { "latexindent" },
          markdown = { "doctoc" },
          javascript = { "prettier", stop_after_first = true },
          typescript = { "prettier", stop_after_first = true },
          typescriptreact = { "prettier", stop_after_first = true },
          javascriptreact = { "prettier", stop_after_first = true },
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
          conform.format({ async = false, lsp_fallback = true, timeout_ms = 1000, })
        end,
      })
    end,
  },
}
