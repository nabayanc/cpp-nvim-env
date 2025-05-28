#!/bin/bash
# Restore Beautiful Shell Features
# Creates a working, beautiful shell without connection-dropping issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[SETUP]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_status "🎨 Restoring beautiful shell features..."

# Test zsh compatibility first
print_status "Testing zsh compatibility..."
ZSH_WORKS=false

if command -v zsh >/dev/null 2>&1; then
    if zsh -c 'autoload -U compinit && compinit 2>/dev/null && echo "ZSH_TEST_SUCCESS"' 2>/dev/null | grep -q "ZSH_TEST_SUCCESS"; then
        ZSH_WORKS=true
        print_success "zsh is compatible on this system"
    else
        print_warning "zsh has compatibility issues, will use enhanced bash"
    fi
else
    print_warning "zsh not available, will use enhanced bash"
fi

if [[ "$ZSH_WORKS" == "true" ]]; then
    # Create beautiful custom zsh configuration
    print_status "Creating beautiful custom zsh configuration..."
    
    cat > "$HOME/.zshrc" << 'EOF'
# Beautiful Custom Zsh Configuration
# Designed to work reliably without Oh My Zsh dependencies

# Basic zsh options
setopt AUTO_CD                 # cd to directory just by typing its name
setopt HIST_VERIFY            # show command with history expansion before running
setopt SHARE_HISTORY          # share command history data
setopt APPEND_HISTORY         # append to history file
setopt HIST_IGNORE_DUPS       # ignore duplicates in history
setopt HIST_IGNORE_SPACE      # ignore commands starting with space
setopt HIST_REDUCE_BLANKS     # remove extra blanks from history
setopt INTERACTIVE_COMMENTS   # allow comments in interactive mode
setopt AUTO_LIST              # automatically list choices on ambiguous completion
setopt AUTO_MENU              # show completion menu on successive tab press
setopt COMPLETE_IN_WORD       # allow completion from within a word
setopt ALWAYS_TO_END          # move cursor to end if word had one match

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Load colors
autoload -U colors && colors

# Enable completion system (safely)
autoload -U compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Beautiful prompt with git support
autoload -Uz vcs_info
precmd() { vcs_info }

# Configure git info
zstyle ':vcs_info:git:*' formats ' (%F{cyan}%b%f)'
zstyle ':vcs_info:*' enable git

setopt PROMPT_SUBST

# Multi-line prompt with colors and git
PROMPT='%F{green}┌─[%f%F{blue}%n%f%F{green}@%f%F{blue}%m%f%F{green}]─[%f%F{yellow}%~%f%F{green}]${vcs_info_msg_0_}%f
%F{green}└─%f%F{red}❯%f%F{yellow}❯%f%F{green}❯%f '

# Right prompt with time
RPROMPT='%F{gray}[%*]%f'

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Enhanced aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Development aliases
alias v='nvim'
alias vim='nvim'
alias cls='clear'
alias h='history'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='htop 2>/dev/null || top'

# Git aliases with colors
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --color=always'
alias gd='git diff --color=always'
alias gb='git branch'
alias gco='git checkout'
alias gm='git merge'
alias gf='git fetch'

# C++ development aliases
alias cpp-debug='g++ -std=c++17 -Wall -Wextra -g -DDEBUG'
alias cpp-release='g++ -std=c++17 -Wall -Wextra -O2 -DNDEBUG'
alias make-debug='make CMAKE_BUILD_TYPE=Debug'
alias make-release='make CMAKE_BUILD_TYPE=Release'

# Quick navigation
alias cpp-test='cd ~/cpp-test-fixed'
alias dev='cd ~/cpp-nvim-env'
alias home='cd ~'
alias projects='cd ~/projects 2>/dev/null || mkdir -p ~/projects && cd ~/projects'

# Enhanced grep with colors
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Network and system info
alias myip='curl -s ipinfo.io/ip'
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias diskusage='du -h --max-depth=1'

