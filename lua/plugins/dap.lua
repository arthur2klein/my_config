-- Per-project DAP customization:
-- A project's `.nvim.lua` can override the Xdebug path mapping by writing
--   vim.g.php_dap_path_mappings = { ["/container/path"] = vim.fn.getcwd() }
-- before the DAP session starts. The default below matches the common
-- `/var/www/html` docker mount.

local function php_path_mappings()
  if type(vim.g.php_dap_path_mappings) == "table" and not vim.tbl_isempty(vim.g.php_dap_path_mappings) then
    return vim.g.php_dap_path_mappings
  end
  return { ["/var/www/html"] = "${workspaceFolder}" }
end

return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { "/root/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
      }
      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
          pathMappings = php_path_mappings(),
        },
      }
      local dap_widgets = require("dap.ui.widgets")
      vim.keymap.set("n", "<leader>dd", dap.continue)
      vim.keymap.set("n", "<leader>du", dap.step_over)
      vim.keymap.set("n", "<leader>di", dap.step_into)
      vim.keymap.set("n", "<leader>do", dap.step_out)
      vim.keymap.set("n", "<Leader>dm", dap.toggle_breakpoint)
      vim.keymap.set("n", "<Leader>dl", dap.repl.open)
      vim.keymap.set("n", "<Leader>dp", dap.run_last)
      vim.keymap.set({ "n", "v" }, "<Leader>dj", dap_widgets.hover)
      vim.keymap.set({ "n", "v" }, "<Leader>dk", dap_widgets.preview)
      vim.keymap.set("n", "<Leader>dy", function()
        dap_widgets.centered_float(dap_widgets.frames)
      end)
      vim.keymap.set("n", "<Leader>dh", function()
        dap_widgets.centered_float(dap_widgets.scopes)
      end)
      vim.keymap.set("n", "<Leader>dB", function()
        require("dap").list_breakpoints()
        vim.cmd("copen")
      end, { desc = "Show all breakpoints (quickfix)" })

      -- Visible feedback for debug session lifecycle, so you can tell whether
      -- Xdebug actually connected vs. nothing happening.
      local function notify(msg, level)
        vim.notify(msg, level or vim.log.levels.INFO, { title = "dap" })
      end
      dap.listeners.after.event_initialized["notify_user"] = function()
        notify("Debug session started")
      end
      dap.listeners.after.event_stopped["notify_user"] = function(_, body)
        local reason = body and body.reason or "stopped"
        notify("Paused: " .. reason)
      end
      dap.listeners.after.event_terminated["notify_user"] = function()
        notify("Debug session terminated")
      end
      dap.listeners.after.event_exited["notify_user"] = function(_, body)
        local code = body and body.exitCode
        notify("Process exited" .. (code ~= nil and (" (code " .. tostring(code) .. ")") or ""))
      end
    end,
  },
  { "theHamsta/nvim-dap-virtual-text", config = true },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.4 },
              { id = "breakpoints", size = 0.2 },
              { id = "stacks", size = 0.2 },
              { id = "watches", size = 0.2 },
            },
            position = "left",
            size = 50,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 12,
          },
        },
      })
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      -- Don't auto-close on terminate/exit: fast tests would flash dap-ui
      -- open then closed before you can read it. Toggle manually with <leader>dt.

      vim.keymap.set("n", "<leader>dt", dapui.toggle)
      vim.keymap.set({ "n", "v" }, "<leader>de", function()
        dapui.eval(nil, { enter = true })
      end)
    end,
  },
}
