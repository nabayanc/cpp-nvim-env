#!/bin/bash
# Fixed Zsh + Oh My Zsh Installation Script
# Resolves syntax errors in conditional expressions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[ZSH]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to compare version numbers
version_compare() {
    local ver1=$1
    local ver2=$2
    
    # Remove any non-numeric characters except dots
    ver1=$(echo "$ver1" | sed 's/[^0-9.]//g')
    ver2=$(echo "$ver2" | sed 's/[^0-9.]//g')
    
    # Simple version comparison using sort
    if [[ "$ver1" = "$ver2" ]]; then
        return 0  # Equal
    fi
    
    local older_version
    older_version=$(printf '%s\n%s\n' "$ver1" "$ver2" | sort -V | head -1)
    
    if [[ "$older_version" = "$ver1" ]]; then
        return 1  # ver1 < ver2
    else
        return 2  # ver1 > ver2
    fi
}

print_status "🐚 Installing Zsh + Oh My Zsh (Fixed Version)..."

# Step 1: Check for existing zsh
print_status "Step 1: Checking for existing zsh..."

ZSH_FOUND=""
ZSH_VERSION=""
ZSH_MIN_MAJOR=5

if command -v zsh >/dev/null 2>&1; then
    ZSH_FOUND=$(command -v zsh)
    ZSH_VERSION_RAW=$(zsh --version 2>/dev/null | head -1)
    ZSH_VERSION=$(echo "$ZSH_VERSION_RAW" | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    
    if [[ -n "$ZSH_VERSION" ]]; then
        ZSH_MAJOR=$(echo "$ZSH_VERSION" | cut -d. -f1)
        print_success "Found zsh: $ZSH_FOUND (version $ZSH_VERSION)"
        
        if [[ "$ZSH_MAJOR" -ge "$ZSH_MIN_MAJOR" ]]; then
            print_success "Zsh version is adequate (>= 5.0)"
        else
            print_warning "Zsh version $ZSH_VERSION is old (recommend 5.0+)"
        fi
    else
        print_warning "Could not determine zsh version"
        ZSH_VERSION="unknown"
    fi
else
    print_warning "No zsh found on system"
fi

# Step 2: Try to get a better zsh if needed
if [[ -z "$ZSH_FOUND" ]] || [[ "$ZSH_VERSION" = "unknown" ]]; then
    print_status "Step 2: Looking for alternative zsh installations..."
    
    # Check for environment modules
    if command -v module >/dev/null 2>&1; then
        print_status "Checking environment modules for zsh..."
        
        # Try common module names
        for module_name in zsh zsh/5.8 zsh/5.9 zsh/latest; do
            if module avail "$module_name" 2>&1 | grep -q "$module_name"; then
                print_status "Attempting to load module: $module_name"
                if module load "$module_name" 2>/dev/null; then
                    if command -v zsh >/dev/null 2>&1; then
                        ZSH_FOUND=$(command -v zsh)
                        ZSH_VERSION_RAW=$(zsh --version 2>/dev/null | head -1)
                        ZSH_VERSION=$(echo "$ZSH_VERSION_RAW" | grep -o '[0-9]\+\.[0-9]\+' | head -1)
                        print_success "Loaded zsh module: $module_name (version $ZSH_VERSION)"
                        
                        # Add to bashrc for persistence
                        if ! grep -q "module load $module_name" ~/.bashrc; then
                            echo "module load $module_name" >> ~/.bashrc
                            print_success "Added module load to ~/.bashrc"
                        fi
                        break
                    fi
                fi
            fi
        done
    else
        print_status "No environment modules system found"
    fi
    
    # If still no zsh, check common locations
    if [[ -z "$ZSH_FOUND" ]]; then
        print_status "Checking common zsh installation paths..."
        
        for zsh_path in /usr/local/bin/zsh /opt/local/bin/zsh ~/.local/bin/zsh; do
            if [[ -x "$zsh_path" ]]; then
                ZSH_FOUND="$zsh_path"
                ZSH_VERSION_RAW=$("$zsh_path" --version 2>/dev/null | head -1)
                ZSH_VERSION=$(echo "$ZSH_VERSION_RAW" | grep -o '[0-9]\+\.[0-9]\+' | head -1)
                print_success "Found zsh at: $zsh_path (version $ZSH_VERSION)"
                break
            fi
        done
    fi
fi

# Step 3: Final zsh check
if [[ -z "$ZSH_FOUND" ]]; then
    print_error "No suitable zsh installation found!"
    print_error "Please install zsh manually or contact system administrator"
    echo ""
    print_status "Manual installation options:"
    echo "  1. Ask admin to install zsh"
    echo "  2. Use environment modules: module load zsh"  
    echo "  3. Install from source (requires build tools)"
    exit 1
fi

print_success "Using zsh: $ZSH_FOUND (version $ZSH_VERSION)"

# Step 4: Install Oh My Zsh
print_status "Step 4: Installing Oh My Zsh..."

# Remove existing Oh My Zsh if present
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_warning "Existing Oh My Zsh found, creating backup..."
    mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.backup.$(date +%s)"
fi

# Download and install Oh My Zsh
print_status "Downloading Oh My Zsh installer..."
if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/install_omz.sh
elif command -v wget >/dev/null 2>&1; then
    wget -O /tmp/install_omz.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
else
    print_error "Neither curl nor wget available for download"
    exit 1
fi

# Make installer executable and run it
chmod +x /tmp/install_omz.sh
print_status "Running Oh My Zsh installer..."

# Set environment variables for unattended installation
export RUNZSH=no
export KEEP_ZSHRC=yes

# Run installer
if /tmp/install_omz.sh --unattended; then
    print_success "Oh My Zsh installed successfully"
else
    print_error "Oh My Zsh installation failed"
    rm -f /tmp/install_omz.sh
    exit 1
fi

# Cleanup
rm -f /tmp/install_omz.sh

# Step 5: Install useful plugins
print_status "Step 5: Installing useful plugins..."

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Install zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    print_status "Installing zsh-autosuggestions..."
    if git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
        print_success "Installed zsh-autosuggestions"
    else
        print_warning "Failed to install zsh-autosuggestions"
    fi
fi

# Install zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    print_status "Installing zsh-syntax-highlighting..."
    if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
        print_success "Installed zsh-syntax-highlighting"
    else
        print_warning "Failed to install zsh-syntax-highlighting"
    fi
fi

# Step 6: Create custom .zshrc
print_status "Step 6: Creating custom .zshrc configuration..."

# Backup existing .zshrc
if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
fi

# Create new .zshrc
cat > "$HOME/.zshrc" << 'EOFZSHRC'
# Custom Zsh Configuration with Oh My Zsh
# Safe syntax - no complex conditionals

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    extract
    z
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="$HOME/.local/bin:$PATH"

# History settings
HISTSIZE=50000
SAVEHIST=50000

# Aliases
alias ll='ls -alF'
alias la='ls -A' 
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Development aliases
alias v='nvim'
alias vim='nvim'
alias cls='clear'

# Git aliases (beyond Oh My Zsh defaults)
alias gst='git status'
alias gaa='git add --all'
alias gcmsg='git commit -m'

# C++ development
alias cpp-debug='g++ -std=c++17 -Wall -Wextra -g -DDEBUG'
alias cpp-release='g++ -std=c++17 -Wall -Wextra -O2 -DNDEBUG'

# Simple C++ project creation
cpp-init() {
    if [ -z "$1" ]; then
        echo "Usage: cpp-init <project-name>"
        return 1
    fi
    
    echo "Creating C++ project: $1"
    mkdir -p "$1"
    cd "$1"
    
    # Create main.cpp
    cat > main.cpp << 'EOFCPP'
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::cout << "Hello from PROJECT_NAME!" << std::endl;
    
    std::vector<std::string> features = {
        "Modern C++17",
        "Zsh + Oh My Zsh",
        "Ready for development"
    };
    
    std::cout << "Features:" << std::endl;
    for (const auto& feature : features) {
        std::cout << "  ✓ " << feature << std::endl;
    }
    
    return 0;
}
EOFCPP
    
    # Replace placeholder
    sed -i "s/PROJECT_NAME/$1/g" main.cpp
    
    # Create CMakeLists.txt
    cat > CMakeLists.txt << 'EOFCMAKE'
cmake_minimum_required(VERSION 3.10)
project(PROJECT_NAME)
set(CMAKE_CXX_STANDARD 17)
add_executable(main main.cpp)
EOFCMAKE
    
    sed -i "s/PROJECT_NAME/$1/g" CMakeLists.txt
    
    echo "✅ Created C++ project: $1"
    echo "Next: cpp-build && nvim ."
}

