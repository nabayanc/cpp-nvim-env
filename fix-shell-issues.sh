#!/bin/bash
# Fix Shell Issues - Remove problematic Oh My Zsh and create clean setup
# Run this to fix the connection dropping and zsh errors

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

print_status "🔧 Fixing shell configuration issues..."

# Step 1: Remove problematic Oh My Zsh auto-start from .bashrc
print_status "Step 1: Removing problematic zsh auto-start..."

# Backup current .bashrc
if [[ -f "$HOME/.bashrc" ]]; then
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%s)"
    print_status "Backed up .bashrc"
fi

# Remove the auto-zsh section that's causing connection drops
if [[ -f "$HOME/.bashrc" ]]; then
    # Create a temporary file without the problematic zsh auto-start
    grep -v "Auto-start zsh" "$HOME/.bashrc" | \
    grep -v "ZSH_AUTO_STARTED" | \
    grep -v "exec zsh" > "$HOME/.bashrc.tmp"
    
    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
    print_success "Removed problematic zsh auto-start"
fi

# Step 2: Create a simple, working zsh configuration (without Oh My Zsh)
print_status "Step 2: Creating simple zsh configuration..."

if command -v zsh >/dev/null 2>&1; then
    # Create a minimal .zshrc that actually works
    cat > "$HOME/.zshrc" << 'EOF'
# Simple Zsh Configuration for C++ Development
# No Oh My Zsh - just clean, working zsh

# Basic options
setopt AUTO_CD
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Simple but effective prompt
autoload -U colors && colors
PROMPT="%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$ "

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Aliases for C++ development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Development aliases
alias v='nvim'
alias vim='nvim'
alias cls='clear'
alias h='history'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# C++ specific aliases
alias cpp-debug='g++ -std=c++17 -Wall -Wextra -g -DDEBUG'
alias cpp-release='g++ -std=c++17 -Wall -Wextra -O2 -DNDEBUG'

# Quick navigation
alias cpp-test='cd ~/cpp-test-fixed'
alias dev='cd ~/cpp-nvim-env'

# Function to create C++ project
cpp-init() {
    if [[ -z "$1" ]]; then
        echo "Usage: cpp-init <project-name>"
        return 1
    fi
    
    mkdir -p "$1"
    cd "$1"
    
    cat > main.cpp << 'EOFCPP'
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
EOFCPP
    
    cat > CMakeLists.txt << 'EOFCMAKE'
cmake_minimum_required(VERSION 3.10)
project(PROJECT_NAME)

set(CMAKE_CXX_STANDARD 17)
add_executable(main main.cpp)
EOFCMAKE
    
    sed -i "s/PROJECT_NAME/$1/g" CMakeLists.txt
    
    echo "✓ Created C++ project: $1"
    echo "Next steps:"
    echo "  cpp-build    # Build the project"
    echo "  nvim .       # Open in Neovim"
}

# Welcome message
echo "🎯 C++ Development Environment Ready!"
echo "💡 Try: cpp-init <project-name> to create a new C++ project"

# Basic completion (if available)
autoload -U compinit
if [[ -d ~/.zcompdump ]]; then
    compinit -d ~/.zcompdump
else
    compinit 2>/dev/null || true
fi
EOF

    print_success "Created simple zsh configuration"
else
    print_warning "zsh not available, will enhance bash instead"
fi

# Step 3: Create enhanced bash configuration as fallback
print_status "Step 3: Creating enhanced bash configuration..."

# Add enhanced bash configuration to .bashrc
cat >> "$HOME/.bashrc" << 'EOF'

# Enhanced Bash Configuration for C++ Development
# Clean, simple, and functional

# Better prompt with colors
if [[ "$TERM" != "dumb" ]]; then
    export PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
else
    export PS1='\u@\h:\w\$ '
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Aliases for C++ development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Development aliases
alias v='nvim'
alias vim='nvim'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# C++ specific aliases
alias cpp-debug='g++ -std=c++17 -Wall -Wextra -g -DDEBUG'
alias cpp-release='g++ -std=c++17 -Wall -Wextra -O2 -DNDEBUG'

# Quick navigation
alias cpp-test='cd ~/cpp-test-fixed'
alias dev='cd ~/cpp-nvim-env'

