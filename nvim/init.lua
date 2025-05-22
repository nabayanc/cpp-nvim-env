-- Portable C++ Development Environment
-- Neovim Configuration

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Setup lazy.nvim plugin manager
require("lazy").setup("plugins", {
  change_detection = { notify = false },
  checker = { enabled = false },  -- Don't auto-check for updates on remote nodes
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Auto-install missing parsers for treesitter
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.cpp", "*.c", "*.h", "*.hpp" },
  callback = function()
    local ts_parsers = require("nvim-treesitter.parsers")
    if not ts_parsers.has_parser("cpp") then
      vim.cmd("TSInstall cpp")
    end
  end,
})
