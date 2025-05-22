-- Editor Options Configuration
-- Optimized for C++ development

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General options
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Text display
opt.wrap = false
opt.linebreak = true
opt.showbreak = "↪ "
opt.colorcolumn = "80,120"
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Visual
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 500
opt.lazyredraw = true

-- Backup and undo
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.expand("~/.local/share/nvim/undo")

-- Clipboard (if available)
if vim.fn.has("unnamedplus") == 1 then
    opt.clipboard = "unnamedplus"
end

-- Mouse support
opt.mouse = "a"

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- File handling
opt.fileencoding = "utf-8"
opt.conceallevel = 0
opt.showtabline = 2

-- C++ specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "c", "h", "hpp" },
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

-- Disable some built-in plugins for faster startup
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
