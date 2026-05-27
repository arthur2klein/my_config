return {
  {
    "stevearc/conform.nvim",
    config = function()
      local conform = require("conform")

      -- Cache PHP formatter detection per buffer so we don't stat the FS on
      -- every BufWritePre. The result depends only on what config files the
      -- project ships, so it's stable for the buffer's lifetime.
      local php_fmt_cache = {}
      local function php_formatters(bufnr)
        if php_fmt_cache[bufnr] ~= nil then
          return php_fmt_cache[bufnr]
        end
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname == "" then
          return {}
        end
        local dir = vim.fs.dirname(fname)
        local cs_fixer = vim.fs.find(
          { ".php-cs-fixer.dist.php", ".php-cs-fixer.php" },
          { upward = true, path = dir, type = "file" }
        )[1]
        if cs_fixer then
          php_fmt_cache[bufnr] = { "php_cs_fixer" }
          return php_fmt_cache[bufnr]
        end
        local phpcs = vim.fs.find(
          { "phpcs.xml", "phpcs.xml.dist" },
          { upward = true, path = dir, type = "file" }
        )[1]
        if phpcs then
          php_fmt_cache[bufnr] = { "phpcbf" }
          return php_fmt_cache[bufnr]
        end
        -- No team config: skip auto-format to avoid diverging from colleagues.
        php_fmt_cache[bufnr] = {}
        return php_fmt_cache[bufnr]
      end

      vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(args)
          php_fmt_cache[args.buf] = nil
        end,
      })

      conform.setup({
        default_format_opts = {
          async = false,
          timeout_ms = 5000,
          lsp_fallback = true,
        },
        formatters = {
          php_cs_fixer = {
            -- Prefer vendor/bin/php-cs-fixer (matches team rules and version);
            -- fall back to the Mason-installed binary.
            prefer_local = "vendor/bin",
            prepend_args = { "--using-cache=no" },
          },
          phpcbf = {
            prefer_local = "vendor/bin",
          },
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          c = { "clang_format" },
          cl = { "clang_format" },
          glsl = { "clang_format" },
          php = php_formatters,
          rust = { "rustfmt" },
          sql = { "sql_formatter" },
          tex = { "latexindent" },
          markdown = { "markdownlint-cli2" },
          javascript = { "prettier", stop_after_first = true },
          typescript = { "prettier", stop_after_first = true },
          typescriptreact = { "prettier", stop_after_first = true },
          javascriptreact = { "prettier", stop_after_first = true },
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          -- Skip PHP buffers without a team CS config; let LSP/intelephense
          -- handle requested-only formatting instead of running on every save.
          if vim.bo[args.buf].filetype == "php" then
            local fmts = php_formatters(args.buf)
            if #fmts == 0 then
              return
            end
          end
          conform.format({ async = false, lsp_fallback = true, timeout_ms = 1000 })
        end,
      })

      vim.keymap.set("n", "<leader>lF", function()
        conform.format({ async = false, lsp_fallback = true, timeout_ms = 5000 })
      end, { desc = "Force-format current buffer (bypasses team-config gate)" })
    end,
  },
}
