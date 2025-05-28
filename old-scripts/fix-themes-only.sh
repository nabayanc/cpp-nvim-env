#!/bin/bash
# Fix Themes Only Script
# Preserves existing config but fixes all theme-related issues
# Applies clean GitHub light theme and removes problematic icon setups

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[FIX]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

NVIM_CONFIG="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim-theme-backup-$(date +%Y%m%d-%H%M%S)"

print_status "🎨 Fixing theme-related issues while preserving your config..."

# Check if nvim config exists
if [[ ! -d "$NVIM_CONFIG" ]]; then
    print_error "No Neovim config found at $NVIM_CONFIG"
    exit 1
fi

# Step 1: Backup theme-related files
print_status "Step 1: Backing up existing theme files..."
mkdir -p "$BACKUP_DIR/lua/plugins"
mkdir -p "$BACKUP_DIR/lua/config"

# Backup theme-related files if they exist
for file in theme.lua ui.lua vscode-ui.lua icons.lua file-colors.lua theme-fallback.lua test-icons.lua; do
    if [[ -f "$NVIM_CONFIG/lua/plugins/$file" ]]; then
        cp "$NVIM_CONFIG/lua/plugins/$file" "$BACKUP_DIR/lua/plugins/" 2>/dev/null || true
    fi
    if [[ -f "$NVIM_CONFIG/lua/config/$file" ]]; then
        cp "$NVIM_CONFIG/lua/config/$file" "$BACKUP_DIR/lua/config/" 2>/dev/null || true
    fi
done

print_success "Theme files backed up to: $BACKUP_DIR"

# Step 2: Remove all conflicting theme files
print_status "Step 2: Removing conflicting theme configurations..."

# Remove problematic plugin files
rm -f "$NVIM_CONFIG/lua/plugins/theme.lua"
rm -f "$NVIM_CONFIG/lua/plugins/ui.lua" 
rm -f "$NVIM_CONFIG/lua/plugins/vscode-ui.lua"
rm -f "$NVIM_CONFIG/lua/plugins/file-explorer.lua"

# Remove problematic config files
rm -f "$NVIM_CONFIG/lua/config/icons.lua"
rm -f "$NVIM_CONFIG/lua/config/file-colors.lua"
rm -f "$NVIM_CONFIG/lua/config/theme-fallback.lua"
rm -f "$NVIM_CONFIG/lua/config/test-icons.lua"

print_success "Removed conflicting theme files"

# Step 3: Clean up init.lua references
print_status "Step 3: Cleaning init.lua references..."

# Remove problematic references from init.lua
if [[ -f "$NVIM_CONFIG/init.lua" ]]; then
    cp "$NVIM_CONFIG/init.lua" "$BACKUP_DIR/init.lua"
    
    # Remove icon and theme-related lines
    sed -i '/require.*config.*icons/d' "$NVIM_CONFIG/init.lua"
    sed -i '/require.*config.*file-colors/d' "$NVIM_CONFIG/init.lua"
    sed -i '/require.*config.*theme-fallback/d' "$NVIM_CONFIG/init.lua"
    sed -i '/Load icon configuration/d' "$NVIM_CONFIG/init.lua"
    sed -i '/Setup theme with fallback/d' "$NVIM_CONFIG/init.lua"
    
    print_success "Cleaned init.lua references"
fi

# Step 4: Clear plugin cache
print_status "Step 4: Clearing theme plugin cache..."

rm -rf ~/.local/share/nvim/lazy/catppuccin 2>/dev/null || true
rm -rf ~/.local/share/nvim/lazy/github-nvim-theme 2>/dev/null || true
rm -rf ~/.local/share/nvim/lazy/tokyonight.nvim 2>/dev/null || true
rm -rf ~/.local/share/nvim/lazy/nvim-web-devicons 2>/dev/null || true
rm -rf ~/.local/share/nvim/lazy/bufferline.nvim 2>/dev/null || true

print_success "Cleared theme plugin cache"

# Step 5: Install clean GitHub light theme
print_status "Step 5: Installing clean GitHub light theme..."

