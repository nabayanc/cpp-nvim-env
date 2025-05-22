#!/bin/bash
# Deploy and Sync Script
# Commits all changes and prepares for deployment to other SSH nodes

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[DEPLOY]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "🚀 Preparing to deploy C++ development environment..."

# Step 1: Ensure we're in the right directory
if [[ ! -f "setup.sh" || ! -d "nvim" ]]; then
    print_error "Please run this script from the cpp-nvim-env directory"
    exit 1
fi

print_status "Working directory: $SCRIPT_DIR"

# Step 2: Create shell-configs backup directory
print_status "Step 1: Backing up current shell configurations..."
mkdir -p shell-configs

# Backup current working configurations
if [[ -f "$HOME/.bashrc" ]]; then
    cp "$HOME/.bashrc" shell-configs/bashrc-working
    print_success "Backed up working .bashrc"
fi

if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" shell-configs/zshrc-working
    print_success "Backed up working .zshrc"
fi

# Step 3: Create deployment documentation
print_status "Step 2: Creating deployment documentation..."

cat > DEPLOYMENT.md << 'EOF'
# C++ Development Environment - Deployment Guide

## Quick Deployment to New SSH Node

### One-Command Setup
```bash
git clone https://github.com/YOUR_USERNAME/cpp-nvim-env.git
cd cpp-nvim-env
./quick-deploy.sh
```

### Manual Setup Process
```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/cpp-nvim-env.git
cd cpp-nvim-env

# 2. Run main setup (installs tools)
./setup.sh

# 3. Apply shell enhancements
./restore-shell-features.sh

# 4. Activate new shell
source ~/.bashrc
# Or for zsh: zsh

# 5. Test the environment
cpp-init test-project
cd test-project
nvim .
```

## What Gets Installed

### Development Tools
- **Neovim 0.9.5** (compatible with university systems)
- **clangd** (C++ language server)
- **ripgrep** (fast text search)
- **fd** (fast file finder)
- **cpp-build** (smart build helper)

### Neovim IDE Features
- **File explorer** (VSCode-like sidebar)
- **Fuzzy finder** (Telescope)
- **Syntax highlighting** (Treesitter)
- **Auto-completion** (LSP integration)
- **Git integration** (gitsigns)
- **Beautiful theme** (Catppuccin)
- **Tab bar** (buffer navigation)
- **Status line** (project info)

### Shell Enhancements
- **Beautiful prompts** (multi-line with git status)
- **Smart aliases** (development shortcuts)
- **Project creation** (cpp-init command)
- **Enhanced navigation** (auto-ls on cd)
- **Git integration** (branch/status in prompt)

## File Structure
```
cpp-nvim-env/
├── setup.sh                    # Main tool installation
├── complete-fix.sh             # Complete environment setup
├── restore-shell-features.sh   # Shell enhancement script
├── nvim/                       # Neovim configuration
│   ├── init.lua                # Main config
│   └── lua/
│       ├── config/             # Core settings
│       └── plugins/            # Plugin configurations
├── shell-configs/              # Shell configuration backups
└── docs/                       # Documentation
```

## Troubleshooting

### If LSP doesn't work
```bash
# Check clangd installation
clangd --version

# Verify compile_commands.json exists
cd your-project
cpp-build
ls -la compile_commands.json

# Check LSP in Neovim
nvim main.cpp
:LspInfo
```

### If shell features are missing
```bash
# Reload shell configuration
source ~/.bashrc

# Or re-run shell setup
./restore-shell-features.sh
```

### If Neovim has plugin issues
```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim/lazy/
rm -rf ~/.local/state/nvim/

# Restart Neovim (plugins will reinstall)
nvim
```
EOF

# Step 4: Create quick deployment script for other nodes
print_status "Step 3: Creating quick deployment script..."

cat > quick-deploy.sh << 'EOF'
#!/bin/bash
# Quick Deployment Script for New SSH Nodes
# Run this after cloning the repository

set -e

echo "🚀 Quick deployment starting..."

# Check system compatibility
echo "📋 System check:"
echo "  OS: $(uname -s)"
echo "  Architecture: $(uname -m)"
echo "  User: $(whoami)"
echo "  Home: $HOME"
echo ""

# Run main setup
echo "🔧 Installing development tools..."
if [[ -f "setup.sh" ]]; then
    chmod +x setup.sh
    ./setup.sh
