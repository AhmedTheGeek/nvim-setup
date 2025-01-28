vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set clipboard=unnamedplus")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.g.mapleader = " "

-- Move to previous/next buffer
vim.keymap.set("n", "<A-,>", "<Cmd>BufferPrevious<CR>", { silent = true })
vim.keymap.set("n", "<A-.>", "<Cmd>BufferNext<CR>", { silent = true })

-- Re-order to previous/next
vim.keymap.set("n", "<A-<>", "<Cmd>BufferMovePrevious<CR>", { silent = true })
vim.keymap.set("n", "<A->>", "<Cmd>BufferMoveNext<CR>", { silent = true })

-- Go to buffer in position...
vim.keymap.set("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", { silent = true })
vim.keymap.set("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", { silent = true })
vim.keymap.set("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", { silent = true })
vim.keymap.set("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", { silent = true })
vim.keymap.set("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", { silent = true })
vim.keymap.set("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", { silent = true })
vim.keymap.set("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", { silent = true })
vim.keymap.set("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", { silent = true })
vim.keymap.set("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", { silent = true })
vim.keymap.set("n", "<A-0>", "<Cmd>BufferLast<CR>", { silent = true })

-- Pin/unpin buffer
vim.keymap.set("n", "<A-p>", "<Cmd>BufferPin<CR>", { silent = true })

-- Close buffer
vim.keymap.set("n", "<A-c>", "<Cmd>BufferClose<CR>", { silent = true })

-- Restore buffer
vim.keymap.set("n", "<A-s-c>", "<Cmd>BufferRestore<CR>", { silent = true })

-- toggle floaterm
vim.keymap.set("n", "A-h", "<cmd>FloatermToggle<cr>")

-- exit terminal mode
vim.api.nvim_set_keymap('t', '<C-q>', '<C-\\><C-n>', { noremap = true, silent = true })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

local opts = {}

-- setup lazy
require("lazy").setup("plugins", opts)
