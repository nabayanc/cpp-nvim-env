#!/bin/bash
# Enhancement Script: Oh My Zsh + VSCode-like Neovim UI
# Run from cpp-nvim-env directory

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[ENHANCE]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "🚀 Enhancing your development environment..."

# Part 1: Install and configure Oh My Zsh
print_status "Part 1: Setting up Oh My Zsh..."

# Check if zsh is available
if ! command -v zsh >/dev/null 2>&1; then
    print_warning "zsh not found on system. Checking if we can install it..."
    if command -v module >/dev/null 2>&1; then
        print_status "Trying to load zsh module..."
        module load zsh 2>/dev/null || print_warning "No zsh module available"
    fi
    
    if ! command -v zsh >/dev/null 2>&1; then
        print_error "zsh not available. Will configure bash with zsh-like features instead."
        USE_BASH_ENHANCED=true
    else
        USE_BASH_ENHANCED=false
    fi
else
    USE_BASH_ENHANCED=false
    print_success "zsh found: $(which zsh)"
fi

if [[ "$USE_BASH_ENHANCED" == "false" ]]; then
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        
        # Download and install Oh My Zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        
        print_success "Oh My Zsh installed"
    else
        print_success "Oh My Zsh already installed"
    fi

    # Configure Oh My Zsh
    print_status "Configuring Oh My Zsh..."

    # Backup existing .zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
    fi

    # Create enhanced .zshrc
    cat > "$HOME/.zshrc" << 'EOF'
# Oh My Zsh Configuration for C++ Development

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - you can change this to any theme you like
ZSH_THEME="agnoster"  # Clean, informative theme
# Other good options: "robbyrussell", "powerlevel10k/powerlevel10k", "spaceship"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    command-not-found
    cp
    extract
    z
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# C++ development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# C++ specific aliases
alias cpp-new='mkdir -p build && cd build && cmake .. && make'
alias cpp-clean='rm -rf build && mkdir build'
alias cpp-debug='g++ -std=c++17 -Wall -Wextra -g -DDEBUG'
alias cpp-release='g++ -std=c++17 -Wall -Wextra -O2 -DNDEBUG'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Development aliases
alias v='nvim'
alias vim='nvim'
alias cls='clear'
alias h='history'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Quick navigation
alias projects='cd ~/projects 2>/dev/null || cd ~'
alias cpp-test='cd ~/cpp-test-fixed'
alias dev='cd ~/cpp-nvim-env'

# Function to create and build C++ project
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
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(main main.cpp)
EOFCMAKE
    
    sed -i "s/PROJECT_NAME/$1/g" CMakeLists.txt
    
    echo "✓ Created C++ project: $1"
    echo "  - main.cpp (basic hello world)"
    echo "  - CMakeLists.txt (CMake configuration)"
    echo ""
    echo "Next steps:"
    echo "  cpp-build    # Build the project"
    echo "  nvim .       # Open in Neovim"
}

# Welcome message
echo "🎯 C++ Development Environment Ready!"
echo "💡 Try: cpp-init <project-name> to create a new C++ project"

