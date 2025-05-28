#!/bin/bash
# Clean Deploy Script for C++ Neovim Environment
# Sets up a minimal, working configuration with GitHub light theme and no icons
# Can be run on any system with or without existing nvim config

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

# Configuration
INSTALL_DIR="$HOME/.local"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TOOLS_DIR="$HOME/.local/tools"
BACKUP_DIR="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"

print_status "🚀 Starting clean deployment of C++ Neovim environment..."

# Step 1: Backup existing configuration
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    print_warning "Existing Neovim config found. Creating backup..."
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
    print_success "Backup created at: $BACKUP_DIR"
fi

# Step 2: Create directories
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$TOOLS_DIR"
mkdir -p "$NVIM_CONFIG_DIR"

# Step 3: Add to PATH if needed
if ! echo "$PATH" | grep -q "$INSTALL_DIR/bin"; then
    print_status "Adding $INSTALL_DIR/bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Step 4: Download function
download_tool() {
    local url=$1
    local output=$2
    print_status "Downloading $(basename "$output")..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L --progress-bar "$url" -o "$output"
    elif command -v wget >/dev/null 2>&1; then
        wget --progress=bar:force:noscroll -O "$output" "$url"
    else
        print_error "Neither curl nor wget found"
        exit 1
    fi
}

# Step 5: Install Neovim (if not present)
if [[ ! -f "$INSTALL_DIR/bin/nvim" ]]; then
    print_status "Installing Neovim 0.9.5..."
    cd "$TOOLS_DIR"
    download_tool \
        "https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz" \
        "nvim-linux64.tar.gz"
    
    tar -xzf nvim-linux64.tar.gz
    ln -sf "$TOOLS_DIR/nvim-linux64/bin/nvim" "$INSTALL_DIR/bin/nvim"
    rm nvim-linux64.tar.gz
    print_success "Neovim installed"
else
    print_success "Neovim already available"
fi

# Step 6: Install clangd (if not present)
if [[ ! -f "$INSTALL_DIR/bin/clangd" ]]; then
    print_status "Installing clangd..."
    cd "$TOOLS_DIR"
    CLANGD_VERSION="18.1.3"
    download_tool \
        "https://github.com/clangd/clangd/releases/download/$CLANGD_VERSION/clangd-linux-$CLANGD_VERSION.zip" \
        "clangd.zip"
    
    unzip -q clangd.zip
    CLANGD_DIR=$(ls -d clangd_* | head -1)
    ln -sf "$TOOLS_DIR/$CLANGD_DIR/bin/clangd" "$INSTALL_DIR/bin/clangd"
    rm clangd.zip
    print_success "clangd installed"
else
    print_success "clangd already available"
fi

# Step 7: Install ripgrep (if not present)
if [[ ! -f "$INSTALL_DIR/bin/rg" ]]; then
    print_status "Installing ripgrep..."
    cd "$TOOLS_DIR"
    RG_VERSION="14.1.0"
    download_tool \
        "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz" \
        "ripgrep.tar.gz"
    
    tar -xzf ripgrep.tar.gz
    RG_DIR=$(ls -d ripgrep-* | head -1)
    ln -sf "$TOOLS_DIR/$RG_DIR/rg" "$INSTALL_DIR/bin/rg"
    rm ripgrep.tar.gz
    print_success "ripgrep installed"
else
    print_success "ripgrep already available"
fi

# Step 8: Install fd (if not present)
if [[ ! -f "$INSTALL_DIR/bin/fd" ]]; then
    print_status "Installing fd..."
    cd "$TOOLS_DIR"
    FD_VERSION="v10.1.0"
    download_tool \
        "https://github.com/sharkdp/fd/releases/download/$FD_VERSION/fd-$FD_VERSION-x86_64-unknown-linux-musl.tar.gz" \
        "fd.tar.gz"
    
    tar -xzf fd.tar.gz
    FD_DIR=$(ls -d fd-* | head -1)
    ln -sf "$TOOLS_DIR/$FD_DIR/fd" "$INSTALL_DIR/bin/fd"
    rm fd.tar.gz
    print_success "fd installed"
else
    print_success "fd already available"
fi

# Step 9: Create clean Neovim configuration
print_status "Creating clean Neovim configuration..."

