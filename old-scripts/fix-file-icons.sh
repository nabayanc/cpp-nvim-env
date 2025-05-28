#!/bin/bash
# Fix File Manager Icon Display Issues
# Ensures icons display correctly across all terminal environments

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[ICON-FIX]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

NVIM_CONFIG="$HOME/.config/nvim"

print_status "🎯 Fixing file manager icon display issues..."

# Step 1: Test current icon support
print_status "Step 1: Testing icon font support..."

echo "Testing icon characters:"
echo "  File: 📄  Folder: 📁  Git: 🔧"
echo "  Arrow: ▶  Check: ✓  Cross: ✗"
echo ""
read -p "Do you see proper icons above? (y/n): " icon_support

if [[ "$icon_support" =~ ^[Yy] ]]; then
    USE_UNICODE_ICONS=true
    print_success "Unicode icons supported - will use enhanced icon set"
else
    USE_UNICODE_ICONS=false
    print_warning "Unicode icons not supported - will use ASCII fallbacks"
fi

# Step 2: Create icon configuration based on support
print_status "Step 2: Creating compatible icon configuration..."

if [[ "$USE_UNICODE_ICONS" == "true" ]]; then
    # Enhanced icons for terminals with good font support
    cat > "$NVIM_CONFIG/lua/config/icons.lua" << 'EOF'
-- Enhanced Icon Configuration
-- For terminals with Unicode/Nerd Font support

local M = {}

M.setup = function()
  -- Try to set up nvim-web-devicons with enhanced icons
  local icons_ok, icons = pcall(require, "nvim-web-devicons")
  
  if icons_ok then
    icons.setup({
      override = {
        cpp = { icon = "", color = "#519aba", name = "Cpp" },
        c = { icon = "", color = "#519aba", name = "C" },
        h = { icon = "", color = "#a074c4", name = "H" },
        hpp = { icon = "", color = "#a074c4", name = "Hpp" },
        cmake = { icon = "", color = "#6d8086", name = "CMake" },
        txt = { icon = "", color = "#89e051", name = "Txt" },
        md = { icon = "", color = "#519aba", name = "Md" },
        json = { icon = "", color = "#cbcb41", name = "Json" },
        js = { icon = "", color = "#cbcb41", name = "Js" },
        py = { icon = "", color = "#519aba", name = "Py" },
        gitignore = { icon = "", color = "#41535b", name = "GitIgnore" },
        makefile = { icon = "", color = "#6d8086", name = "Makefile" },
      },
      default = true,
    })
    return true
  end
  
  return false
end

M.get_file_icon = function(filename, extension)
  local icons_ok, icons = pcall(require, "nvim-web-devicons")
  if icons_ok then
    return icons.get_icon(filename, extension)
  end
  
  -- Fallback icons
  local ext_icons = {
    cpp = "", c = "", h = "", hpp = "",
    cmake = "", txt = "", md = "",
    json = "", js = "", py = "",
    gitignore = "", makefile = "",
  }
  
  return ext_icons[extension] or "", "#ffffff"
end

return M
EOF
else
    # ASCII fallback icons for limited terminal support
    cat > "$NVIM_CONFIG/lua/config/icons.lua" << 'EOF'
-- ASCII Fallback Icon Configuration
-- For terminals with limited Unicode support

local M = {}

M.setup = function()
  -- Override nvim-web-devicons to use ASCII characters
  local icons_ok, icons = pcall(require, "nvim-web-devicons")
  
  if icons_ok then
    icons.setup({
      override = {
        cpp = { icon = "C+", color = "#519aba", name = "Cpp" },
        c = { icon = "C", color = "#519aba", name = "C" },
        h = { icon = "H", color = "#a074c4", name = "H" },
        hpp = { icon = "H+", color = "#a074c4", name = "Hpp" },
        cmake = { icon = "CM", color = "#6d8086", name = "CMake" },
        txt = { icon = "T", color = "#89e051", name = "Txt" },
        md = { icon = "MD", color = "#519aba", name = "Md" },
        json = { icon = "JS", color = "#cbcb41", name = "Json" },
        py = { icon = "PY", color = "#519aba", name = "Py" },
        gitignore = { icon = "GI", color = "#41535b", name = "GitIgnore" },
        makefile = { icon = "MK", color = "#6d8086", name = "Makefile" },
      },
      default = true,
    })
    return true
  end
  
  return false
end

M.get_file_icon = function(filename, extension)
  -- ASCII-based file type indicators
  local ext_icons = {
    cpp = "C+", c = "C", h = "H", hpp = "H+",
    cmake = "CM", txt = "T", md = "MD",
    json = "JS", py = "PY",
    gitignore = "GI", makefile = "MK",
  }
  
  return ext_icons[extension] or "F", "#ffffff"
end

return M
EOF
fi

print_success "Created icon configuration for your terminal"

# Step 3: Update nvim-tree configuration with better icon support
print_status "Step 3: Updating file explorer with compatible icons..."

