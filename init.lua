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
vim.cmd("syntax enable")
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

-- Netrw settings
vim.g.netrw_banner = 0

-- Mouse settigs
if vim.fn.has("mouse") == 1 then
	vim.opt.mouse = "a"
end

-- Set terminal codes for different modes
vim.opt.guicursor = "n-v-c:block,i:ver25,r:hor20"
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 1
vim.opt.ttyfast = true
vim.opt.so = 25

-- WSL specific settings
if vim.fn.has("unix") == 1 then
	local lines = vim.fn.readfile("/proc/version")
	if lines[1]:match("Microsoft") then
		vim.opt.visualbell = true
		vim.opt.t_u7 = ""
	end
end

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Dependencies
		"nvim-tree/nvim-web-devicons",

		-- LSP config
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
				require("mason-lspconfig").setup_handlers({
					function(_)
						require("mason-registry").get_package("php-debug-adapter"):install()
					end,
				})
			end,
		},
		"williamboman/mason-lspconfig.nvim",
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
		"folke/neodev.nvim",
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
			},
			init = function()
				vim.g.db_ui_use_nerd_fonts = 1
			end,
		},
		"https://gitlab.com/schrieveslaach/sonarlint.nvim",
		{
			"danymat/neogen",
			config = true,
		},
		{
			"stevearc/dressing.nvim",
			opts = {},
		},
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
			version = "v2.*",
			build = "make install_jsregexp",
		},
		{ "rafamadriz/friendly-snippets" },
		{
			"folke/trouble.nvim",
			opts = {}, -- for default options, refer to the configuration section for custom setup.
			cmd = "Trouble",
			keys = {
				{
					"<leader>xx",
					"<cmd>Trouble diagnostics toggle win.wo.wrap=true win.position=right win.size.width=40 win.relative=win<cr>",
					desc = "Diagnostics (Trouble)",
				},
				{
					"<leader>xs",
					"<cmd>Trouble symbols toggle focus=false<cr>",
					desc = "Symbols (Trouble)",
				},
				{
					"<leader>xl",
					"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
					desc = "LSP Definitions / references / ... (Trouble)",
				},
				{
					"<leader>xL",
					"<cmd>Trouble loclist toggle<cr>",
					desc = "Location List (Trouble)",
				},
				{
					"<leader>xQ",
					"<cmd>Trouble qflist toggle<cr>",
					desc = "Quickfix List (Trouble)",
				},
			},
		},
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
		},
		{
			"stevearc/conform.nvim",
			opts = {},
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

				-- metals_config.on_attach = function(client, bufnr)
				-- 	local neogen = require("neogen")
				-- 	vim.keymap.set("n", "gD", vim.lsp.buf.definition)
				-- 	vim.keymap.set("n", "K", vim.lsp.buf.hover)
				-- 	vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
				-- 	vim.keymap.set("n", "gr", vim.lsp.buf.references)
				-- 	vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol)
				-- 	vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol)
				-- 	vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run)
				-- 	vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help)
				-- 	vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename)
				-- 	vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
				-- 	vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action)
				-- 	vim.keymap.set("n", "<leader>lg", neogen.generate)
				-- 	vim.keymap.set("n", "<leader>le", require("metals").run_scalafix())
				-- 	vim.keymap.set("n", "<leader>ws", function()
				-- 		require("metals").hover_worksheet()
				-- 	end)
				-- 	vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist)
				-- 	vim.keymap.set("n", "<leader>ae", function()
				-- 		vim.diagnostic.setqflist({ severity = "E" })
				-- 	end)
				-- 	vim.keymap.set("n", "<leader>aw", function()
				-- 		vim.diagnostic.setqflist({ severity = "W" })
				-- 	end)
				-- 	vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist)
				-- 	vim.keymap.set("n", "[c", function()
				-- 		vim.diagnostic.goto_prev({ wrap = false })
				-- 	end)
				-- 	vim.keymap.set("n", "]c", function()
				-- 		vim.diagnostic.goto_next({ wrap = false })
				-- 	end)
				-- 	return metals_config
				-- end
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
						require("metals").initialize_or_attach(metals_config)
					end,
					group = nvim_metals_group,
				})
			end,
		},

		-- DAP config
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
						port = "9003",
						pathMapping = {
							["/var/www/html"] = "${workspaceFolder}",
						},
					},
				}
			end,
		},
		{ "theHamsta/nvim-dap-virtual-text", config = true },
		{
			"michaelb/sniprun",
			branch = "master",

			build = "sh install.sh",

			config = function()
				require("sniprun").setup({})
			end,
		},
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

		-- Text edition
		{
			"lervag/vimtex",
			lazy = false,
			init = function()
				vim.g.vimtex_view_method = "zathura"
			end,
		},
		{
			"iamcco/markdown-preview.nvim",
			build = "cd app && yarn install",
			init = function()
				vim.g.mkdp_filetypes = { "markdown" }
			end,
			ft = { "markdown" },
		},
		"vim-scripts/loremipsum",

		-- Theme
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"folke/tokyonight.nvim",
			lazy = false,
			priority = 1000,
			opts = {},
		},
		{
			"nvimdev/dashboard-nvim",
			event = "VimEnter",
			config = function()
				require("dashboard").setup({})
			end,
			dependencies = { { "nvim-tree/nvim-web-devicons" } },
		},

		-- Commands
		"junegunn/vim-easy-align",
		{
			"kylechui/nvim-surround",
			version = "*",
			event = "VeryLazy",
			config = function()
				require("nvim-surround").setup({})
			end,
		},
		"numToStr/Comment.nvim",

		-- File explorer
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-dap.nvim" },
		},
		"olacin/telescope-cc.nvim",
		"nvim-telescope/telescope-symbols.nvim",
		{
			"AckslD/nvim-neoclip.lua",
			dependencies = {
				{ "nvim-telescope/telescope.nvim" },
			},
			config = function()
				require("neoclip").setup()
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
		},
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
		},
		"kevinhwang91/rnvimr",

		-- Syntax highlighting (vim settings)
		"udalov/kotlin-vim",
		"memgraph/cypher.vim",
		"ap/vim-css-color",
		"evanleck/vim-svelte",
		"andreshazard/vim-freemarker",

		-- Git integration
		"lewis6991/gitsigns.nvim",
		"sindrets/diffview.nvim",

		-- Misc
		"preservim/tagbar",
		"christoomey/vim-tmux-navigator",
		"kshenoy/vim-signature",
	},
	install = { colorscheme = { "tokyonight" } },
	checker = { enabled = true, notify = false },
})