# Enable autosuggestions and syntax highlighting
if [[ -d "$ZSH/plugins/zsh-autosuggestions" ]]; then
    source "$ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -d "$ZSH/plugins/zsh-syntax-highlighting" ]]; then
    source "$ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOF

    # Install popular zsh plugins
    print_status "Installing zsh plugins..."
    
    # zsh-autosuggestions
    if [[ ! -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"
    fi

    print_success "Oh My Zsh configured with plugins"

    # Configure shell switching
    print_status "Configuring automatic zsh startup..."
    
    # Add zsh auto-start to .bashrc
    if ! grep -q "# Auto-start zsh" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'EOF'

# Auto-start zsh with Oh My Zsh
if [[ -t 1 && -x "$(command -v zsh)" && "$SHELL" != "$(which zsh)" ]]; then
    # Only auto-switch if we're in an interactive terminal
    # and not already in zsh, and not in a specific environment
    if [[ -z "$ZSH_AUTO_STARTED" && -z "$NVIM" && -z "$INSIDE_EMACS" ]]; then
        export ZSH_AUTO_STARTED=1
        exec zsh
    fi
fi
EOF
        print_success "Added zsh auto-start to .bashrc"
    fi

else
    # Enhanced bash configuration if zsh is not available
    print_status "Setting up enhanced bash configuration..."
    
    cat >> "$HOME/.bashrc" << 'EOF'

# Enhanced Bash Configuration for C++ Development
# (zsh-like features for bash)

# Better prompt
export PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

# C++ development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Development aliases
alias v='nvim'
alias vim='nvim'
alias cls='clear'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'

# C++ function
cpp-init() {
    if [[ -z "$1" ]]; then
        echo "Usage: cpp-init <project-name>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
    echo '#include <iostream>
int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}' > main.cpp
    echo "✓ Created C++ project: $1"
}

echo "🎯 Enhanced C++ Development Environment Ready!"
EOF

    print_success "Enhanced bash configuration added"
fi

# Part 2: Enhance Neovim UI to be more VSCode-like
print_status "Part 2: Enhancing Neovim UI to be VSCode-like..."

# Create enhanced file explorer configuration
cat > "$SCRIPT_DIR/nvim/lua/plugins/vscode-ui.lua" << 'EOF'
-- VSCode-like UI enhancements
return {
  -- Enhanced file explorer (left sidebar like VSCode)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        -- Auto-open on startup for directories
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        
        -- Update focused file in tree
        update_focused_file = {
          enable = true,
          update_cwd = true,
          ignore_list = {},
        },
        
        -- View settings (VSCode-like)
        view = {
          width = 35,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        
        -- Renderer settings
        renderer = {
          add_trailing = false,
          group_empty = true,
          highlight_git = true,
          full_name = false,
          highlight_opened_files = "name",
          root_folder_label = ":~:s?$?/..?",
          indent_width = 2,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              none = " ",
            },
          },
          icons = {
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
          special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt" },
        },
        
        -- File filtering
        filters = {
          dotfiles = false,
          git_clean = false,
          no_buffer = false,
          custom = { ".DS_Store", "__pycache__", ".git", "node_modules", ".cache" },
          exclude = { ".gitignore", ".env" },
        },
        
        -- Git integration
        git = {
          enable = true,
          ignore = false,
          show_on_dirs = true,
          show_on_open_dirs = true,
          timeout = 400,
        },
        
        -- Actions
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          expand_all = {
            max_folder_discovery = 300,
            exclude = { ".git", "target", "build" },
          },
          file_popup = {
            open_win_config = {
              col = 1,
              row = 1,
              relative = "cursor",
              border = "shadow",
              style = "minimal",
            },
          },
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = true,
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
          remove_file = {
            close_window = true,
          },
        },
        
        -- Filesystem watchers
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
          ignore_dirs = {},
        },
        
        -- Live filter
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = true,
        },
        
        -- Log
        log = {
          enable = false,
          truncate = false,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            dev = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
          },
        },
      })

      -- Keymaps for VSCode-like experience
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer", silent = true })
      vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find File in Explorer", silent = true })
      vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", { desc = "Refresh Explorer", silent = true })
      vim.keymap.set("n", "<leader>ec", ":NvimTreeCollapse<CR>", { desc = "Collapse Explorer", silent = true })
      
      -- Auto-open nvim-tree when opening a directory
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          local directory = vim.fn.isdirectory(data.file) == 1
          if directory then
            vim.cmd.cd(data.file)
            require("nvim-tree.api").tree.open()
          end
        end
      })
      
      -- Auto-open nvim-tree when no file is specified
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            require("nvim-tree.api").tree.open()
          end
        end
      })
    end,
  },

  -- Enhanced tabs/buffers (VSCode-like tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.default,
          themable = true,
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 30,
          max_prefix_length = 30,
          truncate_names = true,
          tab_size = 21,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            return "("..count..")"
          end,
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          move_wraps_at_ends = false,
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = {"close"},
          },
          sort_by = "insert_after_current",
          
          -- Offsets for nvim-tree
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "center",
              separator = true,
            },
          },
        },
      })
      
      -- Keymaps for tab navigation (VSCode-like)
      vim.keymap.set("n", "<C-Tab>", ":BufferLineCycleNext<CR>", { desc = "Next Tab", silent = true })
      vim.keymap.set("n", "<C-S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "Previous Tab", silent = true })
      vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close Buffer", silent = true })
      vim.keymap.set("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force Close Buffer", silent = true })
      
      -- Navigate to specific buffers
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", 
          { desc = "Go to Buffer " .. i, silent = true })
      end
    end,
  },

  -- Better status line (VSCode-like)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = { 
            {
              "mode",
              fmt = function(str)
                return str:sub(1,3)
              end
            }
          },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { 
            {
              "filename",
              file_status = true,
              newfile_status = false,
              path = 1,
              symbols = {
                modified = "[+]",
                readonly = "[RO]",
                unnamed = "[No Name]",
                newfile = "[New]",
              }
            }
          },
          lualine_x = { 
            "encoding", 
            "fileformat", 
            {
              "filetype",
              colored = true,
              icon_only = false,
              icon = { align = "right" },
            }
          },
          lualine_y = { "progress" },
          lualine_z = { "location" }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = { "nvim-tree", "quickfix" }
      })
    end,
  },

  -- Indentation guides (VSCode-like)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
          smart_indent_cap = true,
          priority = 2,
        },
        whitespace = {
          highlight = { "Whitespace", "NonText" },
          remove_blankline_trail = false,
        },
        scope = {
          enabled = true,
          char = "│",
          show_start = true,
          show_end = true,
          injected_languages = false,
          highlight = { "Function", "Label" },
          priority = 500,
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      })
    end,
  },
}
EOF

