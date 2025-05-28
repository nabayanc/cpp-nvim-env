#!/bin/bash
# Neovim Treesitter Diagnostic and Fix Script
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[NVIM]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_status "🔍 Diagnosing Neovim Treesitter Issues..."

# Step 1: Check Neovim installation
print_status "Step 1: Checking Neovim installation..."

if ! command -v nvim >/dev/null 2>&1; then
    print_error "Neovim not found in PATH"
    exit 1
fi

NVIM_VERSION=$(nvim --version | head -1)
print_success "Found: $NVIM_VERSION"

# Check Neovim version compatibility
NVIM_VERSION_NUM=$(nvim --version | head -1 | grep -o 'v[0-9]\+\.[0-9]\+' | sed 's/v//')
print_status "Neovim version: $NVIM_VERSION_NUM"

# Step 2: Check Neovim configuration structure
print_status "Step 2: Checking Neovim configuration structure..."

NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    print_error "Neovim config directory not found: $NVIM_CONFIG_DIR"
    exit 1
fi

print_success "Config directory found: $NVIM_CONFIG_DIR"

# Check for key files
if [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
    print_success "Found init.lua"
else
    print_warning "No init.lua found"
fi

if [[ -f "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua" ]]; then
    print_success "Found treesitter.lua"
    print_status "Current treesitter.lua content:"
    echo "----------------------------------------"
    cat "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua"
    echo "----------------------------------------"
else
    print_warning "No treesitter.lua found"
fi

# Step 3: Check plugin manager
print_status "Step 3: Checking plugin manager..."

# Common plugin manager locations
PLUGIN_MANAGERS=(
    "lazy" 
    "packer"
    "vim-plug"
    "dein"
)

FOUND_PLUGIN_MANAGER=""
PLUGIN_INSTALL_DIR=""

# Check for Lazy.nvim (most common modern plugin manager)
if [[ -d "$HOME/.local/share/nvim/lazy" ]]; then
    FOUND_PLUGIN_MANAGER="lazy"
    PLUGIN_INSTALL_DIR="$HOME/.local/share/nvim/lazy"
    print_success "Found Lazy.nvim plugin manager"
elif [[ -d "$HOME/.local/share/nvim/site/pack/packer" ]]; then
    FOUND_PLUGIN_MANAGER="packer"
    PLUGIN_INSTALL_DIR="$HOME/.local/share/nvim/site/pack/packer"
    print_success "Found Packer plugin manager"
else
    print_warning "Could not determine plugin manager"
fi

# Step 4: Check if nvim-treesitter is installed
print_status "Step 4: Checking nvim-treesitter installation..."

TREESITTER_INSTALLED=false
TREESITTER_PATH=""

if [[ -n "$PLUGIN_INSTALL_DIR" ]]; then
    # Look for nvim-treesitter in plugin directory
    TREESITTER_SEARCH=$(find "$PLUGIN_INSTALL_DIR" -name "*treesitter*" -type d 2>/dev/null | head -5)
    
    if [[ -n "$TREESITTER_SEARCH" ]]; then
        echo "Found treesitter-related directories:"
        echo "$TREESITTER_SEARCH"
        
        # Check for the main nvim-treesitter plugin
        for dir in $TREESITTER_SEARCH; do
            if [[ -f "$dir/lua/nvim-treesitter/configs.lua" ]] || [[ -f "$dir/lua/nvim-treesitter.lua" ]]; then
                TREESITTER_INSTALLED=true
                TREESITTER_PATH="$dir"
                print_success "nvim-treesitter found at: $dir"
                break
            fi
        done
    fi
fi

if [[ "$TREESITTER_INSTALLED" == false ]]; then
    print_warning "nvim-treesitter plugin not found or not properly installed"
fi

# Step 5: Create/fix treesitter configuration
print_status "Step 5: Creating fixed treesitter configuration..."

# Backup existing config
if [[ -f "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua" ]]; then
    cp "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua" "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua.backup.$(date +%s)"
    print_status "Backed up existing treesitter.lua"
fi

# Create plugins directory if it doesn't exist
mkdir -p "$NVIM_CONFIG_DIR/lua/plugins"

# Create a safer treesitter configuration
cat > "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua" << 'EOFTREESITTER'
-- Safe Treesitter Configuration
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Check if nvim-treesitter is actually available
    local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
      vim.notify("nvim-treesitter not found. Please install it first.", vim.log.levels.WARN)
      return
    end

    treesitter_configs.setup({
      -- A list of parser names, or "all"
      ensure_installed = {
        "c",
        "cpp", 
        "lua",
        "vim",
        "vimdoc",
        "query",
        "python",
        "javascript",
        "html",
        "css",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "bash",
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      auto_install = true,

      -- List of parsers to ignore installing (for "all")
      ignore_install = {},

      highlight = {
        enable = true,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },

      indent = {
        enable = true,
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn", 
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
    })

    -- Additional treesitter modules (optional)
    -- Uncomment these if you have the corresponding plugins installed
    
    --[[ 
    -- For nvim-treesitter-textobjects
    require('nvim-treesitter.configs').setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner", 
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    })
    --]]
  end,
}
EOFTREESITTER

