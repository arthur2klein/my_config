-- LSP stack: lspconfig + mason (servers/tools), blink.cmp (completion),
-- LuaSnip (snippets), none-ls (cspell + phpstan diagnostics) and
-- render-markdown. intelephense's PHP version is read from composer.json.
--
-- LSP keymaps (set on attach):
--   gD           go to definition
--   K            hover documentation
--   gi           go to implementation
--   gr           list references
--   gy           go to type definition
--   gds / gws    document / workspace symbols
--   <leader>la   code action
--   <leader>lz   source-level code action
--   <leader>rr   rename (refactor namespace)
--   <leader>lf   format (conform)
--   <leader>lc   run code lens
--   <leader>ls   signature help
--   <leader>lh / lH   parent (super) / child (sub) types
--   <leader>li / lo   incoming / outgoing calls
--   <leader>le   run scalafix (metals only)
--
-- Diagnostics (the <leader>x list/diagnostics namespace; trouble adds the
-- rest of <leader>x in diagnostic.lua):
--   <leader>xa   send all diagnostics to the quickfix
--   <leader>xw   send warnings to the quickfix
--   <leader>xd   send buffer diagnostics to the location list
--   [c / ]c      previous / next diagnostic
--
-- Completion / snippets:
--   <Tab>            accept (blink.cmp super-tab); <C-\> also accepts
--   <C-K>            expand a snippet (LuaSnip)
--   <C-L> / <C-J>    jump to the next / previous snippet node
--   <C-E>            cycle the snippet choice

vim.filetype.add({ extension = { service = "systemd" } })
-- vim.filetype.add({ pattern = { ["swagger.yaml"] = 'swagger' } })