# Update the existing UI plugin configuration
cp "$SCRIPT_DIR/nvim/lua/plugins/vscode-ui.lua" "$SCRIPT_DIR/nvim/lua/plugins/ui.lua"

# Update Neovim configuration
cp -r "$SCRIPT_DIR/nvim" ~/.config/nvim

print_success "Enhanced Neovim UI configuration updated"

# Part 3: Create startup configuration for automatic file explorer
print_status "Part 3: Configuring automatic file explorer startup..."

# Add auto-open file explorer to init.lua
cat >> "$SCRIPT_DIR/nvim/init.lua" << 'EOF'

-- Auto-open file explorer on startup (VSCode-like behavior)
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- Open nvim-tree if no file was specified or if opening a directory
    if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.schedule(function()
        require("nvim-tree.api").tree.open()
      end)
    end
  end,
})
EOF

# Update the configuration
cp -r "$SCRIPT_DIR/nvim" ~/.config/nvim

print_success "🎉 Environment enhancement complete!"

echo ""
print_status "📋 SUMMARY OF ENHANCEMENTS:"
if [[ "$USE_BASH_ENHANCED" == "false" ]]; then
    echo "  ✓ Installed Oh My Zsh with plugins (autosuggestions, syntax highlighting)"
    echo "  ✓ Configured automatic zsh startup on login"
    echo "  ✓ Added C++ development aliases and functions"
else
    echo "  ✓ Enhanced bash configuration with zsh-like features"
    echo "  ✓ Added C++ development aliases and functions"
fi
echo "  ✓ VSCode-like file explorer on the left (auto-opens)"
echo "  ✓ Enhanced tab bar with buffer navigation"
echo "  ✓ Improved status line with more information"
echo "  ✓ Better indentation guides"
echo ""
print_status "🚀 NEW FEATURES:"
echo ""
print_status "Shell Features:"
if [[ "$USE_BASH_ENHANCED" == "false" ]]; then
    echo "  • Oh My Zsh with beautiful prompts and autosuggestions"
    echo "  • Automatic zsh startup (run 'zsh' manually first time)"
else
    echo "  • Enhanced bash with better prompts and aliases"
fi
echo "  • cpp-init <name> - Create new C++ project quickly"
echo "  • Smart aliases: v/vim→nvim, gs→git status, etc."
echo ""
print_status "Neovim UI Features:"
echo "  • File explorer automatically opens on left (like VSCode)"
echo "  • Tabs at top with buffer navigation"
echo "  • <Ctrl+Tab> / <Ctrl+Shift+Tab> - Navigate tabs"
echo "  • <leader>1-9 - Jump to specific buffer/tab"
echo "  • <leader>bd - Close current buffer/tab"
echo "  • Enhanced file icons and git status indicators"
echo ""
print_status "🔑 QUICK START:"
echo "  1. Close this terminal and SSH back in (to get Oh My Zsh)"
echo "  2. Run: cpp-init my-project"
echo "  3. Run: cd my-project && nvim ."
echo "  4. Enjoy VSCode-like file explorer + full C++ LSP!"
echo ""
print_success "Your development environment is now supercharged! 🎯"

# Restart message
echo ""
print_warning "⚠️  IMPORTANT: Close this terminal and SSH back in to activate Oh My Zsh!"
print_status "Then try: cpp-init test-project && cd test-project && nvim ."
