-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Modifier key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Color settings
vim.cmd('syntax enable')
vim.opt.termguicolors = true

-- Tab settings
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Column settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "100"
vim.opt.signcolumn = "yes"

-- Search settings
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Save settings
vim.opt.swapfile = false
vim.opt.encoding = "utf-8"
vim.opt.updatetime = 300
vim.opt.backup = false
vim.opt.writebackup = false

-- Error notification
vim.opt.errorbells = false

-- Completion settings
vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }
vim.g.coq_settings = { auto_start = 'shut-up' }

-- Mouse settigs
if vim.fn.has('mouse') == 1 then
  vim.opt.mouse = 'a'
end

-- Set terminal codes for different modes
vim.opt.guicursor = "n-v-c:block,i:ver25,r:hor20"
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 1
vim.opt.ttyfast = true

-- WSL specific settings
if vim.fn.has("unix") == 1 then
  local lines = vim.fn.readfile("/proc/version")
  if lines[1]:match("Microsoft") then
    vim.opt.visualbell = true
    vim.opt.t_u7 = ''
  end
end



-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Dependencies
    'nvim-tree/nvim-web-devicons',

    -- LSP config
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'folke/neodev.nvim',
    'ms-jpq/coq_nvim',
    'ms-jpq/coq.artifacts',
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
      }
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
          vim.keymap.set("n", "gD", vim.lsp.buf.definition)
          vim.keymap.set("n", "K", vim.lsp.buf.hover)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
          vim.keymap.set("n", "gr", vim.lsp.buf.references)
          vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol)
          vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol)
          vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run)
          vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help)
          vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename)
          vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
          vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action)
          vim.keymap.set("n", "<leader>ws", function()
            require("metals").hover_worksheet()
          end)
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
        return metals_config
      end,
      config = function(self, metals_config)
        local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
          pattern = self.ft,
          callback = function()
            require("metals").initialize_or_attach(metals_config)
          end,
          group = nvim_metals_group,
        })
      end
    },
    
    -- DAP config
    'mfussenegger/nvim-dap',
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    },
    {
      "michaelb/sniprun",
      branch = "master",

      build = "sh install.sh",

      config = function()
        require("sniprun").setup({
        })
      end,
    },

    -- Text edition
    {
      'lervag/vimtex',
      lazy = false,
      init = function()
        vim.g.vimtex_view_method = "zathura"
      end
    },
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { "markdown" },
    },
    'vim-scripts/loremipsum',
    
    -- Theme
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
    },
    {
      'nvimdev/dashboard-nvim',
      event = 'VimEnter',
      config = function()
        require('dashboard').setup {
        }
      end,
      dependencies = { {'nvim-tree/nvim-web-devicons'}}
    },

    -- Commands
    'junegunn/vim-easy-align',
    {
      "kylechui/nvim-surround",
      version = "*",
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({})
      end
    },
    'numToStr/Comment.nvim',

    -- File explorer
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
      'nvim-treesitter/nvim-treesitter',
      build = ":TSUpdate",
    },
    'kevinhwang91/rnvimr',

    -- Syntax highlighting (vim settings)
    'udalov/kotlin-vim',
    'memgraph/cypher.vim',
    'ap/vim-css-color',
    'evanleck/vim-svelte',
    'andreshazard/vim-freemarker',

    -- Git integration
    'lewis6991/gitsigns.nvim',
    "sindrets/diffview.nvim",
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        "nvim-telescope/telescope.nvim",
      },
      config = true
    },

    -- Misc
    'preservim/tagbar',
    'christoomey/vim-tmux-navigator',
    'kshenoy/vim-signature',
    
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true },
})

-- General mappings
vim.api.nvim_set_keymap('i', '<C-c>', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('n', '<M-j>', ':m .+1<CR>==', { noremap = true })
vim.api.nvim_set_keymap('n', '<M-k>', ':m .-2<CR>==', { noremap = true })
vim.api.nvim_set_keymap('v', '<M-j>', ':m \'>+1<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('v', '<M-k>', ':m \'<-2<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('i', '<c-l>', '<c-g>u<Esc>[s1z=]a<c-g>u', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-l>', '[s1z=<c-o>', { noremap = true })

-- Dependencies
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'bibtex',
    'c',
    'cpp',
    'dart',
    'html',
    'latex',
    'java',
    'javascript',
    'lua',
    'markdown',
    'markdown_inline',
    'php',
    'python',
    'query',
    'rust',
    'scala',
    'typescript',
    'vim',
    'vimdoc',
  }
})

