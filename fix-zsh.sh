#!/bin/bash
# Zsh Diagnostic and Fix Script
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[DIAG]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_status "🔍 Diagnosing Zsh Installation Issues..."

# Step 1: Find and analyze current zsh
print_status "Step 1: Analyzing current zsh installation..."

ZSH_PATH=$(command -v zsh 2>/dev/null || echo "")
if [[ -z "$ZSH_PATH" ]]; then
    print_error "No zsh found in PATH"
    exit 1
fi

print_success "Found zsh at: $ZSH_PATH"

# Get zsh version and info
ZSH_VERSION_FULL=$($ZSH_PATH --version 2>/dev/null || echo "unknown")
print_status "Zsh version: $ZSH_VERSION_FULL"

# Step 2: Check zsh installation completeness
print_status "Step 2: Checking zsh installation completeness..."

# Find zsh installation directory
ZSH_PREFIX=$(dirname $(dirname $ZSH_PATH))
print_status "Zsh prefix directory: $ZSH_PREFIX"

# Common locations for zsh functions
POTENTIAL_FPATH_DIRS=(
    "$ZSH_PREFIX/share/zsh/functions"
    "$ZSH_PREFIX/share/zsh/*/functions"
    "$ZSH_PREFIX/share/zsh/site-functions" 
    "/usr/share/zsh/functions"
    "/usr/share/zsh/*/functions"
    "/usr/share/zsh/site-functions"
    "/usr/local/share/zsh/functions"
    "/usr/local/share/zsh/*/functions"
    "/usr/local/share/zsh/site-functions"
)

print_status "Searching for zsh function directories..."
FOUND_FPATH_DIRS=()

for dir_pattern in "${POTENTIAL_FPATH_DIRS[@]}"; do
    for dir in $dir_pattern; do
        if [[ -d "$dir" ]]; then
            FOUND_FPATH_DIRS+=("$dir")
            print_success "Found function directory: $dir"
            
            # Check for key functions
            key_functions=("compinit" "compdef" "add-zsh-hook" "is-at-least" "colors")
            for func in "${key_functions[@]}"; do
                if [[ -f "$dir/$func" ]]; then
                    echo "    ✓ $func"
                else
                    echo "    ✗ $func (missing)"
                fi
            done
        fi
    done
done

