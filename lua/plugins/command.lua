-- Editing and text-manipulation plugins, plus core editing keymaps and
-- system-clipboard integration (Wayland / X11 / tmux auto-detected).
--
-- Plugins: loremipsum, easy-align, nvim-surround, Comment.nvim,
-- debugprint, treesitter-textobjects, neoclip, tmux-navigator, neogen,
-- endec, visual-multi, venn, swagger-preview.
--
-- Keymaps:
--   <C-c>          (i) escape to normal mode
--   <C-l>          fix the last spelling mistake (i and n)
--   <leader>y      (n/v) yank to the system clipboard
--   <leader>p      paste from the system clipboard
--   <leader>w      write without running autocommands
--   gl             insert a lorem ipsum paragraph
--   ga             (n/x) align around a delimiter (easy-align)
--   <leader>v      toggle venn box-drawing mode (then H/J/K/L draw)
--   <leader>pp/pP  debugprint a plain line below / above
--   <leader>pv/pV  (n/v) debugprint the variable below / above
--   <leader>po/pO  debugprint a text object below / above
--   <leader>rn        generate a doc comment (neogen)
--   <leader>ra/rf/rc  swap parameter / function / class with the next
--   <leader>rA/rF/rC  swap parameter / function / class with the previous
--   Text objects (treesitter): if/af func, ic/ac class, il/al loop,
--     ir/ar return, ii/ai conditional, ia/aa parameter, it/at comment;
--     )f / (f etc. jump to next / previous. nvim-surround (ys/cs/ds) and
--     Comment.nvim (gcc/gc) use their defaults.

vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = true, desc = "Escape to normal mode" })
vim.api.nvim_set_keymap("i", "<c-l>", "<c-g>u<Esc>[s1z=]a<c-g>u", { noremap = true, desc = "Fix last spelling mistake" })
vim.api.nvim_set_keymap("n", "<c-l>", "[s1z=<c-o>", { noremap = true, desc = "Fix last spelling mistake" })
vim.api.nvim_set_keymap("n", "<leader>y", '"+y', { noremap = true, desc = "Yank to system clipboard" })
vim.api.nvim_set_keymap("v", "<leader>y", '"+y', { noremap = true, desc = "Yank to system clipboard" })
vim.api.nvim_set_keymap("n", "<leader>p", '"+p', { noremap = true, desc = "Paste from system clipboard" })
vim.api.nvim_set_keymap("n", "<leader>w", ":noautocmd w<CR>", { noremap = true, desc = "Write (no autocommands)" })

if vim.env.WAYLAND_DISPLAY ~= nil and vim.fn.executable("wl-copy") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard (Wayland)",
    copy = {
      ["+"] = "wl-copy --type text/plain",
      ["*"] = "wl-copy --primary --type text/plain",
    },
    paste = {
      ["+"] = "wl-paste --no-newline",
      ["*"] = "wl-paste --no-newline --primary",
    },
    cache_enabled = 0,
  }
elseif vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = {
    name = "xclip (X11)",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = 0,
  }
elseif os.getenv("TMUX") then
  vim.g.clipboard = {
    name = "tmux",
    copy = {
      ["+"] = "tmux load-buffer -",
      ["*"] = "tmux load-buffer -",
    },
    paste = {
      ["+"] = "tmux save-buffer -",
      ["*"] = "tmux save-buffer -",
    },
    cache_enabled = true,
  }
end