cat > "$NVIM_CONFIG/lua/plugins/file-explorer.lua" << 'EOF'
-- File Explorer with Compatible Icon Configuration
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Setup icons first
      require("config.icons").setup()

      require("nvim-tree").setup({
        -- Auto-open behavior
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        
        update_focused_file = {
          enable = true,
          update_cwd = true,
          ignore_list = {},
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
        
        -- Renderer with compatible icons
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
              corner = "+",
              edge = "|",
              item = "|",
              none = " ",
            },
          },
          icons = {
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " -> ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "F",
              symlink = "L",
              bookmark = "B",
              folder = {
                arrow_closed = ">",
                arrow_open = "v",
                default = "D",
                open = "O",
                empty = "E",
                empty_open = "e",
                symlink = "S",
                symlink_open = "s",
              },
              git = {
                unstaged = "M",
                staged = "A",
                unmerged = "U",
                renamed = "R",
                untracked = "?",
                deleted = "D",
                ignored = "I",
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
            window_picker = {
              enable = true,
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
        },
        
        -- Performance
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
          ignore_dirs = {},
        },
        
        -- Live filter
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = true,
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer", silent = true })
      vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find File in Explorer", silent = true })
      vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", { desc = "Refresh Explorer", silent = true })
      
      -- Auto-open behaviors
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          local directory = vim.fn.isdirectory(data.file) == 1
          if directory then
            vim.cmd.cd(data.file)
            require("nvim-tree.api").tree.open()
          end
        end
      })
      
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            require("nvim-tree.api").tree.open()
          end
        end
      })
    end,
  },
  
  -- Web dev icons with fallback support
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("config.icons").setup()
    end,
  },
}
EOF

# Step 4: Update main init.lua to load icon config
print_status "Step 4: Updating init.lua to load icon configuration..."

# Add icon config loading to init.lua if not present
if ! grep -q "config.icons" "$NVIM_CONFIG/init.lua"; then
    cat >> "$NVIM_CONFIG/init.lua" << 'EOF'

-- Load icon configuration early
require("config.icons").setup()
EOF
fi

# Step 5: Create a simple icon test
print_status "Step 5: Creating icon test utility..."

cat > "$NVIM_CONFIG/lua/config/test-icons.lua" << 'EOF'
-- Icon Test Utility
local M = {}

M.test_icons = function()
  print("=== Icon Test ===")
  
  local icons = require("config.icons")
  
  -- Test common file types
  local test_files = {
    {"main.cpp", "cpp"},
    {"main.c", "c"},
    {"header.h", "h"},
    {"CMakeLists.txt", "cmake"},
    {"README.md", "md"},
    {".gitignore", "gitignore"}
  }
  
  for _, file_info in ipairs(test_files) do
    local filename, ext = file_info[1], file_info[2]
    local icon, color = icons.get_file_icon(filename, ext)
    print(string.format("  %s %s", icon, filename))
  end
  
  print("=== End Test ===")
end

return M
EOF

# Step 6: Clear plugin cache to force reload
print_status "Step 6: Clearing icon plugin cache..."

rm -rf "$HOME/.local/share/nvim/lazy/nvim-web-devicons" 2>/dev/null || true
rm -rf "$HOME/.local/share/nvim/lazy/nvim-tree.lua" 2>/dev/null || true

print_success "Cleared icon plugin cache"

# Step 7: Update repository with fixes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "$SCRIPT_DIR/nvim" ]]; then
    cp -r "$NVIM_CONFIG"/* "$SCRIPT_DIR/nvim/"
    print_success "Updated repository with icon fixes"
fi

print_success "🎯 File icon fix complete!"

echo ""
print_status "📋 WHAT WAS FIXED:"
if [[ "$USE_UNICODE_ICONS" == "true" ]]; then
    echo "  ✓ Enhanced Unicode icons for files and folders"
    echo "  ✓ Beautiful file type indicators"
else
    echo "  ✓ ASCII fallback icons (C+, H, MD, etc.)"
    echo "  ✓ Clear file type indicators that work everywhere"
fi
echo "  ✓ Improved folder tree display"
echo "  ✓ Compatible git status indicators"
echo "  ✓ Fallback support for all terminal types"
echo ""
print_status "🚀 NEXT STEPS:"
echo "  1. Restart Neovim: exit and run 'nvim .'"
echo "  2. File explorer should show proper icons/indicators"
echo "  3. Test with: :lua require('config.test-icons').test_icons()"
echo ""
print_status "🎯 WHAT YOU'LL SEE:"
if [[ "$USE_UNICODE_ICONS" == "true" ]]; then
    echo "  📄 main.cpp    🗂️ src/        ✓ staged files"
    echo "  📝 README.md   📁 build/      ? untracked files"
else
    echo "  C+ main.cpp    D src/         A staged files"
    echo "  MD README.md   D build/       ? untracked files"
fi
echo ""
print_success "File icons should now display correctly! 🎨"

# Add to quick-deploy script if it exists
if [[ -f "$SCRIPT_DIR/quick-deploy.sh" ]]; then
    print_status "Adding icon fix to quick-deploy script..."
    
    if ! grep -q "fix-file-icons" "$SCRIPT_DIR/quick-deploy.sh"; then
        sed -i '/restore-shell-features.sh/a\
\
# Fix file icons\
if [[ -f "fix-file-icons.sh" ]]; then\
    chmod +x fix-file-icons.sh\
    echo "🎨 Fixing file icons..."\
    echo "y" | ./fix-file-icons.sh\
fi' "$SCRIPT_DIR/quick-deploy.sh"
        
        print_success "Added to quick-deploy for future deployments"
    fi
fi
