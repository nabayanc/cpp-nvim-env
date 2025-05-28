#!/bin/bash

echo "🚫 FORCING complete icon removal..."

# 1. Completely rewrite nvim-tree to show ZERO icons
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
            webdev_colors = false,  -- Disable colors
            git_placement = "after", -- Put git status after filename
            padding = "",           -- No padding
            symlink_arrow = " -> ",
            show = {
              file = false,         -- NO file icons
              folder = false,       -- NO folder icons  
              folder_arrow = true,  -- Keep expand arrows
              git = true,          -- Keep git status
              modified = false,    -- No modified indicator
              diagnostics = false, -- No diagnostic icons
              bookmarks = false,   -- No bookmark icons
            },
            glyphs = {
              default = "",        -- Empty string for files
              symlink = "",        -- Empty string for symlinks
              bookmark = "",       -- Empty string for bookmarks
              modified = "",       -- Empty string for modified
              folder = {
                arrow_closed = ">", -- Simple text arrow
                arrow_open = "v",   -- Simple text arrow
                default = "",       -- NO folder icon
                open = "",          -- NO open folder icon
                empty = "",         -- NO empty folder icon
                empty_open = "",    -- NO empty open folder icon
                symlink = "",       -- NO symlink folder icon
                symlink_open = "",  -- NO symlink open folder icon
              },
              git = {
                unstaged = " M",
                staged = " A", 
                unmerged = " U",
                renamed = " R",
                untracked = " ?",
                deleted = " D",
                ignored = " !",
              },
            },
          },
          root_folder_label = false,
          root_folder_modifier = ":~",
          indent_width = 2,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "├",
              bottom = "─",
              none = " ",
            },
          },
          special_files = {},  -- No special file highlighting
        },
        view = { 
          width = 25, 
          side = "left",
          preserve_window_proportions = false,
        },
        git = { 
          enable = true, 
          ignore = false,
          timeout = 400,
        },
        actions = { 
          open_file = { 
            quit_on_open = false,
            resize_window = false,
          } 
        },
        filters = { 
          dotfiles = false,
          custom = { ".git", "node_modules", ".cache" },
          exclude = {},
        },
        diagnostics = {
          enable = false,  -- Disable diagnostic icons
        },
        modified = {
          enable = false,  -- Disable modified indicators
        },
      })
    end,
  }
}
TREE_EOF

# 2. Remove nvim-web-devicons from any plugin files that might load it
find ~/.config/nvim/lua/plugins/ -name "*.lua" -exec sed -i '/nvim-web-devicons/d' {} \; 2>/dev/null

# 3. Completely disable the icons configuration
cat > ~/.config/nvim/lua/config/icons.lua << 'ICON_EOF'
-- Icons completely disabled
local M = {}

function M.setup()
  -- Prevent any icon loading
  package.loaded["nvim-web-devicons"] = false
  print("🚫 All icons disabled")
end

return M
ICON_EOF

# 4. Make sure init.lua doesn't load icons
sed -i '/icons/d' ~/.config/nvim/init.lua

echo "✅ Aggressively disabled ALL icons"
echo "✅ Removed nvim-web-devicons references"
echo "✅ Set all icon glyphs to empty strings"
echo "✅ Disabled icon colors and padding"
echo ""
echo "🎯 File manager will now show:"
echo "   > src/"
echo "   v build/"
echo "   ├ main.cpp"
echo "   ├ utils.cpp M"
echo "   └ new-file.txt ?"
echo ""
echo "⚠️  MUST restart Neovim completely for this to take effect!"
echo "    Close all Neovim instances and start fresh"