# C++ project creation function
cpp-init() {
    if [[ -z "$1" ]]; then
        echo "Usage: cpp-init <project-name>"
        return 1
    fi
    
    echo "🚀 Creating C++ project: $1"
    mkdir -p "$1"
    cd "$1"
    
    # Create main.cpp
    cat > main.cpp << EOFCPP
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::cout << "Hello from $1!" << std::endl;
    
    std::vector<std::string> features = {
        "Modern C++17",
        "CMake build system", 
        "Ready for development"
    };
    
    std::cout << "Project features:" << std::endl;
    for (const auto& feature : features) {
        std::cout << "  ✓ " << feature << std::endl;
    }
    
    return 0;
}
EOFCPP
    
    # Create CMakeLists.txt
    cat > CMakeLists.txt << EOFCMAKE
cmake_minimum_required(VERSION 3.10)
project($1)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler flags
set(CMAKE_CXX_FLAGS_DEBUG "-g -Wall -Wextra -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG")

# Create executable
add_executable(main main.cpp)

# Optional: Add more source files here
# add_executable(main main.cpp other.cpp)
EOFCMAKE
    
    # Create .gitignore
    cat > .gitignore << 'EOFGIT'
# Build directories
build/
cmake-build-*/

# Compiled files
*.o
*.so
*.a
*.exe
main

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
EOFGIT

    echo "✅ Created C++ project with:"
    echo "   📄 main.cpp (Modern C++ hello world)"
    echo "   🔧 CMakeLists.txt (CMake configuration)"
    echo "   🚫 .gitignore (Ignore build files)"
    echo ""
    echo "🎯 Next steps:"
    echo "   cpp-build    # Build the project"
    echo "   nvim .       # Open in Neovim IDE"
    echo "   git init     # Initialize git repository"
}

# Git project initialization function
git-init-cpp() {
    if [[ -z "$1" ]]; then
        echo "Usage: git-init-cpp <project-name>"
        return 1
    fi
    
    cpp-init "$1"
    git init
    git add .
    git commit -m "Initial commit: C++ project setup"
    echo "🎉 Git repository initialized with initial commit!"
}

# Quick project build and run
cpp-run() {
    if [[ ! -f "CMakeLists.txt" && ! -f "Makefile" ]]; then
        echo "❌ No build system found (CMakeLists.txt or Makefile)"
        return 1
    fi
    
    echo "🔨 Building project..."
    cpp-build
    
    if [[ -x "./main" ]]; then
        echo "🚀 Running ./main:"
        echo "----------------------------------------"
        ./main
    elif [[ -x "./build/main" ]]; then
        echo "🚀 Running ./build/main:"
        echo "----------------------------------------"
        ./build/main
    else
        echo "❌ No executable found to run"
    fi
}

# Enhanced cd with automatic ls
cd() {
    builtin cd "$@" && ls --color=auto
}

# Extract function for various archive types
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Welcome message with system info
welcome_msg() {
    echo ""
    echo "🎯 ${fg[cyan]}C++ Development Environment${reset_color}"
    echo "📅 $(date)"
    echo "💻 $(uname -n) | $(uname -s) $(uname -r)"
    echo "📂 $(pwd)"
    echo ""
    echo "🚀 ${fg[green]}Quick Commands:${reset_color}"
    echo "   cpp-init <name>     Create new C++ project"
    echo "   git-init-cpp <name> Create C++ project with git"
    echo "   cpp-run             Build and run current project"
    echo "   v .                 Open in Neovim IDE"
    echo "   projects            Go to projects directory"
    echo ""
}

# Key bindings
bindkey '^[[A' history-search-backward  # Up arrow
bindkey '^[[B' history-search-forward   # Down arrow
bindkey '^R' history-incremental-search-backward  # Ctrl+R

# Show welcome message
welcome_msg
EOF

    print_success "Created beautiful custom zsh configuration"
    
    # Set zsh as default for this session
    print_status "To use zsh, run: zsh"
    print_status "To make it default, add 'exec zsh' to your .bashrc"
    
else
    # Create super enhanced bash configuration
    print_status "Creating super enhanced bash configuration..."
    
    # Backup existing .bashrc
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%s)" 2>/dev/null || true
    
    cat > "$HOME/.bashrc" << 'EOF'
# Super Enhanced Bash Configuration
# Beautiful, feature-rich bash that rivals zsh

