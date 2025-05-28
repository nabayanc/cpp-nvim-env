#!/bin/bash
# Fix Catppuccin Theme Loading Issue
# Ensures the theme loads properly on all systems

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
NVIM_CONFIG="$HOME/.config/nvim"

print_status "🎨 Fixing Catppuccin theme loading issue..."

# Step 1: Check current setup
print_status "Step 1: Diagnosing theme issue..."

if [[ ! -d "$NVIM_CONFIG" ]]; then
    print_error "Neovim config directory not found!"
    exit 1
fi

# Check if plugins are installed
if [[ -d "$HOME/.local/share/nvim/lazy/catppuccin" ]]; then
    print_success "Catppuccin plugin directory exists"
else
    print_warning "Catppuccin plugin not installed yet"
fi

# Step 2: Fix the UI plugin configuration
print_status "Step 2: Updating theme configuration for better compatibility..."

cat > "$NVIM_CONFIG/lua/plugins/ui.lua" << 'EOF'
-- Enhanced UI Plugins with Fixed Theme Loading
return {
  -- Color scheme - Catppuccin with proper loading
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,  -- Load immediately
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          notify = false,
          mini = false,
        },
      })
      
      -- Set colorscheme with error handling
      local status_ok, _ = pcall(vim.cmd.colorscheme, "catppuccin")
      if not status_ok then
        print("Warning: Catppuccin theme not available, using fallback")
        vim.cmd.colorscheme("default")
      else
        print("✓ Catppuccin theme loaded successfully")
      end
    end,
  },

  -- File explorer with enhanced icons
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
        },
      })

      -- Keymaps for VSCode-like experience
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer", silent = true })
      vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find File in Explorer", silent = true })
      vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", { desc = "Refresh Explorer", silent = true })
      
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
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
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
      
      -- Navigate to specific buffers
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", 
          { desc = "Go to Buffer " .. i, silent = true })
      end
    end,
  },

  -- Better status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Determine theme based on what's available
      local theme = "auto"
      local catppuccin_ok = pcall(require, "catppuccin")
      if catppuccin_ok then
        theme = "catppuccin"
      end
      
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = theme,
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
        extensions = { "nvim-tree", "quickfix" }
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
        current_line_blame = false,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Navigation
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

          -- Actions
          vim.keymap.set({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
          vim.keymap.set({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
          vim.keymap.set("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
          vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
          vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
          vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
          vim.keymap.set("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
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
        ts_config = {
          lua = { "string", "source" },
          javascript = { "string", "template_string" },
        },
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

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPre",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { enabled = false },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
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

print_success "Updated UI configuration with better theme loading"

# Step 3: Clear plugin cache and force reinstall
print_status "Step 3: Clearing plugin cache to force clean install..."

rm -rf "$HOME/.local/share/nvim/lazy/catppuccin" 2>/dev/null || true
rm -rf "$HOME/.local/state/nvim/lazy-lock.json" 2>/dev/null || true

print_success "Cleared theme plugin cache"

# Step 4: Create fallback theme configuration
print_status "Step 4: Adding fallback theme support..."

cat > "$NVIM_CONFIG/lua/config/theme-fallback.lua" << 'EOF'
-- Theme Fallback Configuration
-- Ensures a good-looking theme even if Catppuccin fails

local M = {}

function M.setup_theme()
  -- Try to load Catppuccin first
  local catppuccin_ok, catppuccin = pcall(require, "catppuccin")
  
  if catppuccin_ok then
    catppuccin.setup({
      flavour = "mocha",
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
      },
    })
    
    local status_ok, _ = pcall(vim.cmd.colorscheme, "catppuccin")
    if status_ok then
      print("✓ Catppuccin theme loaded")
      return true
    end
  end
  
  -- Fallback themes in order of preference
  local fallback_themes = {
    "habamax",    -- Modern, built-in theme
    "murphy",     -- Classic dark theme
    "slate",      -- Another good dark theme
    "default",    -- Always available
  }
  
  for _, theme in ipairs(fallback_themes) do
    local ok, _ = pcall(vim.cmd.colorscheme, theme)
    if ok then
      print("Using fallback theme: " .. theme)
      
      -- Enhance the fallback theme with better colors
      vim.api.nvim_set_hl(0, "Normal", { bg = "#1e1e2e", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#313244" })
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#313244" })
      vim.api.nvim_set_hl(0, "Visual", { bg = "#585b70" })
      vim.api.nvim_set_hl(0, "Search", { bg = "#f9e2af", fg = "#1e1e2e" })
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "#45475a", fg = "#cdd6f4" })
      
      return true
    end
  end
  
  print("Warning: All themes failed, using Neovim defaults")
  return false
end

return M
EOF

# Step 5: Update init.lua to use fallback theme
print_status "Step 5: Updating init.lua with theme fallback..."

# Add fallback theme loading to init.lua if not already present
if ! grep -q "theme-fallback" "$NVIM_CONFIG/init.lua"; then
    cat >> "$NVIM_CONFIG/init.lua" << 'EOF'

-- Setup theme with fallback support
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("config.theme-fallback").setup_theme()
  end,
})
EOF
fi

print_success "Added theme fallback to init.lua"

# Step 6: Copy updated config to repository
print_status "Step 6: Updating repository with fixed configuration..."

if [[ -d "$SCRIPT_DIR/nvim" ]]; then
    cp -r "$NVIM_CONFIG"/* "$SCRIPT_DIR/nvim/"
    print_success "Updated repository nvim configuration"
fi

print_success "🎨 Theme fix complete!"

echo ""
print_status "📋 WHAT WAS FIXED:"
echo "  ✓ Added proper plugin loading priority for Catppuccin"
echo "  ✓ Added error handling for theme loading"
echo "  ✓ Created fallback theme system"
echo "  ✓ Cleared plugin cache for clean reinstall"
echo "  ✓ Enhanced theme compatibility across systems"
echo ""
print_status "🚀 NEXT STEPS:"
echo "  1. Restart Neovim: exit and run 'nvim .'"
echo "  2. Plugins will reinstall automatically (1-2 minutes)"
echo "  3. Theme should load properly now"
echo "  4. If using fallback theme, it will still look great!"
echo ""
print_status "🎯 TO TEST:"
echo "  nvim ."
echo "  # Wait for plugins to install"
echo "  # You should see either:"
echo "  # - '✓ Catppuccin theme loaded' (success)"
echo "  # - 'Using fallback theme: X' (still looks good)"
echo ""
print_success "Theme loading should now work reliably! 🎨"