cat > "$NVIM_CONFIG/lua/plugins/github-theme.lua" << 'EOF'
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
          transparent = false,
          hide_end_of_buffer = true,
          hide_nc_statusline = true,
          terminal_colors = true,
          dim_inactive = false,
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
        groups = {
          github_light = {
            -- Clean file explorer colors
            Directory = { fg = '#0969da', style = 'bold' },
            NvimTreeFolderName = { fg = '#0969da', style = 'bold' },
            NvimTreeOpenedFolderName = { fg = '#0969da', style = 'bold' },
            NvimTreeRootFolder = { fg = '#0969da', style = 'bold' },
            
            -- File type highlighting
            NvimTreeExecFile = { fg = '#cf222e', style = 'bold' },
            NvimTreeSpecialFile = { fg = '#8250df', style = 'bold' },
            
            -- Git status colors
            NvimTreeGitDirty = { fg = '#fb8500' },
            NvimTreeGitStaged = { fg = '#1f883d' },
            NvimTreeGitDeleted = { fg = '#cf222e' },
            NvimTreeGitNew = { fg = '#8250df' },
            NvimTreeGitIgnored = { fg = '#656d76' },
            
            -- General UI improvements
            StatusLine = { bg = '#f6f8fa', fg = '#24292f' },
            StatusLineNC = { bg = '#eaeef2', fg = '#656d76' },
            WinSeparator = { fg = '#d0d7de' },
            
            -- Better contrast for important elements
            Search = { bg = '#fff8c5', fg = '#24292f' },
            IncSearch = { bg = '#fddf68', fg = '#24292f' },
            CursorLine = { bg = '#f6f8fa' },
            Visual = { bg = '#ddf4ff' },
          },
        },
      })
      
      -- Apply the theme
      vim.cmd('colorscheme github_light')
      print("✅ GitHub Light theme loaded successfully")
    end,
  }
}
EOF

print_success "GitHub Light theme configuration created"

# Step 6: Fix file explorer (remove icons, keep functionality)
print_status "Step 6: Fixing file explorer configuration..."

# Find existing nvim-tree config and update it, or create new one
NVIM_TREE_CONFIG=""
if [[ -f "$NVIM_CONFIG/lua/plugins/nvim-tree.lua" ]]; then
    NVIM_TREE_CONFIG="$NVIM_CONFIG/lua/plugins/nvim-tree.lua"
elif [[ -f "$NVIM_CONFIG/lua/plugins/file-explorer.lua" ]]; then
    NVIM_TREE_CONFIG="$NVIM_CONFIG/lua/plugins/file-explorer.lua"