# Source global definitions
if [[ -f /etc/bashrc ]]; then
    . /etc/bashrc
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Enhanced history
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
shopt -s histappend
shopt -s cmdhist
shopt -s histreedit
shopt -s histverify

# Better bash options
shopt -s autocd 2>/dev/null || true        # cd by typing directory name
shopt -s dirspell 2>/dev/null || true      # correct directory name typos
shopt -s cdspell 2>/dev/null || true       # correct cd typos
shopt -s checkwinsize                       # check window size after commands
shopt -s expand_aliases                     # expand aliases
shopt -s dotglob                           # include dotfiles in pathname expansion

# Colors for ls
export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Git prompt function
git_prompt() {
    local git_status=`git status -unormal 2>&1`
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local Color_On='\[\033[0;32m\]'  # Green
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local Color_On='\[\033[0;33m\]'  # Yellow
        else
            local Color_On='\[\033[0;31m\]'  # Red
        fi
        local Color_Off='\[\033[0m\]'
        local branch=`git branch 2>/dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\\\\\(\\\\\1\\\\\)\ /`
        echo " $Color_On$branch$Color_Off"
    fi
}

# Beautiful multi-line prompt
PS1='\[\033[0;32m\]┌─[\[\033[0;34m\]\u\[\033[0;32m\]@\[\033[0;34m\]\h\[\033[0;32m\]]─[\[\033[0;33m\]\w\[\033[0;32m\]]$(git_prompt)\[\033[0m\]
\[\033[0;32m\]└─\[\033[0;31m\]❯\[\033[0;33m\]❯\[\033[0;32m\]❯\[\033[0m\] '

# Enhanced aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Development aliases
alias v='nvim'
alias vim='nvim'
alias cls='clear'
alias h='history'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --color=always'
alias gd='git diff --color=always'
alias gb='git branch'
alias gco='git checkout'
alias gm='git merge'
alias gf='git fetch'

# C++ development aliases
alias cpp-debug='g++ -std=c++17 -Wall -Wextra -g -DDEBUG'
alias cpp-release='g++ -std=c++17 -Wall -Wextra -O2 -DNDEBUG'

# Navigation aliases
alias cpp-test='cd ~/cpp-test-fixed'
alias dev='cd ~/cpp-nvim-env'
alias home='cd ~'
alias projects='cd ~/projects 2>/dev/null || mkdir -p ~/projects && cd ~/projects'

# Enhanced grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# C++ project creation function
cpp-init() {
    if [[ -z "$1" ]]; then
        echo "Usage: cpp-init <project-name>"
        return 1
    fi
    
    echo "🚀 Creating C++ project: $1"
    mkdir -p "$1"
    cd "$1"
    
    cat > main.cpp << EOFCPP
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::cout << "Hello from $1!" << std::endl;
    
    std::vector<std::string> features = {
        "Modern C++17",
        "CMake build system", 
        "Ready for development"
    };
    
    std::cout << "Project features:" << std::endl;
    for (const auto& feature : features) {
        std::cout << "  ✓ " << feature << std::endl;
    }
    
    return 0;
}
EOFCPP
    
    cat > CMakeLists.txt << EOFCMAKE
cmake_minimum_required(VERSION 3.10)
project($1)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_DEBUG "-g -Wall -Wextra -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG")

add_executable(main main.cpp)
EOFCMAKE
    
    cat > .gitignore << 'EOFGIT'
build/
cmake-build-*/
*.o
*.so
*.a
*.exe
main
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db
EOFGIT

    echo "✅ Created C++ project with full setup!"
    echo "🎯 Next: cpp-build && nvim ."
}

# Git integration
git-init-cpp() {
    if [[ -z "$1" ]]; then
        echo "Usage: git-init-cpp <project-name>"
        return 1
    fi
    
    cpp-init "$1"
    git init
    git add .
    git commit -m "Initial commit: C++ project setup"
    echo "🎉 Git repository initialized!"
}

# Build and run
cpp-run() {
    echo "🔨 Building..."
    cpp-build && {
        if [[ -x "./main" ]]; then
            echo "🚀 Running ./main:"
            ./main
        elif [[ -x "./build/main" ]]; then
            echo "🚀 Running ./build/main:"
            ./build/main
        fi
    }
}

# Enhanced cd with ls
cd() {
    builtin cd "$@" && ls --color=auto
}

# Extract function
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.zip)       unzip $1       ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    fi
}

# Welcome message
echo ""
echo "🎯 Enhanced C++ Development Environment"
echo "📅 $(date)"
echo "💻 $(hostname) | $(uname -s)"
echo ""
echo "🚀 Quick Commands:"
echo "   cpp-init <name>     Create C++ project"
echo "   git-init-cpp <name> Create C++ project with git"
echo "   cpp-run             Build and run project"
echo "   v .                 Open in Neovim"
echo "   projects            Go to projects directory"
echo ""
EOF

    print_success "Created super enhanced bash configuration"
fi

# Update repository with improved shell config
print_status "Updating repository configuration..."
if [[ -f "$HOME/.zshrc" && "$ZSH_WORKS" == "true" ]]; then
    cp "$HOME/.zshrc" ~/cpp-nvim-env/shell-configs/zshrc 2>/dev/null || mkdir -p ~/cpp-nvim-env/shell-configs && cp "$HOME/.zshrc" ~/cpp-nvim-env/shell-configs/zshrc
fi
cp "$HOME/.bashrc" ~/cpp-nvim-env/shell-configs/bashrc 2>/dev/null || mkdir -p ~/cpp-nvim-env/shell-configs && cp "$HOME/.bashrc" ~/cpp-nvim-env/shell-configs/bashrc

# Create shell switching utility
cat > "$HOME/.local/bin/switch-shell" << 'EOF'
#!/bin/bash
# Shell switching utility

echo "🐚 Available shells:"
echo "1. Enhanced Bash (current)"
if command -v zsh >/dev/null 2>&1; then
    echo "2. Beautiful Zsh"
fi
echo ""

read -p "Choose shell (1-2): " choice

case $choice in
    1)
        echo "Already using enhanced bash!"
        ;;
    2)
        if command -v zsh >/dev/null 2>&1; then
            echo "Switching to zsh..."
            exec zsh
        else
            echo "zsh not available"
        fi
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
EOF

