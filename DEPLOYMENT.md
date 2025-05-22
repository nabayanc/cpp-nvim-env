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