# Create directory structure
mkdir -p "$NVIM_CONFIG_DIR/lua/config"
mkdir -p "$NVIM_CONFIG_DIR/lua/plugins"

# Main init.lua
cat > "$NVIM_CONFIG_DIR/init.lua" << 'EOF'
-- Clean C++ Development Environment
-- Focus on functionality with clean GitHub light theme

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load configuration
require("config.options")
require("config.keymaps")
require("config.lsp")

-- Setup plugins
require("lazy").setup("plugins", {
  change_detection = { notify = false },
  checker = { enabled = false },
})

-- Auto-open file explorer
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        require("nvim-tree.api").tree.open()
      end)
    end
  end,
})
EOF

# Options configuration
cat > "$NVIM_CONFIG_DIR/lua/config/options.lua" << 'EOF'
-- Editor Options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Display
opt.wrap = false
opt.linebreak = true
opt.colorcolumn = "80,120"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 500

-- Backup and undo
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- Clipboard
if vim.fn.has("unnamedplus") == 1 then
    opt.clipboard = "unnamedplus"
end

-- Mouse
opt.mouse = "a"

-- File encoding
opt.fileencoding = "utf-8"
opt.conceallevel = 0
opt.showtabline = 2
EOF

# Keymaps configuration
cat > "$NVIM_CONFIG_DIR/lua/config/keymaps.lua" << 'EOF'
-- Key Mappings
local keymap = vim.keymap.set

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffer navigation
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- File operations
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })

-- Splits
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertical" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Split horizontal" })
keymap("n", "<leader>sx", ":close<CR>", { desc = "Close split" })

-- Terminal
keymap("n", "<leader>tt", ":terminal<CR>", { desc = "Open terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- C++ specific
keymap("n", "<leader>cc", ":!g++ -std=c++17 -Wall -Wextra -g % -o %:r<CR>", { desc = "Compile file" })
keymap("n", "<leader>cb", ":!cpp-build<CR>", { desc = "Build project" })

-- Diagnostics
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Visual mode
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Insert mode shortcuts
keymap("i", "jk", "<Esc>", { desc = "Quick escape" })
keymap("i", "kj", "<Esc>", { desc = "Quick escape" })
EOF

# LSP configuration
cat > "$NVIM_CONFIG_DIR/lua/config/lsp.lua" << 'EOF'
-- LSP Configuration for C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    local clangd_path = vim.fn.expand("~/.local/bin/clangd")
    
    if vim.fn.executable(clangd_path) == 1 then
      print("🚀 Starting clangd for " .. vim.fn.expand("%:t"))
      
      local client_id = vim.lsp.start({
        name = "clangd",
        cmd = { 
          clangd_path, 
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu"
        },
        root_dir = vim.fs.dirname(
          vim.fs.find({"compile_commands.json", ".git"}, { upward = true })[1]
        ) or vim.fn.getcwd(),
        capabilities = {
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = true,
                resolveSupport = {
                  properties = { "documentation", "detail", "additionalTextEdits" }
                }
              }
            }
          }
        },
        on_attach = function(client, bufnr)
          print("✅ clangd attached! LSP features active")
          
          local opts = { buffer = bufnr, silent = true }
          
          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          
          -- Information
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          
          -- Actions
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
      
      if client_id then
        print("✓ clangd client started (ID: " .. client_id .. ")")
      end
    else
      print("❌ clangd not found. Run clean-deploy.sh to install.")
    end
  end,
})

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
EOF

# Theme plugin
cat > "$NVIM_CONFIG_DIR/lua/plugins/theme.lua" << 'EOF'
return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require('github-theme').setup({
        options = {
          compile_path = vim.fn.stdpath('cache') .. '/github-theme',
          transparent = false,
          hide_end_of_buffer = true,
          hide_nc_statusline = true,
          terminal_colors = true,
          dim_inactive = false,
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
        groups = {
          github_light = {
            -- File explorer colors
            Directory = { fg = '#0969da', style = 'bold' },
            NvimTreeFolderName = { fg = '#0969da', style = 'bold' },
            NvimTreeOpenedFolderName = { fg = '#0969da', style = 'bold' },
            NvimTreeRootFolder = { fg = '#0969da', style = 'bold' },
            
            -- File type colors
            NvimTreeExecFile = { fg = '#cf222e', style = 'bold' },
            NvimTreeSpecialFile = { fg = '#8250df', style = 'bold' },
            
            -- Git status colors
            NvimTreeGitDirty = { fg = '#fb8500' },
            NvimTreeGitStaged = { fg = '#1f883d' },
            NvimTreeGitDeleted = { fg = '#cf222e' },
            NvimTreeGitNew = { fg = '#8250df' },
            NvimTreeGitIgnored = { fg = '#656d76' },
          },
        },
      })
      
      vim.cmd('colorscheme github_light')
    end,
  }
}
EOF

