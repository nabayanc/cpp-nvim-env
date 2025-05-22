-- Editor Options Configuration
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- Display
opt.wrap = false
opt.linebreak = true
opt.colorcolumn = "80,120"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 500

-- Backup and undo
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- Clipboard
if vim.fn.has("unnamedplus") == 1 then
    opt.clipboard = "unnamedplus"
end

-- Mouse
opt.mouse = "a"

-- File encoding
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