-- Some servers (notably vtsls/tsserver for merged value+type declarations or
-- re-exports) return the same location more than once, and Neovim's default
-- handler then prompts you to pick between identical entries. Collapse
-- duplicates by file:line:col so an unambiguous result jumps straight away.
local function goto_definition()
  vim.lsp.buf.definition({
    on_list = function(options)
      local seen, items = {}, {}
      for _, item in ipairs(options.items) do
        local key = ("%s:%d:%d"):format(item.filename, item.lnum, item.col)
        if not seen[key] then
          seen[key] = true
          items[#items + 1] = item
        end
      end
      vim.fn.setqflist({}, " ", { title = options.title, items = items })
      if #items == 1 then
        vim.cmd.cfirst()
      else
        vim.cmd.copen()
      end
    end,
  })
end

local function lsp_key_mapping()
  vim.keymap.set("n", "gD", goto_definition, { desc = "Go to definition" })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
  vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "List references" })
  vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol, { desc = "Document symbols" })
  vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbols" })
  vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run, { desc = "Run code lens" })
  vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "Signature help" })
  vim.keymap.set("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Rename symbol" })
  vim.keymap.set("n", "<leader>lf", require("conform").format, { desc = "Format buffer" })
  vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
  vim.keymap.set("n", "<leader>lz", function()
    vim.lsp.buf.code_action({ context = { only = { "source" } } })
  end, { desc = "Source-level code action" })
  vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
  vim.keymap.set("n", "<leader>lh", function()
    vim.lsp.buf.typehierarchy("supertypes")
  end, { desc = "Parent classes (supertypes)" })
  vim.keymap.set("n", "<leader>lH", function()
    vim.lsp.buf.typehierarchy("subtypes")
  end, { desc = "Child classes (subtypes)" })
  vim.keymap.set("n", "<leader>li", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
  vim.keymap.set("n", "<leader>lo", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls" })
  vim.keymap.set("n", "<leader>xa", vim.diagnostic.setqflist, { desc = "All diagnostics to quickfix" })
  vim.keymap.set("n", "<leader>xw", function()
    vim.diagnostic.setqflist({ severity = "W" })
  end, { desc = "Warnings to quickfix" })
  vim.keymap.set("n", "<leader>xd", vim.diagnostic.setloclist, { desc = "Buffer diagnostics to loclist" })
  vim.keymap.set("n", "[c", function()
    vim.diagnostic.goto_prev({ wrap = false })
  end, { desc = "Previous diagnostic" })
  vim.keymap.set("n", "]c", function()
    vim.diagnostic.goto_next({ wrap = false })
  end, { desc = "Next diagnostic" })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    lsp_key_mapping()
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "metals" then
      vim.keymap.set("n", "<leader>le", function()
        client:request("workspace/executeCommand", { command = "scalafix-run" }, nil, args.buf)
      end, { buffer = args.buf, desc = "Run scalafix (metals)" })
    end
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "php-debug-adapter",
          "php-cs-fixer",
          "phpcs",
          "phpcbf",
          "phpstan",
          "phpactor",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      require("mason").setup()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
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
          "phpactor",
          "vacuum",
          "jsonls",
          "kotlin_language_server",
          "ltex",
          "lua_ls",
          "markdown_oxide",
          "metals",
          "pyright",
          "rust_analyzer",
          "sqlls",
          "terraformls",
          "vtsls",
          "systemd_ls",
        },
      })

      vim.lsp.enable({
        "ansiblels",
        "bashls",
        "clangd",
        "cssls",
        "dockerls",
        "slint_lsp",
        "elixirls",
        "glsl_analyzer",
        "html",
        "intelephense",
        "phpactor",
        "jsonls",
        "kotlin_language_server",
        "gopls",
        "vacuum",
        "ltex",
        "lua_ls",
        "markdown_oxide",
        "metals",
        "pyright",
        "rust_analyzer",
        "sqlls",
        "systemd_ls",
        "terraformls",
        "vtsls",
        "eslint",
      })

      vim.lsp.config.slint_lsp = {
        filetypes = { "slint" },
      }
      -- Parse the lowest PHP version implied by composer.json `require.php`.
      -- Returns a string like "7.4.0" or nil if no composer.json / no constraint.
      local function detect_php_version(root_dir)
        if not root_dir then
          return nil
        end
        local composer = root_dir .. "/composer.json"
        if vim.fn.filereadable(composer) ~= 1 then
          return nil
        end
        local ok_read, lines = pcall(vim.fn.readfile, composer)
        if not ok_read then
          return nil
        end
        local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
        if not ok_decode or type(decoded) ~= "table" then
          return nil
        end
        local constraint = decoded.require and decoded.require.php
        if type(constraint) ~= "string" then
          return nil
        end
        -- Take the first X.Y found: handles "^7.4", "~7.4", ">=7.4", "7.4.*",
        -- "7.4|8.0" (picks the lower), ">=7.2 <8.2" (picks the lower).
        local major, minor = constraint:match("(%d+)%.(%d+)")
        if not major then
          return nil
        end
        return major .. "." .. minor .. ".0"
      end

      -- phpactor runs alongside intelephense purely for its richer PHP
      -- refactoring code actions (extract method, generate accessors,
      -- import class, move/copy class, etc.). Strip its overlapping
      -- features at attach time so completion/hover/definition stay
      -- intelephense's job and we don't get duplicate results.
      --
      -- Mason's phpactor wrapper invokes `php` from PATH, but on this
      -- machine that's PHP 7.4 — phpactor needs PHP 8.2+. Pin the cmd to
      -- a PHP 8.x binary and bypass the wrapper.
      local function pick_php8()
        for _, c in ipairs({ "php8.3", "php8.4", "php8.5", "php8.2" }) do
          if vim.fn.executable(c) == 1 then
            return c
          end
        end
        return "php"
      end
      local phpactor_phar = vim.fn.stdpath("data") .. "/mason/packages/phpactor/phpactor.phar"
      vim.lsp.config.phpactor = {
        cmd = { pick_php8(), phpactor_phar, "language-server" },
        on_init = function(client)
          local caps = client.server_capabilities
          caps.completionProvider = nil
          caps.hoverProvider = nil
          caps.definitionProvider = nil
          caps.implementationProvider = nil
          caps.referencesProvider = nil
          caps.documentSymbolProvider = nil
          caps.workspaceSymbolProvider = nil
          caps.documentFormattingProvider = nil
          caps.documentRangeFormattingProvider = nil
          caps.signatureHelpProvider = nil
          caps.renameProvider = nil
          caps.documentHighlightProvider = nil
          caps.diagnosticProvider = nil
        end,
      }

      vim.lsp.config.intelephense = {
        init_options = {
          -- Pin the cache location so :IntelephensePurgeCache knows where to look.
          globalStoragePath = vim.fn.stdpath("cache") .. "/intelephense",
        },
        before_init = function(params, config)
          local root
          if params.workspaceFolders and params.workspaceFolders[1] then
            root = vim.uri_to_fname(params.workspaceFolders[1].uri)
          elseif params.rootUri then
            root = vim.uri_to_fname(params.rootUri)
          end
          local php_version = detect_php_version(root) or "8.3.0"
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            intelephense = {
              environment = { phpVersion = php_version },
            },
          })
        end,
        settings = {
          intelephense = {
            environment = {
              phpVersion = "8.3.0",
            },
            files = {
              -- Big repos: bump from the 5MB default so large generated files
              -- (factories, fixtures, locale data) don't get silently skipped.
              maxSize = 5000000,
            },
          },
        },
      }
      vim.lsp.config.elixirls = {
        filetypes = { "elixir", "eelixir", "heex" },
      }
      vim.lsp.config.ltex = {
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
      }
      vim.lsp.config.lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      }
      vim.lsp.config.pyright = {
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
      }
      vim.lsp.config.metals = {
        init_options = {
          statusBarProvider = "off",
        },
        root_markers = {
          "build.sbt",
          "build.sc",
          "build.gradle",
          "build.gradle.kts",
          "pom.xml",
          ".git",
        },
        settings = {
          metals = {
            showImplicitArguments = true,
            excludedPackages = {
              "akka.actor.typed.javadsl",
              "com.github.swagger.akka.javadsl",
            },
          },
        },
      }
      vim.lsp.config.eslint = {
        settings = {
          rulesCustomizations = {
            { rule = "@typescript-eslint/no-explicit-any", severity = "off" },
          },
          format = false,
        },
      }
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
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")

      vim.keymap.set({ "i" }, "<C-K>", function()
        ls.expand()
      end, { silent = true, desc = "Expand snippet" })
      vim.keymap.set({ "i", "s" }, "<C-L>", function()
        ls.jump(1)
      end, { silent = true, desc = "Jump to next snippet node" })
      vim.keymap.set({ "i", "s" }, "<C-J>", function()
        ls.jump(-1)
      end, { silent = true, desc = "Jump to previous snippet node" })
      vim.keymap.set({ "i", "s" }, "<C-E>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "Cycle snippet choice" })

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
      local null_ls = require("null-ls")
      require("null-ls").setup({
        fallback_severity = vim.diagnostic.severity.HINT,
        sources = {
          cspell.diagnostics,
          cspell.code_actions,
          -- PHPStan: only attach if the project ships a phpstan config.
          -- Prefer vendor/bin/phpstan so the analyzer version matches what
          -- the team's CI runs.
          null_ls.builtins.diagnostics.phpstan.with({
            condition = function(utils)
              return utils.root_has_file({
                "phpstan.neon",
                "phpstan.neon.dist",
                "phpstan.dist.neon",
              })
            end,
            method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
            prefer_local = "vendor/bin",
          }),
        },
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      completions = { lsp = { enabled = true } },
      -- LSP hover floats are buftype=nofile and trigger a known crash in the
      -- code-block renderer when the doc has irregular fences. Disable plugin
      -- in those windows; regular .md buffers still render.
      overrides = {
        buftype = {
          nofile = { enabled = false },
        },
      },
    },
  },
}
