# Portable C++ Neovim Environment

A lightweight, powerful C++ development environment using Neovim that can be quickly deployed to any Linux system without sudo access.

## Features

🚀 **Full IDE Experience**
- **clangd** LSP for C++ intellisense (autocomplete, go-to-definition, diagnostics)
- **Telescope** for fuzzy finding and powerful search
- **Treesitter** for advanced syntax highlighting
- **Auto-completion** with context-aware suggestions

🔧 **Smart Build System**
- Auto-detects CMake, Makefile, Meson, or single files
- Generates `compile_commands.json` for perfect LSP integration
- Supports debug/release builds and parallel compilation
- Works with any C++ project structure

🎨 **Beautiful Interface**
- Modern Catppuccin color scheme
- File explorer with git integration
- Status line with project info
- Which-key for discovering keybindings

⚡ **Optimized for Remote Work**
- ~50MB total footprint
- No sudo required
- Works on any Linux x86_64 system
- Fast setup (2-3 minutes)

## Quick Setup

```bash
git clone https://github.com/YOUR_USERNAME/cpp-nvim-env.git
cd cpp-nvim-env
./setup.sh
source ~/.bashrc
```

## Usage

### Basic Commands
```bash
nvim .           # Open project in Neovim
cpp-build        # Build C++ project with LSP support
cpp-build --help # Show build options
```

### Essential Keybindings
- `<Space>` - Leader key
- `<Space>pf` - Find files (fuzzy finder)
- `<Space>pg` - Live grep search
- `<Space>e` - Toggle file explorer
- `gd` - Go to definition
- `K` - Show documentation
- `<Space>f` - Format code
- `gcc` - Comment/uncomment line

### C++ Development
- `<Space>cc` - Compile current file
- `<Space>cb` - Build entire project
- `]d` / `[d` - Navigate diagnostics
- `<Space>vca` - Code actions
- `<Space>vrr` - Find references
- `<Space>vrn` - Rename symbol

### File Navigation
- `<Space>pf` - Find files
- `<Space>pb` - Switch buffers
- `<Space>pr` - Recent files
- `Ctrl+h/j/k/l` - Navigate windows

### Git Integration
- `]c` / `[c` - Navigate git hunks
- `<Space>gs` - Stage hunk
- `<Space>gp` - Preview hunk
- `<Space>gb` - Git blame

## Project Examples

### CMake Project
```bash
mkdir my-cmake-project && cd my-cmake-project

# Create CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(MyProject)
set(CMAKE_CXX_STANDARD 17)
add_executable(main main.cpp)
EOF

# Create source file
cat > main.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
EOF

# Build and develop
cpp-build
nvim .
```

### Single File Project
```bash
mkdir simple-cpp && cd simple-cpp

cat > hello.cpp << 'EOF'
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    for (const auto& num : numbers) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
    return 0;
}
EOF

# Build and develop
cpp-build
nvim hello.cpp
```

## Build System Support

The `cpp-build` script automatically detects and supports:

- **CMake**: Looks for `CMakeLists.txt`
- **Makefile**: Uses existing `Makefile`
- **Meson**: Detects `meson.build`
- **Single files**: Compiles `*.cpp`, `*.c` files directly

### Build Options
```bash
cpp-build                    # Debug build
cpp-build --release          # Release build  
cpp-build --clean            # Clean and rebuild
cpp-build --verbose          # Verbose output
cpp-build --jobs 8           # Use 8 parallel jobs
cpp-build my-project --clean # Build specific directory
```

## Advanced Features

### LSP Health Check
```bash
nvim
:checkhealth lsp
```

### Plugin Management
Plugins auto-install on first launch. To manually manage:
```bash
nvim
:Lazy                        # Open plugin manager
:Lazy update                 # Update all plugins
:Lazy clean                  # Remove unused plugins
```

### Customization
Edit configuration files in `nvim/lua/`:
- `config/options.lua` - Editor settings
- `config/keymaps.lua` - Key bindings
- `plugins/` - Plugin configurations

## Troubleshooting

### LSP Not Working
```bash
# Check if clangd is installed
clangd --version

# Verify compile_commands.json exists
ls -la compile_commands.json

# Check LSP status in Neovim
nvim
:LspInfo
:LspRestart
```

### Tools Not Found
```bash
# Check if tools are in PATH
which nvim clangd rg fd

# Reload shell
source ~/.bashrc

# Re-run setup if needed
./setup.sh
```

### Build Issues
```bash
# Check for build dependencies
which g++ cmake make

# Clean build
cpp-build --clean --verbose

# Manual compilation test
g++ -std=c++17 -Wall -Wextra main.cpp -o main
```

## Requirements

- Linux x86_64
- git
- curl or wget
- Internet connection (for initial setup)
- C++ compiler (g++ recommended)

## What Gets Installed

All tools are installed to `~/.local/` (no sudo required):
- Neovim (latest AppImage)
- clangd (C++ language server)
- ripgrep (fast text search)
- fd (fast file finder)

Total footprint: ~50MB

## Updating

```bash
cd cpp-nvim-env
git pull origin main
./setup.sh  # Re-run if needed
```

## License

This configuration is provided as-is for educational and development purposes.