# File explorer plugin (NO ICONS)
cat > "$NVIM_CONFIG_DIR/lua/plugins/explorer.lua" << 'EOF'
return {
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        
        view = {
          width = 35,
          side = "left",
        },
        
        renderer = {
          add_trailing = false,
          group_empty = true,
          highlight_git = true,
          highlight_opened_files = "name",
          root_folder_label = ":t",
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
            show = {
              file = false,        -- NO file icons
              folder = false,      -- NO folder icons
              folder_arrow = true, -- Keep expand arrows
              git = true,         -- Keep git status
            },
            glyphs = {
              folder = {
                arrow_closed = "▶",
                arrow_open = "▼",
              },
              git = {
                unstaged = "M",
                staged = "A",
                unmerged = "U",
                renamed = "R",
                untracked = "?",
                deleted = "D",
                ignored = "!",
              },
            },
          },
          special_files = { 
            "Cargo.toml", "Makefile", "README.md", "readme.md", 
            "CMakeLists.txt", ".gitignore" 
          },
        },
        
        filters = {
          dotfiles = false,
          custom = { ".DS_Store", "__pycache__", "node_modules", ".cache" },
          exclude = { ".gitignore", ".env" },
        },
        
        git = {
          enable = true,
          ignore = false,
          show_on_dirs = true,
          timeout = 400,
        },
        
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
          },
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer", silent = true })
      vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find File in Explorer", silent = true })
      vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", { desc = "Refresh Explorer", silent = true })
    end,
  }
}
EOF

# Telescope plugin
cat > "$NVIM_CONFIG_DIR/lua/plugins/telescope.lua" << 'EOF'
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "%.git/", "node_modules", "%.o$", "%.so$", "%.a$", "build/" },
          layout_config = {
            horizontal = { preview_width = 0.5 },
          },
        },
        pickers = {
          find_files = { theme = "dropdown", previewer = false },
          live_grep = { theme = "ivy" },
          buffers = { theme = "dropdown", previewer = false },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>pg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>pb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>ph", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>pr", builtin.oldfiles, { desc = "Recent files" })
    end,
  },
}
EOF

# Treesitter plugin
cat > "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua" << 'EOF'
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "bash", "cmake" },
        sync_install = false,
        auto_install = false,
        highlight = { 
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
}
EOF

# Completion plugin
cat > "$NVIM_CONFIG_DIR/lua/plugins/completion.lua" << 'EOF'
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({ 
            behavior = cmp.ConfirmBehavior.Replace, 
            select = true 
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },
}
EOF

# Additional UI plugins
cat > "$NVIM_CONFIG_DIR/lua/plugins/ui.lua" << 'EOF'
return {
  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = false,
          theme = "github_light",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          vim.keymap.set("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next git hunk" })

          vim.keymap.set("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous git hunk" })

          vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
          vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
          vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
          vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
        end,
      })
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        disable_filetype = { "TelescopePrompt" },
      })
    end,
  },

  -- Comment plugin
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },
}
EOF

print_success "Clean Neovim configuration created"

# Step 10: Create cpp-build script
print_status "Creating cpp-build script..."

cat > "$INSTALL_DIR/bin/cpp-build" << 'EOF'
#!/bin/bash
# Simple C++ Build Helper

set -e

PROJECT_DIR="${1:-.}"
BUILD_DIR="$PROJECT_DIR/build"

echo "🔨 Building C++ project in $PROJECT_DIR..."

cd "$PROJECT_DIR"

if [[ -f "CMakeLists.txt" ]]; then
    echo "📋 CMake project detected"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
    make -j$(nproc)
    
    # Link compile_commands.json for LSP
    if [[ -f "compile_commands.json" ]]; then
        ln -sf "$BUILD_DIR/compile_commands.json" "$PROJECT_DIR/"
        echo "✅ Created compile_commands.json for LSP"
    fi
    