else
    echo "❌ setup.sh not found!"
    exit 1
fi

# Apply shell enhancements
echo "🎨 Enhancing shell..."
if [[ -f "restore-shell-features.sh" ]]; then
    chmod +x restore-shell-features.sh
    ./restore-shell-features.sh
else
    echo "❌ restore-shell-features.sh not found!"
    exit 1
fi

echo ""
echo "✅ Quick deployment complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Close terminal and SSH back in"
echo "  2. Try: cpp-init my-project"
echo "  3. Try: cd my-project && nvim ."
echo ""
echo "📚 See REFERENCE.md for all commands and shortcuts"
EOF

chmod +x quick-deploy.sh

# Step 5: Check git status and prepare commit
print_status "Step 4: Preparing git commit..."

# Initialize git if not already done
if [[ ! -d ".git" ]]; then
    print_status "Initializing git repository..."
    git init
    
    # Create .gitignore if it doesn't exist
    if [[ ! -f ".gitignore" ]]; then
        cat > .gitignore << 'EOF'
# Backup files
*.backup.*
*~
*.swp
*.swo

# Compiled binaries
build/
*.o
*.so
*.a
main
a.out

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Shell history and cache
.zsh_history
.bash_history
.zcompdump*

# Neovim runtime files (will be generated)
.local/share/nvim/
.local/state/nvim/
.cache/nvim/
EOF
    fi
fi

# Add all files
print_status "Adding files to git..."
git add .

# Show what will be committed
print_status "Files to be committed:"
git status --porcelain

# Step 6: Create commit with comprehensive message
print_status "Step 5: Creating comprehensive commit..."

COMMIT_MSG="Complete C++ Development Environment Setup

🎯 Features included:
- Portable Neovim 0.9.5 with LSP integration
- clangd C++ language server with full IntelliSense
- VSCode-like UI with file explorer and tabs
- Beautiful shell with git integration
- Smart project creation (cpp-init command)
- Cross-platform compatibility (no sudo required)

🔧 Tools installed:
- Neovim (latest compatible version)
- clangd (C++ language server)
- ripgrep (fast search)
- fd (fast file finder)
- Telescope (fuzzy finder)
- Treesitter (syntax highlighting)
- Auto-completion and diagnostics

🎨 UI enhancements:
- File explorer (auto-opens, VSCode-like)
- Tab bar with buffer navigation
- Catppuccin theme
- Enhanced status line
- Git signs and diff integration

🐚 Shell improvements:
- Multi-line colored prompts
- Git branch/status in prompt
- Development aliases and functions
- Smart navigation and completion
- Project creation workflows

📦 Deployment:
- One-command setup: ./quick-deploy.sh
- Works on university/enterprise systems
- No system package dependencies
- Portable across SSH nodes

🔑 Usage:
- cpp-init <project> - Create C++ project
- nvim . - Open VSCode-like IDE
- All standard development workflows

Compatible with systems having glibc 2.17+ and basic development tools."

git commit -m "$COMMIT_MSG"

print_success "Comprehensive commit created!"

# Step 7: Show deployment instructions
print_status "Step 6: Deployment instructions..."

echo ""
print_success "🎉 Repository ready for deployment!"
echo ""
print_status "📤 TO PUSH TO GITHUB:"
echo "  1. Create repository on GitHub: https://github.com/new"
echo "  2. Run these commands:"
echo "     git remote add origin https://github.com/YOUR_USERNAME/cpp-nvim-env.git"
echo "     git branch -M main"
echo "     git push -u origin main"
echo ""
print_status "🚀 TO DEPLOY TO OTHER SSH NODES:"
echo "  # On any new SSH node:"
echo "  git clone https://github.com/YOUR_USERNAME/cpp-nvim-env.git"
echo "  cd cpp-nvim-env"
echo "  ./quick-deploy.sh"
echo ""
print_status "⚡ QUICK TEST AFTER DEPLOYMENT:"
echo "  cpp-init test-project"
echo "  cd test-project"
echo "  nvim ."
echo ""
print_status "📋 FILES INCLUDED IN REPOSITORY:"
find . -name ".git" -prune -o -type f -print | sort | head -20
echo "  ... and more"
echo ""
print_warning "🔄 UPDATE YOUR GITHUB USERNAME in the commands above!"
print_success "Your development environment is ready for world-wide deployment! 🌍"
EOF

