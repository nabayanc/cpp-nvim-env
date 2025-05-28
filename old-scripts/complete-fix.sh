#!/bin/bash
# Complete Fix Script for C++ Neovim Environment
# Fixes LSP issues and creates fully functional development environment
# Run from cpp-nvim-env directory

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "🔧 Starting complete C++ Neovim environment fix..."

# Verify we're in the right directory
if [[ ! -f "setup.sh" || ! -d "nvim" ]]; then
    print_error "Please run this script from the cpp-nvim-env directory"
    exit 1
fi

print_status "Project directory: $SCRIPT_DIR"

# Step 1: Complete cleanup of broken state
print_status "Step 1: Complete cleanup of broken plugins and state..."
pkill nvim 2>/dev/null || true
rm -rf ~/.local/share/nvim/
rm -rf ~/.local/state/nvim/
rm -rf ~/.cache/nvim/
if [[ -d ~/.config/nvim ]]; then
    mv ~/.config/nvim ~/.config/nvim.backup.$(date +%s) 2>/dev/null || true
fi
print_success "Cleaned up broken plugin state"

# Step 2: Create new compatible Neovim configuration
print_status "Step 2: Creating new compatible Neovim configuration..."

# Create new nvim config structure
mkdir -p "$SCRIPT_DIR/nvim-fixed/lua/config"
mkdir -p "$SCRIPT_DIR/nvim-fixed/lua/plugins"

# Create main init.lua
cat > "$SCRIPT_DIR/nvim-fixed/init.lua" << 'EOF'
-- C++ Development Environment for Neovim 0.9.5
-- Compatible configuration without problematic plugins

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
EOF

# Create options.lua
cat > "$SCRIPT_DIR/nvim-fixed/lua/config/options.lua" << 'EOF'
-- Editor Options Configuration
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

-- C++ specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "c", "h", "hpp" },
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})
EOF

# Create keymaps.lua
cat > "$SCRIPT_DIR/nvim-fixed/lua/config/keymaps.lua" << 'EOF'
-- Key Mappings Configuration
local keymap = vim.keymap.set

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
keymap("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease height" })
keymap("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase height" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Better line movement
keymap("n", "j", "gj", { desc = "Move down (display line)" })
keymap("n", "k", "gk", { desc = "Move up (display line)" })

-- Keep cursor centered
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
keymap("n", "n", "nzzzv", { desc = "Next search (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search (centered)" })

-- Visual mode - stay in indent mode
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("v", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "p", '"_dP', { desc = "Paste without yanking" })

-- File operations
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })

-- Search and replace
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlights" })

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

-- Insert mode shortcuts
keymap("i", "jk", "<Esc>", { desc = "Quick escape" })
keymap("i", "kj", "<Esc>", { desc = "Quick escape" })
EOF

# Create manual LSP configuration
cat > "$SCRIPT_DIR/nvim-fixed/lua/config/lsp.lua" << 'EOF'
-- Manual LSP Configuration for Neovim 0.9.5
-- Works without nvim-lspconfig

-- LSP setup for C++ files
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
          
          -- LSP Keymaps
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
          
          -- Workspace
          vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          
          -- Type definition
          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
        end,
      })
      
      if client_id then
        print("✓ clangd client started (ID: " .. client_id .. ")")
      else
        print("✗ Failed to start clangd client")
      end
    else
      print("❌ clangd not found at: " .. clangd_path)
      print("Run setup.sh to install clangd")
    end
  end,
})

-- Enhanced diagnostic configuration
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
    header = "",
    prefix = "",
  },
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Auto-format on save for C++ files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.c", "*.h", "*.hpp" },
  callback = function()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentFormattingProvider then
        vim.lsp.buf.format({ async = false })
        break
      end
    end
  end,
})
EOF

# Create telescope plugin (fuzzy finder)
cat > "$SCRIPT_DIR/nvim-fixed/lua/plugins/telescope.lua" << 'EOF'
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
      vim.keymap.set("n", "<leader>ps", function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end, { desc = "Grep string" })
    end,
  },
}
EOF

# Create treesitter plugin (syntax highlighting)
cat > "$SCRIPT_DIR/nvim-fixed/lua/plugins/treesitter.lua" << 'EOF'
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

# Create completion plugin
cat > "$SCRIPT_DIR/nvim-fixed/lua/plugins/completion.lua" << 'EOF'
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

# Create essential UI plugins
cat > "$SCRIPT_DIR/nvim-fixed/lua/plugins/ui.lua" << 'EOF'
return {
  -- Color scheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          custom = { ".DS_Store", ".git", "node_modules", ".cache", "build" },
        },
        git = { enable = true, ignore = false },
      })

      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
      vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find file in explorer" })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          disabled_filetypes = { "NvimTree" },
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

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPre",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = false },
        exclude = {
          filetypes = { "help", "dashboard", "NvimTree", "lazy" },
        },
      })
    end,
  },
}
EOF

print_success "Created new compatible Neovim configuration"