elif [[ -f "Makefile" ]]; then
    echo "📋 Makefile detected"
    make -j$(nproc)
    
else
    echo "📋 Single file compilation"
    CPP_FILES=($(find . -maxdepth 1 -name "*.cpp"))
    
    if [[ ${#CPP_FILES[@]} -eq 0 ]]; then
        echo "❌ No C++ files found"
        exit 1
    fi
    
    # Create compile_commands.json for LSP
    echo '[' > compile_commands.json
    for i in "${!CPP_FILES[@]}"; do
        file="${CPP_FILES[$i]}"
        if [[ $i -gt 0 ]]; then echo ',' >> compile_commands.json; fi
        cat >> compile_commands.json << EOJ
  {
    "directory": "$(pwd)",
    "command": "g++ -std=c++17 -Wall -Wextra -g $(basename "$file")",
    "file": "$file"
  }
EOJ
    done
    echo ']' >> compile_commands.json
    
    # Compile
    OUTPUT_NAME="${CPP_FILES[0]%.*}"
    g++ -std=c++17 -Wall -Wextra -g "${CPP_FILES[@]}" -o "$OUTPUT_NAME"
    echo "✅ Compiled to $OUTPUT_NAME"
fi

echo "🎉 Build complete!"
EOF

chmod +x "$INSTALL_DIR/bin/cpp-build"
print_success "cpp-build script created"

# Step 11: Create test project
print_status "Creating test project..."
TEST_DIR="$HOME/cpp-test-clean"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

cat > main.cpp << 'EOF'
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::vector<std::string> messages = {
        "🎉 Clean C++ environment is working!",
        "✅ GitHub light theme active",
        "🚀 LSP integration ready",
        "📁 File explorer (no icons, clean look)",
        "🔍 Telescope fuzzy finder active"
    };
    
    std::cout << "Clean Deploy Success!" << std::endl;
    for (const auto& msg : messages) {
        std::cout << "  " << msg << std::endl;
    }
    
    return 0;
}
EOF

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(CleanTest)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(main main.cpp)
EOF

# Build the test project
cpp-build

print_success "Test project created and built at $TEST_DIR"

# Final cleanup
print_status "Final cleanup..."
rm -rf ~/.local/share/nvim/lazy/ 2>/dev/null || true
rm -rf ~/.local/state/nvim/ 2>/dev/null || true
rm -rf ~/.cache/nvim/ 2>/dev/null || true

print_success "🎉 Clean deployment complete!"

echo ""
print_status "📋 WHAT WAS INSTALLED:"
echo "  ✅ Neovim 0.9.5 (compatible with older systems)"
echo "  ✅ clangd (C++ language server)"
echo "  ✅ ripgrep (fast text search)"
echo "  ✅ fd (fast file finder)"
echo "  ✅ cpp-build (smart build helper)"
echo ""
print_status "🎨 THEME & UI:"
echo "  ✅ GitHub Light theme (clean, professional)"
echo "  ✅ File explorer with NO ICONS (text only)"
echo "  ✅ Git status indicators (M, A, ?, D, etc.)"
echo "  ✅ Clean status line"
echo "  ✅ No visual clutter or broken symbols"
echo ""
print_status "🔑 KEY FEATURES:"
echo "  • <Space>pf - Find files (fuzzy finder)"
echo "  • <Space>pg - Live grep search"
echo "  • <Space>e - Toggle file explorer"
echo "  • gd - Go to definition (LSP)"
echo "  • K - Show documentation (LSP)"
echo "  • <Space>f - Format code"
echo "  • gcc - Comment/uncomment line"
echo "  • cpp-build - Build C++ projects"
echo ""
print_status "🚀 QUICK TEST:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Test: cd $TEST_DIR && nvim ."
echo "  3. Wait for plugins to install (1-2 minutes first time)"
echo "  4. File explorer should auto-open on left"
echo "  5. Try LSP: put cursor on 'std::cout' and press 'K'"
echo ""
if [[ -d "$BACKUP_DIR" ]]; then
    print_warning "📦 Your old config was backed up to: $BACKUP_DIR"
fi
print_success "Clean C++ development environment ready! 🎯"
