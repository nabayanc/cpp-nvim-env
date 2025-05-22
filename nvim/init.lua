-- C++ Development Environment for Neovim 0.9.5
-- Compatible configuration without problematic plugins

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load configuration
require("config.options")
require("config.keymaps")
require("config.lsp")

-- Setup plugins
require("lazy").setup("plugins", {
  change_detection = { notify = false },
  checker = { enabled = false },
})

-- Auto-open file explorer on startup (VSCode-like behavior)
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- Open nvim-tree if no file was specified or if opening a directory
    if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.schedule(function()
        require("nvim-tree.api").tree.open()
      end)
    end
  end,
})