-- General mappings
vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-j>", ":m .+1<CR>==", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-k>", ":m .-2<CR>==", { noremap = true })
vim.api.nvim_set_keymap("v", "<M-j>", ":m '>+1<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap("v", "<M-k>", ":m '<-2<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap("i", "<c-l>", "<c-g>u<Esc>[s1z=]a<c-g>u", { noremap = true })
vim.api.nvim_set_keymap("n", "<c-l>", "[s1z=<c-o>", { noremap = true })

-- Dependencies
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"bibtex",
		"c",
		"cmake",
		"cpp",
		"dart",
		"elixir",
		"html",
		"glsl",
		"go",
		"latex",
		"java",
		"javascript",
		"lua",
		"markdown",
		"markdown_inline",
		"php",
		"python",
		"query",
		"rust",
		"scala",
		"typescript",
		"vim",
		"vimdoc",
	},
	highlight = {
		enable = true,
	},
})
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
				["<leader>sa"] = "@parameter.inner",
				["<leader>sf"] = "@function.outer",
				["<leader>sc"] = "@class.outer",
			},
			swap_previous = {
				["<leader>sA"] = "@parameter.inner",
				["<leader>sF"] = "@function.outer",
				["<leader>sC"] = "@class.outer",
			},
		},
	},
})

-- LSP config
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
		"jsonls",
		"kotlin_language_server",
		"ltex",
		"lua_ls",
		"markdown_oxide",
		"pyright",
		"rust_analyzer",
		"sqlls",
		"terraformls",
		"ts_ls",
	},
})

local lsp = require("lspconfig")
lsp.ansiblels.setup({})
lsp.bashls.setup({})
lsp.clangd.setup({})
lsp.cssls.setup({})
lsp.dockerls.setup({})
lsp.elixirls.setup({})
lsp.glsl_analyzer.setup({})
lsp.html.setup({})
lsp.intelephense.setup({})
lsp.jsonls.setup({})
lsp.kotlin_language_server.setup({})
lsp.gopls.setup({})
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
	Lua = {
		diagnostics = {
			globals = { "vim" },
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
lsp.sonarlint.setup({})
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
lsp.sqlls.setup({})
lsp.terraformls.setup({})
lsp.ts_ls.setup({})

local neogen = require("neogen")
vim.keymap.set("n", "gD", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gds", vim.lsp.buf.document_symbol)
vim.keymap.set("n", "gws", vim.lsp.buf.workspace_symbol)
vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run)
vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>lg", neogen.generate)
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

require("lualine").setup({
	options = { theme = "palenight" },
})

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

local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		c = { "clang_format" },
		cl = { "clang_format" },
		glsl = { "clang_format" },
		php = { "pretty-php" },
		rust = { "rustfmt" },
		tex = { "latexindent" },
		markdown = { "markdownlint", "doctoc" },
		javascript = { "prettier", stop_after_first = true },
		typescript = { "prettier", stop_after_first = true },
		typescriptreact = { "prettier", stop_after_first = true },
		javascriptreact = { "prettier", stop_after_first = true },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		conform.format({ async = false, lsp_fallback = true })
	end,
})

-- DAP config
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
vim.api.nvim_set_keymap("v", "<leader>r", "<Plug>SnipRun", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>r", "<Plug>SnipRun", { silent = true })
local neotest = require("neotest")
vim.keymap.set("n", "<leader>tt", neotest.run.run)
vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end)
vim.keymap.set("n", "<leader>td", function()
	require("neotest").run.run({ strategy = "dap" })
end)
vim.keymap.set("n", "<leader>ts", neotest.run.stop)
vim.keymap.set("n", "<leader>to", neotest.summary.toggle)