return {
  {
    "vim-scripts/loremipsum",
    config = function()
      vim.keymap.set("n", "gl", function()
        vim.cmd("Loremipsum")
      end, { desc = "Insert lorem ipsum" })
    end,
  },
  {
    "junegunn/vim-easy-align",
    config = function()
      vim.api.nvim_set_keymap("x", "ga", "<Plug>(EasyAlign)", { desc = "Align around a delimiter" })
      vim.api.nvim_set_keymap("n", "ga", "<Plug>(EasyAlign)", { desc = "Align around a delimiter" })
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  "numToStr/Comment.nvim",
  {
    "andrewferrier/debugprint.nvim",
    dependencies = { "echasnovski/mini.nvim" },
    opts = {
      keymaps = {
        normal = {
          plain_below = "<leader>pp",
          plain_above = "<leader>pP",
          variable_below = "<leader>pv",
          variable_above = "<leader>pV",
          textobj_below = "<leader>po",
          textobj_above = "<leader>pO",
        },
        visual = {
          variable_below = "<leader>pv",
          variable_above = "<leader>pV",
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["it"] = "@comment.inner",
              ["if"] = "@function.inner",
              ["ic"] = "@class.inner",
              ["il"] = "@loop.inner",
              ["ir"] = "@return.inner",
              ["ii"] = "@conditional.inner",
              ["ia"] = "@parameter.inner",
              ["at"] = "@comment.outer",
              ["af"] = "@function.outer",
              ["ac"] = "@class.outer",
              ["al"] = "@loop.outer",
              ["ar"] = "@return.outer",
              ["ai"] = "@conditional.outer",
              ["aa"] = "@parameter.outer",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [")t"] = "@comment.outer",
              [")f"] = "@function.outer",
              [")c"] = "@class.outer",
              [")l"] = "@loop.outer",
              [")r"] = "@return.inner",
              [")i"] = "@conditional.outer",
              [")a"] = "@parameter.outer",
            },
            goto_next_end = {
              [")T"] = "@comment.outer",
              [")F"] = "@function.outer",
              [")C"] = "@class.outer",
              [")L"] = "@loop.outer",
              [")R"] = "@return.inner",
              [")I"] = "@conditional.outer",
              [")A"] = "@parameter.outer",
            },
            goto_previous_start = {
              ["(t"] = "@comment.outer",
              ["(f"] = "@function.outer",
              ["(c"] = "@class.outer",
              ["(l"] = "@loop.outer",
              ["(r"] = "@return.inner",
              ["(i"] = "@conditional.outer",
              ["(a"] = "@parameter.outer",
            },
            goto_previous_end = {
              ["(T"] = "@comment.outer",
              ["(F"] = "@function.outer",
              ["(C"] = "@class.outer",
              ["(L"] = "@loop.outer",
              ["(R"] = "@return.inner",
              ["(I"] = "@conditional.outer",
              ["(A"] = "@parameter.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>ra"] = "@parameter.inner",
              ["<leader>rf"] = "@function.outer",
              ["<leader>rc"] = "@class.outer",
            },
            swap_previous = {
              ["<leader>rA"] = "@parameter.inner",
              ["<leader>rF"] = "@function.outer",
              ["<leader>rC"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require("neoclip").setup()
    end,
  },
  "christoomey/vim-tmux-navigator",
  {
    "danymat/neogen",
    config = function()
      local neogen = require("neogen")
      neogen.setup()
      vim.keymap.set("n", "<leader>rn", neogen.generate, { desc = "Generate doc comment (neogen)" })
    end,
  },
  {
    "ovk/endec.nvim",
    event = "VeryLazy",
    opts = {
      -- Override default configuration here
    }
  },
  "mg979/vim-visual-multi",
  {
    "jbyuki/venn.nvim",
    config = function()
      function _G.Toggle_venn()
        local venn_enabled = vim.inspect(vim.b.venn_enabled)
        if venn_enabled == "nil" then
          vim.b.venn_enabled = true
          vim.cmd([[setlocal ve=all]])
          vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "v", "m", "jlokh", { noremap = true })
        else
          vim.cmd([[setlocal ve=]])
          vim.api.nvim_buf_del_keymap(0, "n", "J")
          vim.api.nvim_buf_del_keymap(0, "n", "K")
          vim.api.nvim_buf_del_keymap(0, "n", "L")
          vim.api.nvim_buf_del_keymap(0, "n", "H")
          vim.api.nvim_buf_del_keymap(0, "v", "f")
          vim.api.nvim_buf_del_keymap(0, "v", "m")
          vim.b.venn_enabled = nil
        end
      end

      vim.api.nvim_set_keymap("n", "<leader>v", ":lua Toggle_venn()<CR>", { noremap = true, desc = "Toggle venn box-drawing mode" })
    end,
  },
  {
    "vinnymeller/swagger-preview.nvim",
    cmd = { "SwaggerPreview", "SwaggerPreviewStop", "SwaggerPreviewToggle" },
    build = "npm i",
    config = true,
  },
}
