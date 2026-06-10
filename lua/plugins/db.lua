-- Database client: vim-dadbod with the dadbod-ui drawer and SQL/Mongo
-- completion. Connections come from lua/dbs.lua (copy dbs.lua.example);
-- saved queries are version-controlled under ~/my_config/queries.
--
-- Keymaps:
--   <leader>D    toggle the DBUI drawer
--   <leader>df   find / jump to a DBUI buffer
--   <leader>dr   rename the current DBUI buffer
--   <leader>dq   show info on the last query
--   <leader>r    (n/v, in a query buffer) execute the query / selection
--   <leader>w    (in a query buffer) save the query
--
-- Commands: DBUI, DBUIToggle, DBUIAddConnection, DBUIFindBuffer,
-- DBUIRenameBuffer, DBUILastQueryInfo.

return {
  "tpope/vim-dadbod",
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql", "mariadb", "mongodb" },
        lazy = true,
      },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
      "DBUIRenameBuffer",
      "DBUILastQueryInfo",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      -- Named saved queries live in the repo so they are version-controlled.
      -- Scratch buffers stay in stdpath('data')/db_ui by default.
      vim.g.db_ui_save_location = vim.fn.expand("~/my_config/queries")
      -- Explicit execution only (matches PhpStorm muscle memory).
      vim.g.db_ui_execute_on_save = 0
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 35
      vim.g.db_ui_force_echo_notifications = 0
      vim.g.db_ui_use_nvim_notify = 1
      vim.g.db_ui_disable_mappings = 0
    end,
    config = function()
      local ok, dbs = pcall(require, "dbs")
      vim.g.dbs = ok and dbs.dbs or {}
      if not ok then
        vim.schedule(function()
          vim.notify(
            "dbs.lua not found at ~/.config/nvim/lua/dbs.lua. "
              .. "Copy lua/dbs.lua.example from this repo to bootstrap.",
            vim.log.levels.WARN
          )
        end)
      end

      vim.keymap.set("n", "<leader>D", "<cmd>DBUIToggle<cr>", { desc = "DBUI: toggle drawer" })
      vim.keymap.set("n", "<leader>df", "<cmd>DBUIFindBuffer<cr>", { desc = "DBUI: find buffer" })
      vim.keymap.set("n", "<leader>dr", "<cmd>DBUIRenameBuffer<cr>", { desc = "DBUI: rename buffer" })
      vim.keymap.set("n", "<leader>dq", "<cmd>DBUILastQueryInfo<cr>", { desc = "DBUI: last query info" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbout",
        callback = function(args)
          vim.opt_local.foldenable = false
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql", "mariadb", "mongodb" },
        callback = function(args)
          vim.keymap.set(
            "n",
            "<leader>r",
            "<Plug>(DBUI_ExecuteQuery)",
            { buffer = args.buf, desc = "DBUI: execute query" }
          )
          vim.keymap.set(
            "v",
            "<leader>r",
            "<Plug>(DBUI_ExecuteQuery)",
            { buffer = args.buf, desc = "DBUI: execute selection" }
          )
          vim.keymap.set(
            "n",
            "<leader>w",
            "<Plug>(DBUI_SaveQuery)",
            { buffer = args.buf, desc = "DBUI: save query" }
          )
        end,
      })
    end,
  },
}
