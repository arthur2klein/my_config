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

vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("i", "<c-l>", "<c-g>u<Esc>[s1z=]a<c-g>u", { noremap = true })
vim.api.nvim_set_keymap("n", "<c-l>", "[s1z=<c-o>", { noremap = true })

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
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		if vim.lsp.get_client_by_id(args.data.client_id).name ~= "metals" then
			lsp_key_mapping()
		end
	end,
})

-- Setup lazy.nvim
require("lazy").setup({
	specs = {},
	install = { colorscheme = { "catppuccin" } },
	checker = { enabled = true, notify = false },
	import = "plugins",
})
