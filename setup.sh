#!/bin/bash
# Portable C++ Development Environment Setup for Remote Nodes
# Usage: ./setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

print_status "Setting up portable C++ development environment..."
print_status "Install directory: $INSTALL_DIR"

# Create directories
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$TOOLS_DIR"
mkdir -p "$NVIM_CONFIG_DIR"

# Add to PATH if not already there
if ! echo "$PATH" | grep -q "$INSTALL_DIR/bin"; then
    print_status "Adding $INSTALL_DIR/bin to PATH in ~/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Function to download with progress
download_with_progress() {
    local url=$1
    local output=$2
    print_status "Downloading $(basename "$output")..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L --progress-bar "$url" -o "$output"
    elif command -v wget >/dev/null 2>&1; then
        wget --progress=bar:force:noscroll -O "$output" "$url"
    else
        print_error "Neither curl nor wget found. Cannot download files."
        exit 1
    fi
}

# Install Neovim static binary
if [ ! -f "$INSTALL_DIR/bin/nvim" ]; then
    print_status "Installing Neovim..."
    cd "$TOOLS_DIR"
    download_with_progress \
        "https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz" \
        "nvim-linux64.tar.gz"
    
    print_status "Extracting Neovim..."
    tar -xzf nvim-linux64.tar.gz
    ln -sf "$TOOLS_DIR/nvim-linux64/bin/nvim" "$INSTALL_DIR/bin/nvim"
    rm nvim-linux64.tar.gz
    print_success "Neovim installed"
else
    print_success "Neovim already installed"
fi
# Install clangd
if [ ! -f "$INSTALL_DIR/bin/clangd" ]; then
    print_status "Installing clangd..."
    cd "$TOOLS_DIR"
    
    # Get latest clangd release
    if command -v curl >/dev/null 2>&1; then
        CLANGD_VERSION=$(curl -s https://api.github.com/repos/clangd/clangd/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    else
        CLANGD_VERSION="18.1.3"  # Fallback version
    fi
    
    download_with_progress \
        "https://github.com/clangd/clangd/releases/download/$CLANGD_VERSION/clangd-linux-$CLANGD_VERSION.zip" \
        "clangd-linux-$CLANGD_VERSION.zip"
    
    unzip -q "clangd-linux-$CLANGD_VERSION.zip"
    CLANGD_DIR=$(ls -d clangd_* | head -1)
    ln -sf "$TOOLS_DIR/$CLANGD_DIR/bin/clangd" "$INSTALL_DIR/bin/clangd"
    rm "clangd-linux-$CLANGD_VERSION.zip"
    print_success "clangd installed"
else
    print_success "clangd already installed"
fi

# Install ripgrep
if [ ! -f "$INSTALL_DIR/bin/rg" ]; then
    print_status "Installing ripgrep..."
    cd "$TOOLS_DIR"
    
    if command -v curl >/dev/null 2>&1; then
        RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    else
        RG_VERSION="14.1.0"  # Fallback version
    fi
    
    download_with_progress \
        "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz" \
        "ripgrep.tar.gz"
    
    tar -xzf "ripgrep.tar.gz"
    RG_DIR=$(ls -d ripgrep-* | head -1)
    ln -sf "$TOOLS_DIR/$RG_DIR/rg" "$INSTALL_DIR/bin/rg"
    rm "ripgrep.tar.gz"
    print_success "ripgrep installed"
else
    print_success "ripgrep already installed"
fi

# Install fd
if [ ! -f "$INSTALL_DIR/bin/fd" ]; then
    print_status "Installing fd..."
    cd "$TOOLS_DIR"
    
    if command -v curl >/dev/null 2>&1; then
        FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    else
        FD_VERSION="v10.1.0"  # Fallback version
    fi
    
    download_with_progress \
        "https://github.com/sharkdp/fd/releases/download/$FD_VERSION/fd-$FD_VERSION-x86_64-unknown-linux-musl.tar.gz" \
        "fd.tar.gz"
    
    tar -xzf "fd.tar.gz"
    FD_DIR=$(ls -d fd-* | head -1)
    ln -sf "$TOOLS_DIR/$FD_DIR/fd" "$INSTALL_DIR/bin/fd"
    rm "fd.tar.gz"
    print_success "fd installed"
else
    print_success "fd already installed"
fi

# Copy Neovim configuration
print_status "Setting up Neovim configuration..."
if [ -d "$NVIM_CONFIG_DIR" ] && [ "$(ls -A "$NVIM_CONFIG_DIR")" ]; then
    print_warning "Existing Neovim config found. Creating backup..."
    mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup.$(date +%s)"
fi

cp -r "$SCRIPT_DIR/nvim" "$NVIM_CONFIG_DIR"
print_success "Neovim configuration installed"

# Make build helper executable
chmod +x "$SCRIPT_DIR/cpp-build.sh"
ln -sf "$SCRIPT_DIR/cpp-build.sh" "$INSTALL_DIR/bin/cpp-build"

print_success "Setup complete!"
echo ""
print_status "Next steps:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Run: nvim (plugins will auto-install on first launch)"
echo "  3. In your C++ project: cpp-build"
echo "  4. Start coding with: nvim ."
echo ""
print_status "Useful commands:"
echo "  nvim --version          # Check Neovim version"
echo "  clangd --version        # Check clangd version"
echo "  cpp-build [project-dir] # Build C++ project with LSP support"
echo ""
print_warning "Remember to run 'source ~/.bashrc' or restart your shell!"
