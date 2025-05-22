#!/bin/bash
# Fix script for C++ Neovim environment
# Run from cpp-nvim-env directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[FIX]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
INSTALL_DIR="$HOME/.local"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TOOLS_DIR="$HOME/.local/tools"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Starting comprehensive fix for C++ Neovim environment..."

# Check we're in the right directory
if [[ ! -f "setup.sh" || ! -d "nvim" ]]; then
    print_error "Please run this script from the cpp-nvim-env directory"
    print_error "Expected files: setup.sh, nvim/"
    exit 1
fi

print_status "Detected project directory: $SCRIPT_DIR"

# Step 1: Remove broken Neovim installation
print_status "Step 1: Removing current Neovim installation..."
rm -f "$INSTALL_DIR/bin/nvim"
rm -rf "$TOOLS_DIR/nvim"*
print_success "Removed old Neovim"

# Step 2: Check system glibc version
print_status "Step 2: Checking system compatibility..."
GLIBC_VERSION=$(ldd --version | head -1 | grep -o '[0-9]\+\.[0-9]\+' | head -1)
print_status "System GLIBC version: $GLIBC_VERSION"

# Step 3: Install compatible Neovim
print_status "Step 3: Installing compatible Neovim 0.9.5..."
mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR"

if command -v curl >/dev/null 2>&1; then
    print_status "Downloading with curl..."
    curl -L --progress-bar -o nvim-linux64.tar.gz \
        https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
elif command -v wget >/dev/null 2>&1; then
    print_status "Downloading with wget..."
    wget --progress=bar:force:noscroll -O nvim-linux64.tar.gz \
        https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
else
    print_error "Neither curl nor wget found"
    exit 1
fi

print_status "Extracting Neovim..."
tar -xzf nvim-linux64.tar.gz
ln -sf "$TOOLS_DIR/nvim-linux64/bin/nvim" "$INSTALL_DIR/bin/nvim"
rm nvim-linux64.tar.gz

# Test Neovim installation
print_status "Testing Neovim installation..."
if "$INSTALL_DIR/bin/nvim" --version >/dev/null 2>&1; then
    print_success "Neovim installed successfully"
    NVIM_VERSION=$("$INSTALL_DIR/bin/nvim" --version | head -1)
    print_status "Version: $NVIM_VERSION"
else
    print_error "Neovim installation failed"
    print_error "This may be a glibc compatibility issue"
    exit 1
fi

# Step 4: Clear plugin state
print_status "Step 4: Clearing plugin cache and state..."
rm -rf "$HOME/.local/share/nvim/"
rm -rf "$HOME/.local/state/nvim/"
rm -rf "$HOME/.cache/nvim/"
print_success "Cleared plugin state"

# Step 5: Create fixed treesitter config
print_status "Step 5: Creating compatible treesitter configuration..."
cat > "$SCRIPT_DIR/nvim/lua/plugins/treesitter.lua" << 'EOF'
-- Treesitter Configuration for Syntax Highlighting
-- Compatible with Neovim 0.9.5

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "bash", "cmake", "make" },
        sync_install = false,
        auto_install = false,
        highlight = { 
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { 
          enable = true,
          disable = { "python" },
        },
        incremental_selection = {
          enable = false,
        },
        textobjects = {
          enable = false,
        },
      })
    end,
  },
}
EOF
print_success "Updated treesitter configuration"

# Step 6: Update which-key config for compatibility
print_status "Step 6: Fixing which-key configuration..."
cat > "$SCRIPT_DIR/nvim/lua/plugins/which-key-fix.lua" << 'EOF'
-- Which-key fix for compatibility
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300

      require("which-key").setup({
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
        window = {
          border = "rounded",
          position = "bottom",
          margin = { 1, 0, 1, 0 },
          padding = { 2, 2, 2, 2 },
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          align = "left",
        },
      })

      -- Use new format for groups
      local wk = require("which-key")
      wk.register({
        ["<leader>b"] = { name = "buffer" },
        ["<leader>c"] = { name = "code/compile" },
        ["<leader>f"] = { name = "file/find" },
        ["<leader>g"] = { name = "git" },
        ["<leader>l"] = { name = "lsp" },
        ["<leader>o"] = { name = "options" },
        ["<leader>p"] = { name = "project/telescope" },
        ["<leader>s"] = { name = "search/session" },
        ["<leader>t"] = { name = "terminal/tab" },
        ["<leader>v"] = { name = "vim/lsp" },
        ["<leader>w"] = { name = "window" },
        ["<leader>x"] = { name = "quickfix" },
      })
    end,
  },
}
EOF