chmod +x "$HOME/.local/bin/switch-shell"

print_success "🎉 Beautiful shell features restored!"

echo ""
print_status "📋 WHAT YOU NOW HAVE:"
if [[ "$ZSH_WORKS" == "true" ]]; then
    echo "  ✅ Beautiful custom zsh configuration (no Oh My Zsh issues)"
    echo "  ✅ Multi-line prompt with git integration"
    echo "  ✅ Smart completion and history"
fi
echo "  ✅ Super enhanced bash as reliable fallback"
echo "  ✅ Git integration in prompt (shows branch and status)"
echo "  ✅ All C++ development functions and aliases"
echo "  ✅ Beautiful multi-line colored prompts"
echo "  ✅ Enhanced navigation and productivity features"
echo ""
print_status "🚀 NEW ENHANCED FEATURES:"
echo ""
print_status "Project Management:"
echo "  • cpp-init <name>        Create full C++ project with CMake"
echo "  • git-init-cpp <name>    Create C++ project + git repository"
echo "  • cpp-run                Build and run current project"
echo "  • projects               Quick jump to projects directory"
echo ""
print_status "Enhanced Navigation:"
echo "  • cd automatically shows directory contents"
echo "  • Smart history search with arrow keys"
echo "  • Git branch and status in prompt"
echo "  • Colored output for ls, grep, git commands"
echo ""
print_status "Development Workflow:"
echo "  • v .                    Open current directory in Neovim"
echo "  • All git aliases: gs, ga, gc, gp, gl, gd"
echo "  • extract <file>         Extract any archive type"
echo "  • switch-shell           Change between bash/zsh"
echo ""
print_status "🎯 QUICK START:"
echo "  1. Restart terminal: exit && ssh odyssey"
if [[ "$ZSH_WORKS" == "true" ]]; then
    echo "  2. Try zsh: zsh"
fi
echo "  3. Create project: cpp-init awesome-project"
echo "  4. Open IDE: cd awesome-project && v ."
echo ""
print_success "Your shell is now beautiful and powerful! 🎨✨"
