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
      "sidlatau/neotest-dart",
      "olimorris/neotest-phpunit",
      "stevanmilic/neotest-scala",
      "rcasia/neotest-java",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-python"),
          require("neotest-jest"),
          require("neotest-dart"),
          require("neotest-phpunit"),
          require("neotest-scala"),
          require("neotest-java"),
        },
      })
      vim.keymap.set("n", "<leader>tt", neotest.run.run)
      vim.keymap.set("n", "<leader>tf", function()
        neotest.run.run(vim.fn.expand("%"))
      end)
      vim.keymap.set("n", "<leader>td", function()
        require("neotest").run.run({ strategy = "dap" })
      end)
      vim.keymap.set("n", "<leader>ts", neotest.run.stop)
      vim.keymap.set("n", "<leader>to", neotest.summary.toggle)
    end,
  },
  {
    "michaelb/sniprun",
    branch = "master",

    build = "sh install.sh",

    config = function()
      require("sniprun").setup({
        repl_enable = { "Python3_original" },
      })
      vim.api.nvim_set_keymap("v", "<leader>r", "<Plug>SnipRun", { silent = true })
      vim.api.nvim_set_keymap("n", "<leader>r", "<Plug>SnipRun", { silent = true })
    end,
    {
      "https://gitlab.com/schrieveslaach/sonarlint.nvim",
      config = function()
        require("sonarlint").setup({
          server = {
            cmd = {
              "sonarlint-language-server",
              "-stdio",
              "-analyzers",
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjs.jar"),
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonargo.jar"),
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarphp.jar"),
            },
          },
          filetypes = {
            "python",
            "cpp",
            "java",
            "go",
            "py",
            "js",
            "ts",
            "tsx",
          },
        })
      end,
    },
  },
}