chmod +x deploy-and-sync.sh

# Create comprehensive reference guide
cat > REFERENCE.md << 'EOF'
# C++ Development Environment - Complete Reference Guide

## 🚀 Quick Start Commands

```bash
# Create new C++ project
cpp-init my-project

# Create C++ project with git
git-init-cpp my-project

# Build and run project
cpp-run

# Open project in IDE
nvim .
```

## 🐚 Shell Commands & Aliases

### Project Management
| Command | Description |
|---------|-------------|
| `cpp-init <name>` | Create new C++ project with CMake |
| `git-init-cpp <name>` | Create C++ project + initialize git |
| `cpp-run` | Build and run current project |
| `cpp-build` | Build project with LSP support |
| `cpp-debug` | Compile with debug flags |
| `cpp-release` | Compile with release flags |

### Navigation & Files
| Command | Description |
|---------|-------------|
| `v <file>` | Open file in Neovim |
| `ll` | Detailed file listing |
| `la` | List all files (including hidden) |
| `..` | Go up one directory |
| `...` | Go up two directories |
| `projects` | Jump to projects directory |
| `dev` | Jump to cpp-nvim-env directory |
| `cpp-test` | Jump to test directory |

### Git Shortcuts
| Command | Description |
|---------|-------------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph` |
| `gd` | `git diff` |
| `gb` | `git branch` |
| `gco` | `git checkout` |

### System & Utilities
| Command | Description |
|---------|-------------|
| `cls` | Clear screen |
| `h` | Show history |
| `df` | Disk usage (human readable) |
| `free` | Memory usage (human readable) |
| `extract <file>` | Extract any archive type |
| `switch-shell` | Switch between bash/zsh |

## 🎮 Neovim Keybindings

### File Management
| Key | Action |
|-----|--------|
| `<Space>e` | Toggle file explorer |
| `<Space>ef` | Find current file in explorer |
| `<Space>er` | Refresh file explorer |
| `<Space>w` | Save file |
| `<Space>q` | Quit |
| `<Space>x` | Save and quit |

### File Explorer (NvimTree)
| Key | Action |
|-----|--------|
| `Enter` | Open file/folder |
| `a` | Create new file |
| `A` | Create new folder |
| `d` | Delete file/folder |
| `r` | Rename file/folder |
| `x` | Cut file |
| `c` | Copy file |
| `p` | Paste file |
| `y` | Copy filename |
| `Y` | Copy relative path |
| `gy` | Copy absolute path |

### Fuzzy Finding (Telescope)
| Key | Action |
|-----|--------|
| `<Space>pf` | Find files |
| `<Space>pg` | Live grep (search in files) |
| `<Space>pb` | Find buffers |
| `<Space>ph` | Help tags |
| `<Space>pr` | Recent files |
| `<Space>ps` | Grep string |

### Buffer/Tab Management
| Key | Action |
|-----|--------|
| `<Ctrl-Tab>` | Next tab |
| `<Ctrl-Shift-Tab>` | Previous tab |
| `<Space>bd` | Close buffer/tab |
| `<Space>bD` | Force close buffer |
| `<Space>1-9` | Jump to buffer 1-9 |
| `<Shift-l>` | Next buffer |
| `<Shift-h>` | Previous buffer |

### Window Navigation
| Key | Action |
|-----|--------|
| `<Ctrl-h>` | Go to left window |
| `<Ctrl-j>` | Go to lower window |
| `<Ctrl-k>` | Go to upper window |
| `<Ctrl-l>` | Go to right window |
| `<Space>sv` | Split vertically |
| `<Space>sh` | Split horizontally |
| `<Space>sx` | Close current split |

### LSP Features (C++ IntelliSense)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Show hover documentation |
| `<Ctrl-k>` | Show signature help |
| `<Space>rn` | Rename symbol |
| `<Space>ca` | Code actions |
| `<Space>f` | Format code |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `<Space>d` | Show diagnostic |

### Code Editing
| Key | Action |
|-----|--------|
| `gcc` | Comment/uncomment line |
| `gc` | Comment/uncomment selection |
| `<Space>h` | Clear search highlights |
| `<Space>sr` | Search and replace |
| `<Ctrl-d>` | Scroll down (centered) |
| `<Ctrl-u>` | Scroll up (centered) |

### Git Integration
| Key | Action |
|-----|--------|
| `]c` | Next git hunk |
| `[c` | Previous git hunk |
| `<Space>gs` | Stage hunk |
| `<Space>gr` | Reset hunk |
| `<Space>gp` | Preview hunk |
| `<Space>gb` | Git blame line |

### Terminal Integration
| Key | Action |
|-----|--------|
| `<Space>tt` | Open terminal |
| `<Esc>` | Exit terminal mode |

### Insert Mode Shortcuts
| Key | Action |
|-----|--------|
| `jk` | Exit to normal mode |
| `kj` | Exit to normal mode |

## 🔧 Development Workflow

### Starting a New Project
```bash
# 1. Create project
cpp-init awesome-game

# 2. Navigate to project
cd awesome-game

# 3. Open in IDE
nvim .

# 4. In Neovim file explorer (left side):
#    - Press 'a' to create new files
#    - Edit main.cpp
#    - Add more source files

# 5. Build project
#    - In nvim: <Space>tt (open terminal)
#    - Run: cpp-build

# 6. Run program
#    - Run: ./main
```

### Working with Existing Projects
```bash
# 1. Clone or navigate to project
cd my-existing-project

# 2. Generate LSP support
cpp-build

# 3. Open in IDE
nvim .

# 4. Features available:
#    - File explorer on left
#    - Go to definition (gd)
#    - Auto-completion
#    - Error diagnostics
#    - Git integration
```

### Multi-file C++ Projects
```bash
# 1. Create project structure
cpp-init my-library
cd my-library

# 2. In Neovim:
#    - Press <Space>e (toggle explorer)
#    - Press 'a' to create: src/math.cpp
#    - Press 'a' to create: include/math.h
#    - Edit CMakeLists.txt to include new files

# 3. Build and test
cpp-build
```

## 🎨 UI Customization

### Changing Theme
```bash
# Edit Neovim config
nvim ~/.config/nvim/lua/plugins/ui.lua

# Available themes:
# - catppuccin-mocha (current)
# - catppuccin-frappe
# - catppuccin-macchiato
# - catppuccin-latte
```

### File Explorer Settings
| Setting | Key in Explorer |
|---------|-----------------|
| Show hidden files | `H` |
| Show git ignored | `I` |
| Collapse all | `W` |
| Expand all | `E` |

## 🚨 Troubleshooting

### LSP Not Working
```bash
# Check clangd installation
clangd --version

# Check LSP status in Neovim
nvim main.cpp
:LspInfo

# Regenerate compile commands
cpp-build

# Restart LSP
:LspRestart
```

### Plugin Issues
```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim/lazy/

# Restart Neovim (plugins reinstall automatically)
nvim
```

### Shell Issues
```bash
# Reload shell configuration
source ~/.bashrc

# Re-run shell setup
./restore-shell-features.sh
```

## 📦 Advanced Features

### Custom Build Configurations
```bash
# Debug build
cpp-build --debug

# Release build  
cpp-build --release

# Clean build
cpp-build --clean

# Verbose build
cpp-build --verbose
```

### Git Workflow Integration
```bash
# Create project with git
git-init-cpp my-project

# In Neovim, git status shown in:
# - File explorer (file colors)
# - Status line
# - Git signs in gutter
```

### Cross-Node Deployment
```bash
# On source node (where you developed)
cd cpp-nvim-env
git add .
git commit -m "Update environment"
git push

# On target node
git clone https://github.com/username/cpp-nvim-env.git
cd cpp-nvim-env
./quick-deploy.sh
```

## 🎯 Pro Tips

1. **Quick project creation**: `cpp-init project && cd project && nvim .`
2. **Fast file navigation**: Use `<Space>pf` more than file explorer
3. **Multi-cursor editing**: Select text, then `<Space>rn` to rename all
4. **Terminal workflow**: Keep terminal split open with `<Space>sh` then `<Space>tt`
5. **Git staging**: Use `<Space>gs` to stage hunks visually
6. **Quick documentation**: Hover over any C++ symbol and press `K`
7. **Code formatting**: Set up auto-format on save (already configured)
8. **Cross-file navigation**: `gd` works across files in your project

---

*This environment provides a complete, portable C++ development experience that rivals any modern IDE while working reliably on university and enterprise systems.*
EOF

print_success "Created complete reference guide!"

# Run the deployment script
./deploy-and-sync.sh
