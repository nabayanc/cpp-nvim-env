#!/bin/bash

echo "🔧 Applying simple light theme fix..."

# 1. Remove the problematic GitHub theme and use a built-in light scheme
cat > ~/.config/nvim/lua/plugins/theme.lua << 'THEME_EOF'
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "day",  -- Use the light "day" variant
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { bold = true },
          functions = {},
          variables = {},
        },
        sidebars = { "nvim-tree" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,
      })
      vim.cmd([[colorscheme tokyonight-day]])
    end,
  }
}
THEME_EOF

# 2. Create the simplest possible nvim-tree config
cat > ~/.config/nvim/lua/plugins/nvim-tree.lua << 'TREE_EOF'
return {
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup({
      view = { width = 30 },
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
            },
          },
        },
      },
      git = { enable = true },
      filters = { custom = { ".git" } },
    })
  end,
}
TREE_EOF

# 3. Remove the problematic file-colors config that's causing issues
rm -f ~/.config/nvim/lua/config/file-colors.lua

# 4. Clean init.lua of any file-colors references
sed -i '/file-colors/d' ~/.config/nvim/init.lua

# 5. Create a simple manual colorscheme for file types in nvim-tree
cat > ~/.config/nvim/lua/config/simple-colors.lua << 'COLOR_EOF'
-- Simple file type colors for nvim-tree
local M = {}

function M.setup()
  -- Set up simple highlighting for nvim-tree file types
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
      -- Define simple colors for different patterns
      vim.api.nvim_set_hl(0, "NvimTreeCppFile", { fg = "#005CC5" })     -- Blue for C++
      vim.api.nvim_set_hl(0, "NvimTreeHeaderFile", { fg = "#6F42C1" })  -- Purple for headers
      vim.api.nvim_set_hl(0, "NvimTreePythonFile", { fg = "#28A745" })  -- Green for Python
      vim.api.nvim_set_hl(0, "NvimTreeJSFile", { fg = "#F9826C" })      -- Orange for JS
      vim.api.nvim_set_hl(0, "NvimTreeShellFile", { fg = "#D73A49" })   -- Red for shell
      vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = "#005CC5", bold = true }) -- Blue folders
      
      -- Apply syntax highlighting to file names based on extension
      vim.cmd([[
        syntax match NvimTreeCppFile /\v\.(cpp|cc|cxx)$/
        syntax match NvimTreeHeaderFile /\v\.(h|hpp|hxx)$/
        syntax match NvimTreePythonFile /\v\.py$/
        syntax match NvimTreeJSFile /\v\.(js|ts)$/
        syntax match NvimTreeShellFile /\v\.(sh|bash|zsh)$/
      ]])
    end,
  })
  
  print("✅ Simple file type colors applied")
end

return M
COLOR_EOF

# 6. Add the simple colors to init.lua
if ! grep -q "simple-colors" ~/.config/nvim/init.lua; then
  sed -i '/require("config\.lsp")/a require("config.simple-colors").setup()' ~/.config/nvim/init.lua
fi

# 7. Remove any other theme plugin files that might conflict
find ~/.config/nvim/lua/plugins/ -name "*github*" -delete 2>/dev/null || true

echo "✅ Replaced GitHub theme with TokyoNight Day (light theme)"
echo "✅ Simplified nvim-tree configuration"
echo "✅ Removed complex color configuration"
echo "✅ Added simple file type colors"
echo ""
echo "🎨 You'll now have:"
echo "   • Clean light background (TokyoNight Day)"
echo "   • Simple file type colors:"
echo "     - Blue: C++ files and folders"
echo "     - Purple: Header files (.h, .hpp)"
echo "     - Green: Python files"
echo "     - Orange: JavaScript files"
echo "     - Red: Shell scripts"
echo ""
echo "🚀 Restart Neovim - all errors should be gone!"
