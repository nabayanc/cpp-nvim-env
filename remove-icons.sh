#!/bin/bash

echo "🧹 Removing ALL icons from Neovim configuration..."

# 1. Create a completely icon-free nvim-tree configuration
cat > ~/.config/nvim/lua/plugins/nvim-tree.lua << 'TREE_EOF'
return {
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        renderer = {
          icons = {
            show = {
              file = false,         -- No file icons
              folder = false,       -- No folder icons  
              folder_arrow = true,  -- Keep arrows for expand/collapse
              git = true,          -- Keep git status letters
            },
            glyphs = {
              folder = {
                arrow_closed = ">",
                arrow_open = "v",
              },
              git = {
                unstaged = "M",
                staged = "A", 
                unmerged = "U",
                renamed = "R",
                untracked = "?",
                deleted = "D",
                ignored = "!",
              },
            },
          },
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              bottom = "─",
              none = " ",
            },
          },
        },
        view = { 
          width = 30, 
          side = "left",
        },
        git = { 
          enable = true, 
          ignore = false,
        },
        actions = { 
          open_file = { 
            quit_on_open = false,
          } 
        },
        filters = { 
          custom = { ".git", "node_modules", ".cache" } 
        },
      })
    end,
  }
}
TREE_EOF

# 2. Remove nvim-web-devicons completely and simplify icons.lua
cat > ~/.config/nvim/lua/config/icons.lua << 'ICON_EOF'
-- No icons configuration
local M = {}

function M.setup()
  print("✅ Icon-free configuration loaded")
end

return M
ICON_EOF

# 3. Remove any icon-related lines from init.lua
sed -i '/require.*config.*icons/d' ~/.config/nvim/init.lua

echo "✅ Removed nvim-web-devicons dependency"
echo "✅ Disabled all file and folder icons"
echo "✅ Removed icon configuration from init.lua"
echo "✅ Kept git status letters (M, A, ?, D, etc.)"
echo "✅ Kept folder expand/collapse arrows (>, v)"
echo ""
echo "🎯 Your file manager will now show:"
echo "   > src/"
echo "   v build/"
echo "   │ ├ main.cpp"
echo "   │ └ M modified.cpp"
echo "   └ ? untracked.txt"
echo ""
echo "🚀 Restart Neovim for a clean, icon-free experience!"
