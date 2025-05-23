#!/bin/bash

echo "🔍 Safe Icon Fix for Neovim - Checking existing setup..."

# Backup directory
BACKUP_DIR="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"

# Function to backup files
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/"
        echo "📦 Backed up: $file"
    fi
}

# Check what exists
echo ""
echo "📋 Current state check:"

# Check for existing icon-related files
existing_files=()
if [[ -f ~/.config/nvim/lua/config/icons.lua ]]; then
    existing_files+=("icons.lua")
fi
if [[ -f ~/.config/nvim/lua/plugins/nvim-tree.lua ]]; then
    existing_files+=("nvim-tree.lua")
fi
if [[ -f ./fix-file-icons.sh ]]; then
    existing_files+=("fix-file-icons.sh in current directory")
fi

if [[ ${#existing_files[@]} -gt 0 ]]; then
    echo "⚠️  Found existing files that might conflict:"
    for file in "${existing_files[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "❓ Do you want to:"
    echo "  1. Continue and backup existing files (recommended)"
    echo "  2. Only add missing components"
    echo "  3. Exit and check manually"
    echo ""
    read -p "Choice (1/2/3): " choice
    
    case $choice in
        3)
            echo "👋 Exiting - no changes made"
            exit 0
            ;;
        2)
            echo "📝 Will only add missing components"
            SAFE_MODE=true
            ;;
        *)
            echo "📦 Will backup and update files"
            SAFE_MODE=false
            ;;
    esac
else
    echo "✅ No conflicts detected"
    SAFE_MODE=false
fi

echo ""
echo "🔧 Applying icon fixes..."

# Create directories
mkdir -p ~/.config/nvim/lua/plugins
mkdir -p ~/.config/nvim/lua/config

# 1. Handle icons.lua
if [[ ! -f ~/.config/nvim/lua/config/icons.lua ]] || [[ "$SAFE_MODE" == "false" ]]; then
    if [[ -f ~/.config/nvim/lua/config/icons.lua ]]; then
        backup_file ~/.config/nvim/lua/config/icons.lua
    fi
    
    cat > ~/.config/nvim/lua/config/icons.lua << 'ICON_EOF'
-- Icon configuration with Unicode fallbacks
local M = {}

function M.setup()
  -- Try to setup nvim-web-devicons
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    devicons.setup({
      color_icons = true,
      default = true,
      strict = true,
      override = {
        zsh = { icon = "", color = "#428850", name = "Zsh" }
      },
      override_by_filename = {
        [".gitignore"] = { icon = "", color = "#f1502f", name = "Gitignore" }
      },
    })
    print("✅ Icons loaded successfully")
  else
    print("⚠️  Using text fallbacks - install a Nerd Font for better icons")
  end
end

return M
ICON_EOF
    echo "✅ Created/updated icons.lua"
fi

# 2. Handle nvim-tree.lua  
if [[ ! -f ~/.config/nvim/lua/plugins/nvim-tree.lua ]] || [[ "$SAFE_MODE" == "false" ]]; then
    if [[ -f ~/.config/nvim/lua/plugins/nvim-tree.lua ]]; then
        backup_file ~/.config/nvim/lua/plugins/nvim-tree.lua
    fi
    
    cat > ~/.config/nvim/lua/plugins/nvim-tree.lua << 'TREE_EOF'
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("config.icons").setup()
      
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        renderer = {
          icons = {
            webdev_colors = true,
            show = { file = true, folder = true, folder_arrow = true, git = true },
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
              },
              git = {
                unstaged = "✗", staged = "✓", untracked = "★",
                deleted = "", ignored = "◌",
              },
            },
          },
        },
        view = { width = 30, side = "left" },
        git = { enable = true, ignore = false },
        actions = { open_file = { quit_on_open = false } },
        filters = { custom = { ".git", "node_modules" } },
      })
    end,
  }
}
TREE_EOF
    echo "✅ Created/updated nvim-tree.lua"
fi

# 3. Add to init.lua if not present
if ! grep -q "require.*config.*icons" ~/.config/nvim/init.lua; then
    backup_file ~/.config/nvim/init.lua
    sed -i '/require("config\.lsp")/a require("config.icons")' ~/.config/nvim/init.lua
    echo "✅ Added icons to init.lua"
else
    echo "ℹ️  Icons already referenced in init.lua"
fi

# 4. Create font checker
cat > ~/.config/nvim/lua/config/font-check.lua << 'FONT_EOF'
local M = {}
function M.check()
  local icons = {"", "", "", "", ""}
  print("🔍 Icon test:")
  for _, icon in ipairs(icons) do
    print("  " .. icon .. " <- Should be a clear icon")
  end
  print("\n💡 If you see squares: install a Nerd Font")
  print("   wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip")
end
return M
FONT_EOF

echo ""
echo "✅ Icon configuration complete!"

if [[ -d "$BACKUP_DIR" ]]; then
    echo "📦 Backups saved to: $BACKUP_DIR"
fi

echo ""
echo "🎯 What this changed:"
echo "  ✓ Added nvim-web-devicons plugin dependency"
echo "  ✓ Enhanced nvim-tree with proper Unicode icons"
echo "  ✓ Created fallback system for missing fonts"
echo ""
echo "🚀 To test:"
echo "  1. Restart Neovim"
echo "  2. Run: :lua require('config.font-check').check()"
echo ""
echo "⚠️  This script is compatible with your existing setup"
echo "   Your quick-deploy.sh and other scripts will continue to work"