# Welcome message
echo "🎯 Zsh + Oh My Zsh environment ready!"
echo "💡 Try: cpp-init <project-name>"
EOFZSHRC

print_success "Created custom .zshrc"

# Step 7: Set up zsh usage
print_status "Step 7: Setting up zsh usage..."

# Create zsh launcher script
cat > "$HOME/.local/bin/use-zsh" << EOFZSH
#!/bin/bash
# Start zsh session
export SHELL="$ZSH_FOUND"
exec "$ZSH_FOUND" "\$@"
EOFZSH

chmod +x "$HOME/.local/bin/use-zsh"

# Add auto-start to bashrc (simple version)
if ! grep -q "use-zsh" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOFAUTO'

# Auto-start zsh (simple version)
if [ -t 1 ] && [ -x "$HOME/.local/bin/use-zsh" ] && [ "$0" != "zsh" ]; then
    exec $HOME/.local/bin/use-zsh
fi
EOFAUTO
    print_success "Added zsh auto-start to ~/.bashrc"
fi

print_success "🎉 Zsh + Oh My Zsh installation complete!"

echo ""
print_status "📋 INSTALLATION SUMMARY:"
echo "  ✅ Zsh: $ZSH_FOUND (version $ZSH_VERSION)"
echo "  ✅ Oh My Zsh with custom configuration"
echo "  ✅ Useful plugins: autosuggestions, syntax highlighting"
echo "  ✅ C++ development functions"
echo "  ✅ Auto-start configured"
echo ""
print_status "🚀 HOW TO USE:"
echo "  Option 1: use-zsh        # Manual start"
echo "  Option 2: zsh            # Direct command"
echo "  Option 3: Restart terminal (auto-start)"
echo ""
print_status "🧪 TEST YOUR SETUP:"
echo "  1. Run: use-zsh"
echo "  2. Try: cpp-init test-project"
echo "  3. Check: echo \$ZSH_VERSION"
echo ""
print_success "Your enhanced Zsh environment is ready! 🐚✨"