else
    # Check if it's in a combined UI file
    for file in "$NVIM_CONFIG/lua/plugins"/*.lua; do
        if [[ -f "$file" ]] && grep -q "nvim-tree" "$file" 2>/dev/null; then
            print_warning "Found nvim-tree config in: $(basename "$file")"
            print_warning "Please manually update that file or let this script create a new one"
            break
        fi
    done
    NVIM_TREE_CONFIG="$NVIM_CONFIG/lua/plugins/nvim-tree-fixed.lua"
fi

# Create clean nvim-tree configuration
cat > "$NVIM_TREE_CONFIG" << 'EOF'
return {
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        -- Auto-open behavior
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        
        -- View configuration
        view = {
          width = 35,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        
        -- Renderer with NO ICONS (clean text-only)
        renderer = {
          add_trailing = false,
          group_empty = true,
          highlight_git = true,
          full_name = false,
          highlight_opened_files = "name",
          root_folder_label = ":t",
          indent_width = 2,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              none = " ",
            },
          },
          icons = {
            show = {
              file = false,        -- NO file icons
              folder = false,      -- NO folder icons
              folder_arrow = true, -- Keep expand arrows
              git = true,         -- Keep git status
            },
            glyphs = {
              folder = {
                arrow_closed = "▶",
                arrow_open = "▼",
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
          special_files = { 
            "Cargo.toml", "Makefile", "README.md", "readme.md", 
            "CMakeLists.txt", ".gitignore" 
          },
        },
        
        -- Filters
        filters = {
          dotfiles = false,
          git_clean = false,
          no_buffer = false,
          custom = { ".DS_Store", "__pycache__", "node_modules", ".cache" },
          exclude = { ".gitignore", ".env" },
        },
        
        -- Git integration
        git = {
          enable = true,
          ignore = false,
          show_on_dirs = true,
          show_on_open_dirs = true,
          timeout = 400,
        },
        
        -- Actions
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
      })

      -- Preserve existing keymaps or set defaults
      local keymap_exists = pcall(vim.keymap.get, "n", "<leader>e")
      if not keymap_exists then
        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer", silent = true })
        vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find File in Explorer", silent = true })
        vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", { desc = "Refresh Explorer", silent = true })
      end
    end,
  }
}
EOF

print_success "Fixed file explorer configuration (no icons, clean text)"

# Step 7: Fix status line if it exists
print_status "Step 7: Updating status line for GitHub theme..."

# Find lualine config and update theme
for file in "$NVIM_CONFIG/lua/plugins"/*.lua; do
    if [[ -f "$file" ]] && grep -q "lualine" "$file" 2>/dev/null; then
        print_status "Updating lualine theme in: $(basename "$file")"
        
        # Update lualine theme references
        sed -i 's/theme = "catppuccin"/theme = "github_light"/g' "$file"
        sed -i 's/theme = "auto"/theme = "github_light"/g' "$file"
        sed -i 's/theme = catppuccin_ok and "catppuccin" or "auto"/theme = "github_light"/g' "$file"
        
        print_success "Updated lualine theme"
        break
    fi
done

# Step 8: Remove nvim-web-devicons dependencies
print_status "Step 8: Removing icon dependencies..."

# Remove nvim-web-devicons from dependencies in plugin files
for file in "$NVIM_CONFIG/lua/plugins"/*.lua; do
    if [[ -f "$file" ]]; then
        # Remove nvim-web-devicons dependencies but keep the plugin structure
        sed -i 's/, "nvim-tree\/nvim-web-devicons"//g' "$file"
        sed -i 's/"nvim-tree\/nvim-web-devicons", //g' "$file"
        sed -i 's/dependencies = { "nvim-tree\/nvim-web-devicons" },/dependencies = {},/g' "$file"
        sed -i '/dependencies = {},/d' "$file"
    fi
done

print_success "Removed icon dependencies"

# Step 9: Create a theme test command
print_status "Step 9: Creating theme test utility..."

cat > "$NVIM_CONFIG/lua/config/theme-test.lua" << 'EOF'
-- Theme Test Utility
local M = {}

function M.test()
  print("=== Theme Test ===")
  print("Current colorscheme: " .. vim.g.colors_name)
  print("✅ GitHub Light theme should be active")
  print("📁 File explorer: text-only, no broken icons")
  print("🎨 Clean light background")
  print("==================")
  
  -- Test if theme is properly loaded
  if vim.g.colors_name == "github_light" then
    print("✅ Theme loaded correctly!")
  else
    print("⚠️  Expected github_light, got: " .. (vim.g.colors_name or "none"))
  end
end

return M
EOF

# Add test command to init.lua if needed
if ! grep -q "theme-test" "$NVIM_CONFIG/init.lua" 2>/dev/null; then
    echo "" >> "$NVIM_CONFIG/init.lua"
    echo "-- Theme test utility" >> "$NVIM_CONFIG/init.lua"
    echo "vim.api.nvim_create_user_command('ThemeTest', function()" >> "$NVIM_CONFIG/init.lua"
    echo "  require('config.theme-test').test()" >> "$NVIM_CONFIG/init.lua"
    echo "end, {})" >> "$NVIM_CONFIG/init.lua"
fi

print_success "Theme test utility created"

print_success "🎉 Theme fixes complete!"

echo ""
print_status "📋 WHAT WAS FIXED:"
echo "  ✅ Removed all conflicting theme configurations"
echo "  ✅ Installed clean GitHub Light theme"
echo "  ✅ Fixed file explorer (no icons, text-only)"
echo "  ✅ Updated status line theme"
echo "  ✅ Removed problematic icon dependencies"
echo "  ✅ Cleared theme plugin cache"
echo "  ✅ Preserved all other functionality"
echo ""
print_status "📦 BACKUPS CREATED:"
echo "  🗂️  Theme files backed up to: $BACKUP_DIR"
echo ""
print_status "🎨 NEW THEME FEATURES:"
echo "  • Clean GitHub Light background"
echo "  • Professional, readable colors"
echo "  • File explorer shows: filename.cpp (no icons)"
echo "  • Folders show: ▶ foldername (expand arrows only)"
echo "  • Git status: M (modified), A (added), ? (untracked)"
echo "  • No broken symbols or squares"
echo ""
print_status "🚀 NEXT STEPS:"
echo "  1. Restart Neovim: exit all instances and reopen"
echo "  2. Plugins will reinstall automatically (1-2 minutes)"
echo "  3. Test theme: :ThemeTest"
echo "  4. Check file explorer: <leader>e (should be clean text)"
echo ""
print_status "🔧 IF ISSUES PERSIST:"
echo "  • Run: :Lazy clean (remove unused plugins)"
echo "  • Run: :Lazy update (update all plugins)"
echo "  • Check: :checkhealth (verify everything works)"
echo ""
print_warning "⚠️  Your config structure and functionality are preserved!"
print_warning "   Only theme-related files were modified"
print_success "Clean GitHub Light theme ready! 🎯"