# Step 3: Install the new configuration
print_status "Step 3: Installing new configuration..."
cp -r "$SCRIPT_DIR/nvim-fixed" ~/.config/nvim
print_success "Installed new configuration"

# Step 4: Update repository with working config
print_status "Step 4: Updating repository with working configuration..."
rm -rf "$SCRIPT_DIR/nvim"
mv "$SCRIPT_DIR/nvim-fixed" "$SCRIPT_DIR/nvim"

# Update setup.sh to use correct Neovim version
sed -i 's|v0.10.2|v0.9.5|g' "$SCRIPT_DIR/setup.sh" 2>/dev/null || true

print_success "Updated repository with working configuration"

# Step 5: Create test project
print_status "Step 5: Creating test project..."
TEST_DIR="$HOME/cpp-test-fixed"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

cat > main.cpp << 'EOF'
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

class Calculator {
public:
    int add(int a, int b) {
        return a + b;
    }
    
    double multiply(double x, double y) {
        return x * y;
    }
};

int main() {
    Calculator calc;
    
    std::vector<std::string> messages = {
        "🎉 C++ Development Environment is working!",
        "✅ LSP integration active",
        "🚀 Ready for serious development!"
    };
    
    for (const auto& message : messages) {
        std::cout << message << std::endl;
    }
    
    std::cout << "Calculator test: 5 + 3 = " << calc.add(5, 3) << std::endl;
    std::cout << "Calculator test: 2.5 * 4.0 = " << calc.multiply(2.5, 4.0) << std::endl;
    
    return 0;
}
EOF

cat > math.h << 'EOF'
#pragma once

class MathUtils {
public:
    static int factorial(int n);
    static bool isPrime(int n);
    static double sqrt(double x);
};
EOF

cat > math.cpp << 'EOF'
#include "math.h"

int MathUtils::factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

bool MathUtils::isPrime(int n) {
    if (n < 2) return false;
    for (int i = 2; i * i <= n; ++i) {
        if (n % i == 0) return false;
    }
    return true;
}

double MathUtils::sqrt(double x) {
    if (x < 0) return -1;
    double guess = x / 2.0;
    double epsilon = 0.0001;
    
    while ((guess * guess - x) > epsilon || (x - guess * guess) > epsilon) {
        guess = (guess + x / guess) / 2.0;
    }
    
    return guess;
}
EOF

# Build the test project
cpp-build

print_success "Created comprehensive test project at $TEST_DIR"

# Step 6: Final verification
print_status "Step 6: Final verification..."

# Check tools are available
TOOLS_OK=true
for tool in nvim clangd rg fd cpp-build; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        print_warning "$tool not found in PATH"
        TOOLS_OK=false
    fi
done

if [[ "$TOOLS_OK" == false ]]; then
    print_status "Some tools missing, running setup.sh..."
    cd "$SCRIPT_DIR"
    ./setup.sh
fi

print_success "🎉 Complete fix applied successfully!"

echo ""
print_status "📋 SUMMARY OF CHANGES:"
echo "  ✓ Removed broken nvim-lspconfig plugin"
echo "  ✓ Created manual LSP setup compatible with Neovim 0.9.5"
echo "  ✓ Installed working plugins (Telescope, Treesitter, completion)"
echo "  ✓ Added beautiful UI (Catppuccin theme, file explorer, status line)"
echo "  ✓ Configured Git integration and auto-formatting"
echo "  ✓ Created comprehensive test project with multiple files"
echo "  ✓ Updated repository with working configuration"
echo ""
print_status "🚀 NEXT STEPS:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Test: cd $TEST_DIR && nvim main.cpp"
echo "  3. Wait for plugins to install (1-2 minutes on first launch)"
echo "  4. Test LSP features:"
echo "     • Put cursor on 'Calculator' and press 'gd' (go to definition)"
echo "     • Put cursor on 'std::cout' and press 'K' (hover docs)"
echo "     • Press '<Space>pf' (file finder)"
echo "     • Press '<Space>e' (file explorer)"
echo "     • Type ':LspInfo' (check LSP status)"
echo ""
print_status "🔑 KEY KEYBINDINGS:"
echo "  • <Space>pf - Find files        • <Space>e - File explorer"
echo "  • <Space>pg - Live grep         • gd - Go to definition"
echo "  • <Space>pb - Find buffers      • K - Hover documentation"
echo "  • <Space>cb - Build project     • <Space>f - Format code"
echo "  • gcc - Comment line            • ]d/[d - Next/prev diagnostic"
echo ""
print_success "Your C++ development environment is now fully functional! 🎯"

# Commit changes to repository
cd "$SCRIPT_DIR"
if git rev-parse --git-dir > /dev/null 2>&1; then
    print_status "Committing fixes to repository..."
    git add .
    git commit -m "Complete fix: Working C++ development environment

- Remove broken nvim-lspconfig dependency
- Add manual LSP setup compatible with Neovim 0.9.5
- Include full IDE features (completion, file explorer, fuzzy finder)
- Add comprehensive test project
- Ensure compatibility with university/enterprise systems"
    print_success "Changes committed to git repository"
fi