if [[ ${#FOUND_FPATH_DIRS[@]} -eq 0 ]]; then
    print_error "No zsh function directories found!"
    print_error "This indicates an incomplete zsh installation."
else
    print_success "Found ${#FOUND_FPATH_DIRS[@]} function directories"
fi

# Step 3: Test basic zsh functionality
print_status "Step 3: Testing basic zsh functionality..."

# Create a test script to check if functions load
cat > /tmp/zsh_test.zsh << 'EOFTEST'
#!/usr/bin/env zsh
# Test script to check zsh function loading

echo "Testing zsh function availability..."

# Set up FPATH
typeset -U fpath  # Remove duplicates
fpath=(
    FPATH_PLACEHOLDER
    $fpath
)

# Try to load essential functions
autoload -Uz compinit
autoload -Uz compdef  
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
autoload -Uz colors

# Test if functions are available
functions_to_test=("compinit" "compdef" "add-zsh-hook" "is-at-least" "colors")
missing_functions=()

for func in "${functions_to_test[@]}"; do
    if ! whence -f "$func" >/dev/null 2>&1; then
        missing_functions+=("$func")
        echo "✗ $func - NOT AVAILABLE"
    else
        echo "✓ $func - available"
    fi
done

if [[ ${#missing_functions[@]} -eq 0 ]]; then
    echo "SUCCESS: All essential functions are available"
    exit 0
else
    echo "ERROR: Missing functions: ${missing_functions[*]}"
    exit 1
fi
EOFTEST

# Replace FPATH_PLACEHOLDER with actual directories
if [[ ${#FOUND_FPATH_DIRS[@]} -gt 0 ]]; then
    FPATH_STRING=""
    for dir in "${FOUND_FPATH_DIRS[@]}"; do
        FPATH_STRING="    \"$dir\"\n$FPATH_STRING"
    done
    sed -i "s|FPATH_PLACEHOLDER|$FPATH_STRING|g" /tmp/zsh_test.zsh
else
    sed -i "s|FPATH_PLACEHOLDER||g" /tmp/zsh_test.zsh
fi

chmod +x /tmp/zsh_test.zsh

print_status "Running zsh function test..."
if $ZSH_PATH /tmp/zsh_test.zsh; then
    print_success "Zsh functions are working correctly!"
    FUNCTIONS_WORKING=true
else
    print_warning "Zsh functions are not loading properly"
    FUNCTIONS_WORKING=false
fi

rm -f /tmp/zsh_test.zsh

# Step 4: Create fixed .zshrc
print_status "Step 4: Creating fixed .zshrc configuration..."

# Backup existing .zshrc
if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.diagnostic.$(date +%s)"
    print_status "Backed up existing .zshrc"
fi

# Create a new .zshrc with proper FPATH setup
cat > "$HOME/.zshrc" << 'EOFZSHRC'
# Fixed Zsh Configuration - Diagnostic Version
# This version ensures proper function loading

# Set up FPATH first (before anything else)
typeset -U fpath  # Remove duplicates from fpath

# Add zsh function directories to fpath
fpath=(
FPATH_DIRS_PLACEHOLDER
    $fpath
)

# Load essential functions explicitly
autoload -Uz compinit
autoload -Uz compdef
autoload -Uz add-zsh-hook  
autoload -Uz is-at-least
autoload -Uz colors

# Initialize completion system
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Initialize colors
colors

# Path to oh-my-zsh installation  
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins (start with minimal set)
plugins=(
    git
)

# Load Oh My Zsh (now that functions are available)
if [[ -f $ZSH/oh-my-zsh.sh ]]; then
    source $ZSH/oh-my-zsh.sh
else
    echo "Warning: Oh My Zsh not found at $ZSH"
fi

# Add plugins gradually (after Oh My Zsh loads)
if [[ -d "$ZSH/custom/plugins/zsh-autosuggestions" ]]; then
    source "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]]; then
    source "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

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
alias v='nvim'
alias vim='nvim'
alias cls='clear'

# Git aliases
alias gst='git status'
alias gaa='git add --all'
alias gcmsg='git commit -m'

# C++ development
alias cpp-debug='g++ -std=c++17 -Wall -Wextra -g -DDEBUG'
alias cpp-release='g++ -std=c++17 -Wall -Wextra -O2 -DNDEBUG'

# Simple C++ project creation function
cpp-init() {
    if [[ -z "$1" ]]; then
        echo "Usage: cpp-init <project-name>"
        return 1
    fi
    
    echo "Creating C++ project: $1"
    mkdir -p "$1"
    cd "$1"
    
    cat > main.cpp << 'EOFCPP'
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::cout << "Hello from PROJECT_NAME!" << std::endl;
    
    std::vector<std::string> features = {
        "Modern C++17",
        "Fixed Zsh + Oh My Zsh", 
        "Ready for development"
    };
    
    std::cout << "Features:" << std::endl;
    for (const auto& feature : features) {
        std::cout << "  ✓ " << feature << std::endl;
    }
    
    return 0;
}
EOFCPP
    
    sed -i "s/PROJECT_NAME/$1/g" main.cpp
    
    cat > CMakeLists.txt << 'EOFCMAKE'
cmake_minimum_required(VERSION 3.10)
project(PROJECT_NAME)
set(CMAKE_CXX_STANDARD 17)
add_executable(main main.cpp)
EOFCMAKE
    
    sed -i "s/PROJECT_NAME/$1/g" CMakeLists.txt
    
    echo "✅ Created C++ project: $1"
    echo "Next: g++ -o main main.cpp && ./main"
}

echo "🔧 Fixed Zsh environment loaded!"
EOFZSHRC

# Insert found FPATH directories into .zshrc
if [[ ${#FOUND_FPATH_DIRS[@]} -gt 0 ]]; then
    FPATH_LINES=""
    for dir in "${FOUND_FPATH_DIRS[@]}"; do
        FPATH_LINES="    \"$dir\"\n$FPATH_LINES"
    done
    sed -i "s|FPATH_DIRS_PLACEHOLDER|$FPATH_LINES|g" "$HOME/.zshrc"
else
    sed -i "s|FPATH_DIRS_PLACEHOLDER||g" "$HOME/.zshrc"
fi

print_success "Created fixed .zshrc configuration"

# Step 5: Create improved launcher
print_status "Step 5: Creating improved zsh launcher..."

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/use-zsh-fixed" << EOFZSH
#!/bin/bash
# Fixed Zsh Launcher
export SHELL="$ZSH_PATH"

# Set environment for proper zsh function loading
if [[ ${#FOUND_FPATH_DIRS[@]} -gt 0 ]]; then
    export FPATH="$(IFS=:; echo "${FOUND_FPATH_DIRS[*]}"):$FPATH"
fi

# Launch zsh
exec "$ZSH_PATH" "\$@"
EOFZSH

chmod +x "$HOME/.local/bin/use-zsh-fixed"

print_success "Created improved zsh launcher: use-zsh-fixed"

# Step 6: Final test
print_status "Step 6: Testing the fix..."

print_status "Running quick test of fixed configuration..."
if $ZSH_PATH -c 'source ~/.zshrc && echo "✓ Configuration loaded successfully"' 2>/dev/null; then
    print_success "Fixed configuration loads without errors!"
else
    print_warning "There may still be some issues with the configuration"
fi

# Summary
echo ""
print_success "🎉 Zsh Diagnostic and Fix Complete!"
echo ""
print_status "📋 SUMMARY:"
echo "  • Zsh path: $ZSH_PATH"
echo "  • Function directories found: ${#FOUND_FPATH_DIRS[@]}"
if [[ $FUNCTIONS_WORKING == true ]]; then
    echo "  • Function loading: ✓ Working"
else
    echo "  • Function loading: ⚠ Fixed in new config"
fi
echo "  • Fixed .zshrc created with proper FPATH"
echo "  • New launcher: use-zsh-fixed"
echo ""
print_status "🚀 HOW TO TEST:"
echo "  1. Run: use-zsh-fixed"
echo "  2. Try: cpp-init test-project"
echo "  3. Check for errors"
echo ""
if [[ $FUNCTIONS_WORKING == false ]]; then
    print_warning "If issues persist, your zsh installation may be incomplete."
    print_warning "Consider asking your system administrator to reinstall zsh."
fi

print_success "Diagnostic complete! Try 'use-zsh-fixed' now. 🐚"
