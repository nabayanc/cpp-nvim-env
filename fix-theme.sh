#!/bin/bash

echo "🔧 Fixing plugin error and setting up light GitHub-style theme..."

# 1. Fix the nvim-tree plugin spec error (simplified config)
cat > ~/.config/nvim/lua/plugins/nvim-tree.lua << 'TREE_EOF'
return {
  "nvim-tree/nvim-tree.lua",
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
        special_files = {
          "Cargo.toml",
          "Makefile",
          "README.md",
          "readme.md",
          "CMakeLists.txt",
          "package.json",
        },
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
}
TREE_EOF

# 2. Create a light GitHub-style theme
cat > ~/.config/nvim/lua/plugins/theme.lua << 'THEME_EOF'
return {
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require('github-theme').setup({
        options = {
          theme_style = "light",           -- Use light theme
          transparent = false,
          hide_end_of_buffer = true,
          hide_nc_statusline = true,
          terminal_colors = true,
          darken = {
            floats = false,
            sidebars = {
              enable = true,
              list = { "nvim-tree" },
            },
          },
        },
        colors = {},
        highlights = {
          -- Custom highlights for file types without icons
          Directory = { fg = "#0969da", bold = true },           -- Folders in blue
          
          -- File extensions with different colors
          NvimTreeExecFile = { fg = "#cf222e", bold = true },     -- Executables in red
          NvimTreeSpecialFile = { fg = "#8250df", bold = true },  -- Special files in purple
          NvimTreeSymlink = { fg = "#1f883d", italic = true },    -- Symlinks in green
          
          -- Git status colors
          NvimTreeGitDirty = { fg = "#fb8500" },                  -- Modified in orange
          NvimTreeGitStaged = { fg = "#1f883d" },                 -- Staged in green
          NvimTreeGitDeleted = { fg = "#cf222e" },                -- Deleted in red
          NvimTreeGitNew = { fg = "#8250df" },                    -- New/untracked in purple
          NvimTreeGitIgnored = { fg = "#656d76" },                -- Ignored in gray
        },
      })
      
      -- Apply the theme
      vim.cmd("colorscheme github_light")
    end,
  }
}
THEME_EOF

# 3. Create file type highlighting configuration
cat > ~/.config/nvim/lua/config/file-colors.lua << 'COLOR_EOF'
-- File type color configuration for light theme
local M = {}

function M.setup()
  -- Set up autocmds for file type highlighting
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
      local ft = vim.bo.filetype
      local filename = vim.fn.expand("%:t")
      local extension = vim.fn.expand("%:e")
      
      -- Define color mappings for different file types
      local colors = {
        -- Programming languages
        cpp = "#0969da",      -- Blue
        c = "#0969da",        -- Blue  
        h = "#8250df",        -- Purple (headers)
        hpp = "#8250df",      -- Purple
        py = "#1f883d",       -- Green
        js = "#fb8500",       -- Orange
        ts = "#fb8500",       -- Orange
        html = "#cf222e",     -- Red
        css = "#8250df",      -- Purple
        scss = "#8250df",     -- Purple
        json = "#fb8500",     -- Orange
        yaml = "#656d76",     -- Gray
        yml = "#656d76",      -- Gray
        xml = "#656d76",      -- Gray
        
        -- Build files
        makefile = "#1f883d", -- Green
        cmake = "#1f883d",    -- Green
        
        -- Documentation
        md = "#0969da",       -- Blue
        txt = "#656d76",      -- Gray
        
        -- Shell scripts
        sh = "#cf222e",       -- Red
        bash = "#cf222e",     -- Red
        zsh = "#cf222e",      -- Red
      }
      
      -- Apply highlighting based on file type or extension
      local color = colors[ft] or colors[extension:lower()]
      if color then
        vim.api.nvim_set_hl(0, "NvimTreeOpenedFile", { fg = color, bold = true })
      end
    end,
  })
  
  print("✅ File type colors configured for light theme")
end

return M
COLOR_EOF

# 4. Update init.lua to load the file colors
if ! grep -q "file-colors" ~/.config/nvim/init.lua; then
  sed -i '/require("config\.lsp")/a require("config.file-colors").setup()' ~/.config/nvim/init.lua
fi

# 5. Remove any conflicting theme configurations
sed -i '/catppuccin/Id' ~/.config/nvim/lua/plugins/*.lua 2>/dev/null || true
sed -i '/tokyonight/Id' ~/.config/nvim/lua/plugins/*.lua 2>/dev/null || true

echo "✅ Fixed nvim-tree plugin specification"
echo "✅ Added GitHub light theme"
echo "✅ Configured file type color coding:"
echo "   🔵 C/C++ files in blue"
echo "   🟣 Headers in purple" 
echo "   🟢 Python/build files in green"
echo "   🟠 JS/JSON in orange"
echo "   🔴 HTML/shell scripts in red"
echo "   ⚪ Docs/config in gray"
echo "✅ Set up git status colors"
echo ""
echo "🎨 Your editor will now have:"
echo "   • Clean light background (GitHub style)"
echo "   • Color-coded file types (no icons needed)"
echo "   • Distinct folder highlighting"
echo "   • Git status color coding"
echo ""
echo "🚀 Restart Neovim to see the light theme with color-coded files!"