local dap = require("dap")
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

require("sniprun").setup({
	repl_enable = { "Python3_original" },
})

-- Text edition

-- Theme
vim.cmd("try | colorscheme tokyonight-moon | catch | endtry")
vim.g.airline_powerline_fonts = 1
vim.g["airline#extensions#tabline#enabled"] = 1
vim.g.SignatureMarkTextHLDynamic = 1

-- Commands
vim.api.nvim_set_keymap("x", "ga", "<Plug>(EasyAlign)", {})
vim.api.nvim_set_keymap("n", "ga", "<Plug>(EasyAlign)", {})

-- File explorer
require("telescope").load_extension("dap")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local utils = require("telescope.utils")
local telescope_dap = require("telescope").extensions.dap
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fa", builtin.diagnostics, {})
vim.keymap.set("n", "<leader>fc", builtin.git_commits, {})
vim.keymap.set("n", "<leader>fC", builtin.git_bcommits, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>ft", builtin.treesitter, {})
vim.keymap.set("n", "<leader>f<leader>", builtin.git_status, {})
vim.keymap.set("n", "<leader>fb", builtin.git_branches, {})
vim.keymap.set("n", "<leader>fh", builtin.command_history, {})
vim.keymap.set("n", "<leader>fm", builtin.marks, {})
vim.keymap.set("n", "<leader>fj", builtin.jumplist, {})
vim.keymap.set("n", "<leader>fs", builtin.spell_suggest, {})
vim.keymap.set("n", "<leader>fr", builtin.lsp_references, {})
-- vim.keymap.set("n", "<leader>fy", builtin.registers, {})

vim.keymap.set("n", "<leader>fk", require("telescope").extensions.conventional_commits.conventional_commits, {})
vim.keymap.set("n", "<leader>fq", require("telescope").extensions.macroscope.default, {})
vim.keymap.set("n", "<leader>fy", require("telescope").extensions.neoclip.default, {})
vim.keymap.set("n", "<leader>fe", function()
	builtin.symbols({ sources = { "emoji", "kaomoji", "gitmoji" } })
end, {})
vim.keymap.set("n", "<leader>fm", function()
	builtin.symbols({ sources = { "math", "latex" } })
end, {})
vim.keymap.set("n", "<leader>fo", function()
	builtin.symbols({ sources = { "julia", "nerd" } })
end, {})

vim.keymap.set("n", "<leader>fda", telescope_dap.commands, {})
vim.keymap.set("n", "<leader>fdc", telescope_dap.configurations, {})
vim.keymap.set("n", "<leader>fdb", telescope_dap.list_breakpoints, {})
vim.keymap.set("n", "<leader>fdv", telescope_dap.variables, {})
vim.keymap.set("n", "<leader>fdf", telescope_dap.frames, {})

require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous,
				["<C-j>"] = actions.move_selection_next,
				["<C-e>"] = function(prompt_bufnr)
					actions.git_merge_branch(prompt_bufnr)
					vim.cmd("checktime")
				end,
				["<C-r>"] = function(prompt_bufn)
					actions.git_rebase_branch(prompt_bufn)
					vim.cmd("checktime")
				end,
				["<C-h>"] = function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local current_picker = action_state.get_current_picker(prompt_bufnr)
					if selection == nil then
						utils.__warn_no_selection("git_rollback")
						return
					end
					utils.get_os_command_output({ "git", "checkout", "--", selection.value }, current_picker.cwd)
					current_picker:delete_selection(function()
						local _, ret, _ = utils.get_os_command_output(
							{ "git", "rev-parse", "--verify", "MERGE_HEAD" },
							current_picker.cwd
						)
						return not (ret == 0)
					end)
					vim.cmd("checktime")
				end,
				["<C-l>"] = function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local current_picker = action_state.get_current_picker(prompt_bufnr)
					if selection == nil then
						utils.__warn_no_selection("git_checkout_theirs")
						return
					end
					utils.get_os_command_output({ "git", "checkout", "--theirs", selection.value }, current_picker.cwd)
					vim.cmd("checktime")
				end,
			},
		},
	},
	pickers = {
		git_status = {
			theme = "dropdown",
		},
		find_files = {
			hidden = true,
			file_ignore_patterns = { ".git/" },
		},
	},
})

vim.g.rnvimr_enable_ex = 1
vim.g.rnvimr_enable_picker = 1
vim.api.nvim_set_keymap("n", "<F2>", ":RnvimrToggle<CR>", { noremap = true, silent = true })

-- Syntax highlighting (vim settings)
-- Git integration
require("gitsigns").setup({})

-- Misc
vim.api.nvim_set_keymap("n", "<F8>", ":TagbarToggle<CR>", { noremap = true })

-- Database
vim.g.dbs = require("dbs").dbs
vim.keymap.set("n", "<leader>D", function()
	vim.cmd("DBUIToggle")
end, {})
