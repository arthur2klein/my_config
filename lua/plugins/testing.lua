-- Test runner (neotest).
--
-- neotest drives PHPUnit (with Xdebug/DAP), pytest and jest. More test
-- keymaps (run all, last, output, source/test toggle) live in php.lua.
--
-- Keymaps:
--   <leader>tt   run the nearest test (opens the summary)
--   <leader>tf   run every test in the current file
--   <leader>td   debug the nearest test under Xdebug/DAP
--   <leader>ts   stop the running tests
--   <leader>to   toggle the test summary panel

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "olimorris/neotest-phpunit",
    },
    config = function()
      local neotest = require("neotest")

      -- Our preferred xdebug startup flags. neotest-phpunit hardcodes
      -- runtimeArgs to just { "-dzend_extension=xdebug.so" } in its DAP
      -- strategy builder, overwriting whatever we pass via opts. We rewrite
      -- the spec after build_spec to put the real flags back.
      local php_runtime_args = {
        "-dxdebug.mode=debug",
        "-dxdebug.start_with_request=yes",
        "-dxdebug.client_host=127.0.0.1",
        "-dxdebug.client_port=9003",
        "-dxdebug.discover_client_host=false",
      }

      local phpunit_adapter = require("neotest-phpunit")({
        phpunit_cmd = function()
          if vim.fn.filereadable("vendor/bin/phpunit") == 1 then
            return "vendor/bin/phpunit"
          end
          return "phpunit"
        end,
        dap = {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug (neotest)",
          port = 9003,
          -- Set vim.g.php_dap_stop_on_entry = true to pause at script entry
          -- (useful when verifying xdebug is connecting at all).
          stopOnEntry = vim.g.php_dap_stop_on_entry == true,
          pathMappings = vim.g.php_dap_path_mappings or vim.empty_dict(),
        },
        filter_dirs = vim.g.neotest_phpunit_filter_dirs or {
          "vendor",
          "node_modules",
          "resources",
          ".git",
          "var",
          "storage",
        },
      })

      local original_build_spec = phpunit_adapter.build_spec
      phpunit_adapter.build_spec = function(args)
        local spec = original_build_spec(args)
        if spec and type(spec.strategy) == "table" and spec.strategy.type == "php" then
          spec.strategy.runtimeArgs = php_runtime_args
        end
        return spec
      end

      neotest.setup({
        adapters = {
          require("neotest-python"),
          require("neotest-jest"),
          phpunit_adapter,
        },
        status = { virtual_text = true, signs = true },
        output = { open_on_run = false },
        quickfix = { enabled = false, open = false },
        summary = { open = "botright vsplit | vertical resize 50" },
        discovery = {
          -- Per-project escape hatch: in .nvim.lua, set
          --   vim.g.neotest_discovery_disabled = true
          -- to skip the up-front scan entirely (tests are then only known
          -- when you run them by file/cursor).
          enabled = not vim.g.neotest_discovery_disabled,
          concurrent = 1,
          filter_dir = function(name)
            return name ~= "vendor"
              and name ~= "node_modules"
              and name ~= ".git"
              and name ~= "var"
              and name ~= "storage"
              and name ~= "resources"
          end,
        },
      })
      local function notify(msg, level)
        vim.notify(msg, level or vim.log.levels.INFO, { title = "neotest" })
      end

      vim.keymap.set("n", "<leader>tt", function()
        notify("Running test under cursor")
        neotest.summary.open()
        neotest.run.run()
      end, { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>tf", function()
        notify("Running file: " .. vim.fn.expand("%:t"))
        neotest.summary.open()
        neotest.run.run(vim.fn.expand("%"))
      end, { desc = "Run tests in current file" })
      vim.keymap.set("n", "<leader>td", function()
        notify("Launching test under DAP (waiting for Xdebug)")
        neotest.summary.open()
        neotest.run.run({ strategy = "dap" })
      end, { desc = "Debug nearest test (DAP)" })
      vim.keymap.set("n", "<leader>ts", function()
        notify("Stopping tests", vim.log.levels.WARN)
        neotest.run.stop()
      end, { desc = "Stop running tests" })
      vim.keymap.set("n", "<leader>to", neotest.summary.toggle, { desc = "Toggle test summary" })
    end,
  },
}