# Remove the old which-key config from essentials.lua and replace it
print_status "Updating essentials.lua to remove which-key..."
sed -i '/-- Which key for keybinding help/,/^  },$/d' "$SCRIPT_DIR/nvim/lua/plugins/essentials.lua"
print_success "Fixed which-key configuration"

# Step 7: Update Neovim configuration
print_status "Step 7: Updating Neovim configuration..."
if [ -d "$NVIM_CONFIG_DIR" ] && [ "$(ls -A "$NVIM_CONFIG_DIR")" ]; then
    print_warning "Backing up existing config..."
    mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup.$(date +%s)"
fi

cp -r "$SCRIPT_DIR/nvim" "$NVIM_CONFIG_DIR"
print_success "Updated Neovim configuration"

# Step 8: Verify other tools
print_status "Step 8: Verifying other tools..."

# Check clangd
if command -v clangd >/dev/null 2>&1; then
    print_success "clangd found: $(clangd --version | head -1)"
else
    print_warning "clangd not found - running setup.sh to install"
    cd "$SCRIPT_DIR"
    ./setup.sh
fi

# Check ripgrep
if command -v rg >/dev/null 2>&1; then
    print_success "ripgrep found: $(rg --version | head -1)"
else
    print_warning "ripgrep not found in PATH"
fi

# Check fd
if command -v fd >/dev/null 2>&1; then
    print_success "fd found: $(fd --version | head -1)"
else
    print_warning "fd not found in PATH"
fi

# Step 9: Test basic functionality
print_status "Step 9: Testing basic functionality..."

# Test Neovim starts
if timeout 5 nvim --headless +q; then
    print_success "Neovim starts successfully"
else
    print_error "Neovim fails to start"
    exit 1
fi

# Step 10: Create test project if it doesn't exist
print_status "Step 10: Setting up test project..."
TEST_DIR="$HOME/test-cpp-fixed"
if [[ ! -d "$TEST_DIR" ]]; then
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    cat > main.cpp << 'EOF'
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::vector<std::string> messages = {
        "Fixed C++ environment is working!",
        "LSP should be active now",
        "Ready for development!"
    };
    
    for (const auto& msg : messages) {
        std::cout << msg << std::endl;
    }
    
    return 0;
}
EOF

    # Build with LSP support
    cpp-build
    print_success "Created and built test project in $TEST_DIR"
else
    print_success "Test project already exists at $TEST_DIR"
fi

# Final status
print_success "Fix complete!"
echo ""
print_status "Summary of changes:"
echo "  ✓ Installed compatible Neovim 0.9.5"
echo "  ✓ Cleared plugin cache and state"
echo "  ✓ Fixed treesitter configuration"
echo "  ✓ Fixed which-key configuration"
echo "  ✓ Updated Neovim configuration"
echo "  ✓ Verified development tools"
echo "  ✓ Created test project"
echo ""
print_status "Next steps:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Test: cd $TEST_DIR && nvim main.cpp"
echo "  3. In Neovim: Wait for plugins to install, then test LSP"
echo "  4. Check health: :checkhealth lsp"
echo ""
print_status "Key test commands in Neovim:"
echo "  - Put cursor on 'std::cout' and press 'K' for hover docs"
echo "  - Put cursor on 'vector' and press 'gd' for go-to-definition"
echo "  - Press '<Space>pf' for file finder"
echo "  - Type ':LspInfo' to check LSP status"
echo ""
print_warning "On first Neovim launch, plugins will auto-install (takes 1-2 minutes)"
print_success "Your C++ development environment should now be working!"