-- LSP config
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = {
    "ansiblels",
    "bashls",
    "clangd",
    "cssls",
    "dockerls",
    "html",
    "jsonls",
    "tsserver",
    "kotlin_language_server",
    "ltex",
    "lua_ls",
    "markdown_oxide",
    "intelephense",
    "pyright",
    "rust_analyzer",
    "sqlls",
    "terraformls",
    "gitlab_ci_ls",
  },
}

local lsp = require('lspconfig')
local coq = require('coq')
lsp.pyright.setup(coq.lsp_ensure_capabilities {})
lsp.tsserver.setup(coq.lsp_ensure_capabilities {})
lsp.ansiblels.setup(coq.lsp_ensure_capabilities {})
lsp.bashls.setup(coq.lsp_ensure_capabilities {})
lsp.clangd.setup(coq.lsp_ensure_capabilities {})
lsp.cssls.setup(coq.lsp_ensure_capabilities {})
lsp.dockerls.setup(coq.lsp_ensure_capabilities {})
lsp.html.setup(coq.lsp_ensure_capabilities {})
lsp.jsonls.setup(coq.lsp_ensure_capabilities {})
lsp.tsserver.setup(coq.lsp_ensure_capabilities {})
lsp.kotlin_language_server.setup(coq.lsp_ensure_capabilities {})
lsp.ltex.setup(coq.lsp_ensure_capabilities {})
lsp.lua_ls.setup(coq.lsp_ensure_capabilities {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})
lsp.markdown_oxide.setup(coq.lsp_ensure_capabilities {})
lsp.intelephense.setup(coq.lsp_ensure_capabilities {})
lsp.pyright.setup(coq.lsp_ensure_capabilities {})
lsp.rust_analyzer.setup(coq.lsp_ensure_capabilities {})
lsp.sqlls.setup(coq.lsp_ensure_capabilities {})
lsp.terraformls.setup(coq.lsp_ensure_capabilities {})
lsp.gitlab_ci_ls.setup(coq.lsp_ensure_capabilities {})

vim.keymap.set("n", "gD", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol)
vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol)
vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run)
vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action)
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

require('lualine').setup {
  options = { theme = 'palenight' },
}

-- DAP config
vim.api.nvim_set_keymap('n', '<silent> <leader>tn', ':TestNearest<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>ta', ':TestFile<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>ts', ':TestSuite<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>tl', ':TestLast<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>tg', ':TestVisit<CR>', { noremap = true })

require("neotest").setup({
  adapters = {
    require("neotest-python"),
    require("neotest-jest"),
    require("neotest-dart"),
    require("neotest-phpunit"),
    require("neotest-scala"),
    require("neotest-java"),
  },
})
vim.api.nvim_set_keymap('v', '<leader>r', '<Plug>SnipRun', {silent = true})
vim.api.nvim_set_keymap('n', '<leader>r', '<Plug>SnipRunOperator', {silent = true})
vim.api.nvim_set_keymap('n', '<leader>rr', '<Plug>SnipRun', {silent = true})

require("sniprun").setup({
  repl_enable = {"Python3_original"},
})

-- Text edition

-- Theme
vim.cmd('try | colorscheme tokyonight-moon | catch | endtry')
vim.g.airline_powerline_fonts = 1
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g.SignatureMarkTextHLDynamic = 1

-- Commands
vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', {})

-- File explorer
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})
vim.api.nvim_set_keymap('n', '<leader>fs', ':Telescope git_status<CR>', { noremap = true, silent = true })
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      }
    },
    pickers = {
      git_status = {
        theme = "dropdown",
      },
      find_files = {
        hidden = true,
      },
    },
  }
})

vim.g.rnvimr_enable_ex = 1
vim.g.rnvimr_enable_picker = 1
vim.api.nvim_set_keymap('n', '<F2>', ':RnvimrToggle<CR>', { noremap = true, silent = true })

-- Syntax highlighting (vim settings)
-- Git integration
local neogit = require('neogit')
vim.keymap.set('n', '<leader>g', neogit.open, {})
require('gitsigns').setup {}

-- Misc
vim.api.nvim_set_keymap('n', '<F8>', ':TagbarToggle<CR>', { noremap = true })