print_success "Created safe treesitter configuration"

# Step 6: Check/create plugin installation setup
print_status "Step 6: Checking plugin installation setup..."

# Check if there's a plugins.lua or similar file that defines plugins
PLUGIN_FILES=(
    "$NVIM_CONFIG_DIR/lua/plugins.lua"
    "$NVIM_CONFIG_DIR/lua/plugins/init.lua"
    "$NVIM_CONFIG_DIR/lua/lazy-plugins.lua"
)

FOUND_PLUGIN_FILE=""
for file in "${PLUGIN_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        FOUND_PLUGIN_FILE="$file"
        print_success "Found plugin definition file: $file"
        break
    fi
done

if [[ -z "$FOUND_PLUGIN_FILE" ]]; then
    print_warning "No plugin definition file found"
    print_status "Creating basic plugin setup with Lazy.nvim..."
    
    # Create lazy.lua setup
    cat > "$NVIM_CONFIG_DIR/lua/lazy-setup.lua" << 'EOFLAZYSETUP'
-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", 
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup("plugins", {
  change_detection = {
    notify = false,
  },
})
EOFLAZYSETUP

    print_success "Created lazy.nvim setup"
fi

# Step 7: Create installation script
print_status "Step 7: Creating installation helper..."

cat > "$NVIM_CONFIG_DIR/install-treesitter.lua" << 'EOFINSTALL'
-- Treesitter Installation Helper
-- Run this with: nvim -l ~/.config/nvim/install-treesitter.lua

print("🌳 Installing nvim-treesitter...")

-- Add lazy.nvim to runtime path if it exists
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.loop.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
  
  -- Try to install/update treesitter
  local lazy = require("lazy")
  
  -- Install treesitter plugin
  lazy.install({
    wait = true,
    plugins = { "nvim-treesitter/nvim-treesitter" }
  })
  
  print("✅ Installation complete!")
  print("Now run: :TSUpdate in Neovim to install parsers")
else
  print("❌ lazy.nvim not found. Please install it first.")
  print("Run this in Neovim:")
  print("  :lua require('lazy-setup')")
end
EOFINSTALL

chmod +x "$NVIM_CONFIG_DIR/install-treesitter.lua"

# Summary and recommendations
echo ""
print_success "🎉 Neovim Treesitter Diagnostic Complete!"
echo ""
print_status "📋 FINDINGS:"
echo "  • Neovim: $NVIM_VERSION_NUM"
echo "  • Config dir: $NVIM_CONFIG_DIR"
echo "  • Plugin manager: ${FOUND_PLUGIN_MANAGER:-'Unknown'}"
echo "  • Treesitter installed: ${TREESITTER_INSTALLED}"
echo ""
print_status "🔧 FIXES APPLIED:"
echo "  • Created safe treesitter.lua configuration"
echo "  • Added error checking to prevent crashes"
echo "  • Created installation helper script"
echo ""
print_status "🚀 NEXT STEPS:"
echo "  1. Open Neovim: nvim"
echo "  2. Install plugins (if using Lazy.nvim): :Lazy install"
echo "  3. Update treesitter parsers: :TSUpdate"
echo "  4. Or run the helper: nvim -l ~/.config/nvim/install-treesitter.lua"
echo ""
if [[ "$TREESITTER_INSTALLED" == false ]]; then
    print_warning "⚠ If treesitter still doesn't work:"
    echo "  • Make sure your plugin manager is set up correctly"
    echo "  • Run :Lazy sync (for Lazy.nvim) or equivalent for your plugin manager"
    echo "  • Check :checkhealth nvim-treesitter"
fi

print_success "Neovim should now start without treesitter errors! 🌳"
