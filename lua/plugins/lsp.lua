vim.filetype.add({ extension = { service = 'systemd' } })
-- vim.filetype.add({ pattern = { ["swagger.yaml"] = 'swagger' } })

function lsp_key_mapping()
  vim.keymap.set("n", "gD", vim.lsp.buf.definition)
  vim.keymap.set("n", "K", vim.lsp.buf.hover)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
  vim.keymap.set("n", "gr", vim.lsp.buf.references)
  vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol)
  vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol)
  vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run)
  vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help)
  vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename)
  vim.keymap.set("n", "<leader>lf", require("conform").format)
  vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action)
  vim.keymap.set("n", "<leader>lz", function() vim.lsp.buf.code_action({ context = { only = { "source" } } }) end)
  vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist)
  vim.keymap.set("n", "<leader>ae", function()
    vim.diagnostic.setqflist({ severity = "E" })
  end)
  vim.keymap.set("n", "<leader>aw", function()
    vim.diagnostic.setqflist({ severity = "W" })
  end)
  vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist)
  vim.keymap.set("n", "[c", function()
    vim.diagnostic.goto_prev({ wrap = false })
  end)
  vim.keymap.set("n", "]c", function()
    vim.diagnostic.goto_next({ wrap = false })
  end)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if vim.lsp.get_client_by_id(args.data.client_id).name ~= "metals" then
      lsp_key_mapping()
    end
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      for server, config in pairs(opts.servers or {}) do
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ansiblels",
          "bashls",
          "clangd",
          "cssls",
          "dockerls",
          "elixirls",
          "glsl_analyzer",
          "gopls",
          "html",
          "intelephense",
          "vacuum",
          "jsonls",
          "kotlin_language_server",
          "ltex",
          "lua_ls",
          "markdown_oxide",
          "pyright",
          "rust_analyzer",
          "sqlls",
          "terraformls",
          -- "ts_ls",
          "systemd_ls"
        },
      })

      local lsp = require("lspconfig")
      lsp.ansiblels.setup({})
      lsp.bashls.setup({})
      lsp.clangd.setup({})
      lsp.cssls.setup({})
      lsp.dockerls.setup({})
      lsp.slint_lsp.setup({
        filetypes = { "slint" },
      })
      lsp.elixirls.setup({
        filetypes = { "elixir", "eelixir", "heex" },
      })
      lsp.glsl_analyzer.setup({})
      lsp.html.setup({})
      lsp.intelephense.setup({})
      lsp.jsonls.setup({})
      lsp.kotlin_language_server.setup({})
      lsp.gopls.setup({})
      lsp.vacuum.setup({})
      lsp.ltex.setup({
        settings = {
          ltex = {
            language = "en",
            diagnosticSeverity = "information",
            set = {
              grammar = true,
              punctuation = true,
              spell = true,
              typography = true,
            },
            completionEnabled = true,
            additionalRules = {
              enablePickyRules = true,
              motherTongue = "en",
            },
          },
        },
      })
      lsp.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
      lsp.markdown_oxide.setup({})
      lsp.pyright.setup({
        on_attach = on_attach,
        settings = {
          pyright = { autoImportCompletion = true },
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      lsp.rust_analyzer.setup({})
      lsp.scala_language_server = nil
      lsp.sqlls.setup({})
      lsp.systemd_ls.setup({})
      lsp.terraformls.setup({})
      -- lsp.ts_ls.setup({})
      lsp.eslint.setup({
        settings = {
          rulesCustomizations = {
            { rule = '@typescript-eslint/no-explicit-any', severity = 'off' }
          },
          format = false,
        },
      })
    end,
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "super-tab",
        ["<C-\\>"] = { "accept" },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },

      -- accept = { auto_brackets = { enabled = true } },

      -- trigger = { signature_help = { enabled = true } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "dadbod" },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "j-hui/fidget.nvim",
        opts = {},
      },
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
      local metals_config = require("metals").bare_config()
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      }

      metals_config.init_options.statusBarProvider = "off"

      metals_config.on_attach = function(client, bufnr)
        local metals = require("metals")
        lsp_key_mapping()
        vim.keymap.set("n", "lh", metals.hover_worksheet)
        vim.keymap.set("n", "<leader>le", metals.run_scalafix())
        return metals_config
      end
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = self.ft,
        callback = function()
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*",
            callback = function()
              vim.lsp.buf.format()
            end,
          })
          lsp_key_mapping()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")

      vim.keymap.set({ "i" }, "<C-K>", function()
        ls.expand()
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-L>", function()
        ls.jump(1)
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-J>", function()
        ls.jump(-1)
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-E>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })

      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  { "davidmh/cspell.nvim" },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    depends = { "davidmh/cspell.nvim" },
    opts = function(_, opts)
      local cspell = require("cspell")
      opts.sources = opts.sources or {}
      table.insert(
        opts.sources,
        cspell.diagnostics.with({
          diagnostics_postprocess = function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity.HINT
          end,
        })
      )
      table.insert(opts.sources, cspell.code_actions)
    end,
    config = function()
      local cspell = require("cspell")
      require("null-ls").setup({
        fallback_severity = vim.diagnostic.severity.HINT,
        sources = {
          cspell.diagnostics,
          cspell.code_actions,
        },
      })
    end,
  },
}
