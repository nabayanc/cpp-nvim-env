#!/bin/bash

echo "🔧 Fixing Neovim startup errors..."

# 1. Check what's causing the plugin spec error
echo "🔍 Looking for problematic plugin files..."
find ~/.config/nvim/lua/plugins/ -name "*.lua" -exec echo "=== {} ===" \; -exec cat {} \; 2>/dev/null

# 2. Fix the GitHub theme configuration (updated API)
cat > ~/.config/nvim/lua/plugins/theme.lua << 'THEME_EOF'
return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require('github-theme').setup({
        options = {
          compile_path = vim.fn.stdpath('cache') .. '/github-theme',
          compile_file_suffix = '_compiled',
          hide_end_of_buffer = true,
          hide_nc_statusline = true,
          transparent = false,
          terminal_colors = true,
          dim_inactive = false,
          module_default = true,
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
        palettes = {},
        specs = {},
        groups = {
          github_light = {
            -- Directory/folder colors
            Directory = { fg = 'blue.base', style = 'bold' },
            
            -- NvimTree specific
            NvimTreeFolderName = { fg = 'blue.base', style = 'bold' },
            NvimTreeOpenedFolderName = { fg = 'blue.base', style = 'bold' },
            NvimTreeEmptyFolderName = { fg = 'blue.base', style = 'bold' },
            NvimTreeRootFolder = { fg = 'blue.base', style = 'bold' },
            
            -- File types (without icons, just text colors)
            NvimTreeExecFile = { fg = 'red.base', style = 'bold' },
            NvimTreeSpecialFile = { fg = 'purple.base', style = 'bold' },
            NvimTreeSymlink = { fg = 'green.base', style = 'italic' },
            
            -- Git status colors
            NvimTreeGitDirty = { fg = 'orange.base' },
            NvimTreeGitStaged = { fg = 'green.base' },
            NvimTreeGitDeleted = { fg = 'red.base' },
            NvimTreeGitNew = { fg = 'purple.base' },
            NvimTreeGitIgnored = { fg = 'gray.base' },
            NvimTreeGitRenamed = { fg = 'orange.base' },
          },
        },
      })
      
      vim.cmd('colorscheme github_light')
    end,
  }
}
THEME_EOF

# 3. Create a simple, error-free nvim-tree config
cat > ~/.config/nvim/lua/plugins/nvim-tree.lua << 'TREE_EOF'
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {},
    config = function()
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          icons = {
            show = {
              file = false,
              folder = false,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              folder = {
                arrow_closed = "▶",
                arrow_open = "▼",
              },
              git = {
                unstaged = "M",
                staged = "A",
                untracked = "?",
                deleted = "D",
                ignored = "!",
              },
            },
          },
          highlight_git = true,
          highlight_opened_files = "name",
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
        filters = {
          custom = { ".git", "node_modules", ".cache" },
        },
      })
    end,
  },
}
TREE_EOF

# 4. Remove any problematic ui.lua plugin file
rm -f ~/.config/nvim/lua/plugins/ui.lua 2>/dev/null

# 5. Clean up the file colors config to be simpler
cat > ~/.config/nvim/lua/config/file-colors.lua << 'COLOR_EOF'
-- Simple file type highlighting
local M = {}

function M.setup()
  -- Set up highlighting for different file extensions
  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*",
    callback = function()
      local filename = vim.fn.expand("%:t")
      local ext = vim.fn.expand("%:e"):lower()
      
      -- Apply different colors based on file extension
      if ext == "cpp" or ext == "cc" or ext == "cxx" then
        vim.api.nvim_set_hl(0, "Normal", { fg = "#0969da" })
      elseif ext == "h" or ext == "hpp" or ext == "hxx" then
        vim.api.nvim_set_hl(0, "Normal", { fg = "#8250df" })
      elseif ext == "py" then
        vim.api.nvim_set_hl(0, "Normal", { fg = "#1f883d" })
      elseif ext == "js" or ext == "ts" then
        vim.api.nvim_set_hl(0, "Normal", { fg = "#fb8500" })
      elseif ext == "html" or ext == "htm" then
        vim.api.nvim_set_hl(0, "Normal", { fg = "#cf222e" })
      end
    end,
  })
  
  print("✅ File type highlighting configured")
end

return M
COLOR_EOF

# 6. Check and clean init.lua
echo "🧹 Cleaning init.lua..."
# Remove any duplicate or problematic lines
sed -i '/file-colors/d' ~/.config/nvim/init.lua
# Add the file-colors config properly
if ! grep -q "file-colors" ~/.config/nvim/init.lua; then
  sed -i '/require("config\.lsp")/a require("config.file-colors").setup()' ~/.config/nvim/init.lua
fi

echo "✅ Fixed GitHub theme API deprecation warnings"
echo "✅ Simplified nvim-tree configuration"
echo "✅ Removed problematic ui.lua plugin"
echo "✅ Updated file type highlighting"
echo ""
echo "🚀 Restart Neovim - errors should be gone!"
echo "🎨 You'll have a clean light theme with color-coded files"
