-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Language Server Protocol
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Completion framework
    'ms-jpq/coq_nvim',
    'ms-jpq/coq.artifacts',

    -- Test
    'vim-test/vim-test',

    -- Writing
    'lervag/vimtex',

    -- Edition
    'junegunn/vim-easy-align',
    'tpope/vim-surround',
    'tpope/vim-commentary',
    'vim-autoformat/vim-autoformat',

    -- File management
    {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
      'nvim-treesitter/nvim-treesitter',
      build = ":TSUpdate",
    },

    'preservim/tagbar',
    'preservim/nerdtree',

    -- Syntax highlighting
    'udalov/kotlin-vim',
    'memgraph/cypher.vim',
    'ap/vim-css-color',
    'evanleck/vim-svelte',
    'andreshazard/vim-freemarker',

    -- Theme
    'ghifarit53/tokyonight-vim',
    'sainnhe/sonokai',
    'vim-airline/vim-airline-themes',

    -- Misc
    'vim-scripts/loremipsum',
    'vim-airline/vim-airline',
    'tpope/vim-fugitive',
    'airblade/vim-gitgutter',
    'christoomey/vim-tmux-navigator',
    'kshenoy/vim-signature',
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

        -- Example of settings
        metals_config.settings = {
          showImplicitArguments = true,
          excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        }

        -- *READ THIS*
        -- I *highly* recommend setting statusBarProvider to either "off" or "on"
        --
        -- "off" will enable LSP progress notifications by Metals and you'll need
        -- to ensure you have a plugin like fidget.nvim installed to handle them.
        --
        -- "on" will enable the custom Metals status extension and you *have* to have
        -- a have settings to capture this in your statusline or else you'll not see
        -- any messages from metals. There is more info in the help docs about this
        metals_config.init_options.statusBarProvider = "off"

        metals_config.on_attach = function(client, bufnr)
          -- LSP mappings
          vim.keymap.set("n", "gD", vim.lsp.buf.definition)
          vim.keymap.set("n", "K", vim.lsp.buf.hover)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
          vim.keymap.set("n", "gr", vim.lsp.buf.references)
          vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol)
          vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol)
          vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run)
          vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
          vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

          vim.keymap.set("n", "<leader>ws", function()
            require("metals").hover_worksheet()
          end)

          -- all workspace diagnostics
          vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist)

          -- all workspace errors
          vim.keymap.set("n", "<leader>ae", function()
            vim.diagnostic.setqflist({ severity = "E" })
          end)

          -- all workspace warnings
          vim.keymap.set("n", "<leader>aw", function()
            vim.diagnostic.setqflist({ severity = "W" })
          end)

          -- buffer diagnostics only
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
    }

  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }
vim.g.coq_settings = { auto_start = 'shut-up' }

-- General settings

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Set basic options
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "100"
vim.opt.errorbells = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.encoding = "utf-8"
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.swapfile = false

-- Check for mouse support and enable it
if vim.fn.has('mouse') == 1 then
    vim.opt.mouse = 'a'
end

-- Set terminal codes for different modes
vim.opt.guicursor = "n-v-c:block,i:ver25,r:hor20,v:ver25"
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 1
vim.opt.ttyfast = true

-- Remap keys
vim.api.nvim_set_keymap('i', '<C-c>', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('n', '<M-j>', ':m .+1<CR>==', { noremap = true })
vim.api.nvim_set_keymap('n', '<M-k>', ':m .-2<CR>==', { noremap = true })
vim.api.nvim_set_keymap('v', '<M-j>', ':m \'>+1<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('v', '<M-k>', ':m \'<-2<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('i', '<c-l>', '<c-g>u<Esc>[s1z=]a<c-g>u', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-l>', '[s1z=<c-o>', { noremap = true })

-- WSL specific settings
if vim.fn.has("unix") == 1 then
    local lines = vim.fn.readfile("/proc/version")
    if lines[1]:match("Microsoft") then
        vim.opt.visualbell = true
        vim.opt.t_u7 = ''
    end
end

-- Enable true color support
vim.opt.termguicolors = true

-- Set colorschemes and theme options
vim.g.sonokai_style = 'atlantis'
vim.g.tokyonight_style = 'storm'
vim.cmd('try | colorscheme tokyonight | catch | endtry')
vim.g.airline_theme = 'tokyonight'

-- Plugin specific settings
vim.g.NERDTreeQuitOnOpen = 1
vim.g.airline_powerline_fonts = 1
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g.SignatureMarkTextHLDynamic = 1

-- Plugin mappings
vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', {})
vim.api.nvim_set_keymap('n', '<F8>', ':TagbarToggle<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F3>', ':Autoformat<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F2>', ':NERDTreeToggle<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ml', '<Plug>MarkdownPreview', {})
vim.api.nvim_set_keymap('n', '<leader>mk', '<Plug>MarkdownPreviewStop', {})
vim.api.nvim_set_keymap('n', '<silent> <leader>tn', ':TestNearest<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>ta', ':TestFile<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>ts', ':TestSuite<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>tl', ':TestLast<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <leader>tg', ':TestVisit<CR>', { noremap = true })

-- LSP and completion setup
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

-- Coq settings

local lsp = require('lspconfig')
local coq = require('coq')

lsp.pyright.setup(coq.lsp_ensure_capabilities{})
lsp.tsserver.setup(coq.lsp_ensure_capabilities{})
lsp.ansiblels.setup(coq.lsp_ensure_capabilities{})
lsp.bashls.setup(coq.lsp_ensure_capabilities{})
lsp.clangd.setup(coq.lsp_ensure_capabilities{})
lsp.cssls.setup(coq.lsp_ensure_capabilities{})
lsp.dockerls.setup(coq.lsp_ensure_capabilities{})
lsp.html.setup(coq.lsp_ensure_capabilities{})
lsp.jsonls.setup(coq.lsp_ensure_capabilities{})
lsp.tsserver.setup(coq.lsp_ensure_capabilities{})
lsp.kotlin_language_server.setup(coq.lsp_ensure_capabilities{})
lsp.ltex.setup(coq.lsp_ensure_capabilities{})
lsp.lua_ls.setup(coq.lsp_ensure_capabilities{
  settings = {
    Lua = {
      diagnostics = {
        globals = {'vim'},
      },
    },
  },
})
lsp.markdown_oxide.setup(coq.lsp_ensure_capabilities{})
lsp.intelephense.setup(coq.lsp_ensure_capabilities{})
lsp.pyright.setup(coq.lsp_ensure_capabilities{})
lsp.rust_analyzer.setup(coq.lsp_ensure_capabilities{})
lsp.sqlls.setup(coq.lsp_ensure_capabilities{})
lsp.terraformls.setup(coq.lsp_ensure_capabilities{})
lsp.gitlab_ci_ls.setup(coq.lsp_ensure_capabilities{})

-- telescopie
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})

local actions = require('telescope.actions')
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      }
    }
  }
})

-- lsp keymaps

vim.keymap.set("n", "gD", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol)
vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol)
vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run)
vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
-- all workspace diagnostics
vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist)
-- all workspace errors
vim.keymap.set("n", "<leader>ae", function()
  vim.diagnostic.setqflist({ severity = "E" })
end)
-- all workspace warnings
vim.keymap.set("n", "<leader>aw", function()
  vim.diagnostic.setqflist({ severity = "W" })
end)
-- buffer diagnostics only
vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist)
vim.keymap.set("n", "[c", function()
  vim.diagnostic.goto_prev({ wrap = false })
end)
vim.keymap.set("n", "]c", function()
  vim.diagnostic.goto_next({ wrap = false })
end)