# Function to create C++ project (bash version)
cpp-init() {
    if [[ -z "$1" ]]; then
        echo "Usage: cpp-init <project-name>"
        return 1
    fi
    
    mkdir -p "$1"
    cd "$1"
    
    cat > main.cpp << 'EOFCPP'
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
EOFCPP
    
    cat > CMakeLists.txt << 'EOFCMAKE'
cmake_minimum_required(VERSION 3.10)
project(PROJECT_NAME)

set(CMAKE_CXX_STANDARD 17)
add_executable(main main.cpp)
EOFCMAKE
    
    sed -i "s/PROJECT_NAME/$1/g" CMakeLists.txt
    
    echo "✓ Created C++ project: $1"
    echo "Next steps:"
    echo "  cpp-build    # Build the project"
    echo "  nvim .       # Open in Neovim"
}

# Function to manually switch to zsh if desired
use-zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "Switching to zsh..."
        exec zsh
    else
        echo "zsh not available on this system"
    fi
}

# Welcome message
echo "🎯 Enhanced C++ Development Environment Ready!"
echo "💡 Commands: cpp-init <name>, v <file>, use-zsh"
EOF

print_success "Enhanced bash configuration added"

# Step 4: Remove/backup problematic Oh My Zsh installation
print_status "Step 4: Cleaning up problematic Oh My Zsh installation..."

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_status "Moving Oh My Zsh to backup location..."
    mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.backup.$(date +%s)"
    print_success "Oh My Zsh moved to backup"
fi

# Step 5: Create manual zsh switch option
print_status "Step 5: Creating manual shell switching options..."

# Create a simple script to test zsh
cat > "$HOME/.local/bin/test-zsh" << 'EOF'
#!/bin/bash
# Test if zsh works properly on this system

echo "Testing zsh compatibility..."

if ! command -v zsh >/dev/null 2>&1; then
    echo "❌ zsh not found"
    exit 1
fi

echo "✓ zsh found at: $(which zsh)"

# Test basic zsh functionality
if zsh -c 'echo "✓ zsh basic test passed"' 2>/dev/null; then
    echo "✓ zsh basic functionality works"
    echo ""
    echo "You can manually switch to zsh with:"
    echo "  zsh"
    echo ""
    echo "Or add to .bashrc:"
    echo "  echo 'exec zsh' >> ~/.bashrc"
    echo ""
    echo "Current shell: $SHELL"
else
    echo "❌ zsh has compatibility issues on this system"
    echo "Staying with enhanced bash is recommended"
fi
EOF

chmod +x "$HOME/.local/bin/test-zsh"

print_success "Created zsh testing utility"

print_success "🎉 Shell configuration fixed!"

echo ""
print_status "📋 WHAT WAS FIXED:"
echo "  ✓ Removed problematic Oh My Zsh auto-start that caused connection drops"
echo "  ✓ Created simple, working zsh configuration (without Oh My Zsh)"
echo "  ✓ Enhanced bash configuration as reliable fallback"
echo "  ✓ Moved broken Oh My Zsh installation to backup"
echo "  ✓ Added manual shell switching options"
echo ""
print_status "🚀 NEW FEATURES AVAILABLE:"
echo ""
print_status "In Bash (current default):"
echo "  • Enhanced prompt with colors"
echo "  • All C++ development aliases (v, gs, ga, etc.)"
echo "  • cpp-init <name> - Create new C++ projects"
echo "  • use-zsh - Manually switch to zsh if desired"
echo "  • test-zsh - Check if zsh works on this system"
echo ""
print_status "🔑 QUICK COMMANDS:"
echo "  cpp-init myproject   # Create new C++ project"
echo "  v .                  # Open current dir in Neovim"
echo "  gs                   # Git status"
echo "  test-zsh             # Test if zsh works"
echo "  use-zsh              # Switch to zsh manually"
echo ""
print_status "✅ WHAT TO DO NOW:"
echo "  1. Close this session: exit"
echo "  2. SSH back in (should work normally now)"
echo "  3. Try: cpp-init test-project"
echo "  4. Try: cd test-project && v ."
echo "  5. Optional: run 'test-zsh' to check zsh compatibility"
echo ""
print_success "Your shell should now work reliably without connection drops! 🎯"
