#!/bin/bash
# Fix Tab Switcher - Ensure bufferline works properly

set -e

NVIM_CONFIG="$HOME/.config/nvim"

echo "🔧 Fixing tab switcher (bufferline)..."

# Create or update bufferline configuration
cat > "$NVIM_CONFIG/lua/plugins/bufferline.lua" << 'EOF'
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
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
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "×",
          modified_icon = "●",
          close_icon = "×",
          left_trunc_marker = "◀",
          right_trunc_marker = "▶",
          max_name_length = 30,
          tab_size = 21,
          diagnostics = "nvim_lsp",
          color_icons = false,  -- Disable to avoid icon issues
          show_buffer_icons = false,  -- No file icons in tabs
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "slant",
          always_show_bufferline = true,
          sort_by = "insert_after_current",
          
          -- Offset for nvim-tree
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "center",
              separator = true,
            },
          },
        },
        highlights = {
          -- GitHub Light theme integration
          background = {
            bg = "#f6f8fa",
          },
          buffer_selected = {
            bg = "#ffffff",
            fg = "#24292f",
            bold = true,
            italic = false,
          },
          buffer_visible = {
            bg = "#eaeef2",
            fg = "#656d76",
          },
          close_button = {
            bg = "#f6f8fa",
            fg = "#656d76",
          },
          close_button_selected = {
            bg = "#ffffff",
            fg = "#cf222e",
          },
          tab_selected = {
            bg = "#ffffff",
            fg = "#24292f",
          },
          separator = {
            bg = "#f6f8fa",
            fg = "#d0d7de",
          },
          separator_selected = {
            bg = "#ffffff",
            fg = "#d0d7de",
          },
          indicator_selected = {
            bg = "#ffffff",
            fg = "#0969da",
          },
        },
      })
      
      -- Tab navigation keymaps
      vim.keymap.set("n", "<C-Tab>", ":BufferLineCycleNext<CR>", { desc = "Next Tab", silent = true })
      vim.keymap.set("n", "<C-S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "Previous Tab", silent = true })
      vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close Buffer", silent = true })
      vim.keymap.set("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force Close Buffer", silent = true })
      
      -- Quick tab switching
      vim.keymap.set("n", "<leader>bn", ":BufferLineCycleNext<CR>", { desc = "Next Buffer", silent = true })
      vim.keymap.set("n", "<leader>bp", ":BufferLineCyclePrev<CR>", { desc = "Previous Buffer", silent = true })
      
      -- Jump to specific buffers (like browser tabs)
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", 
          { desc = "Go to Buffer " .. i, silent = true })
      end
    end,
  }
}
EOF

# Clear bufferline cache
rm -rf ~/.local/share/nvim/lazy/bufferline.nvim 2>/dev/null || true

echo "✅ Tab switcher fixed!"
echo ""
echo "🎯 Tab Navigation:"
echo "  • Ctrl+Tab / Ctrl+Shift+Tab - Switch tabs"
echo "  • <Space>bd - Close current tab" 
echo "  • <Space>1-9 - Jump to tab 1-9"
echo "  • <Space>bn/bp - Next/Previous tab"
echo ""
echo "🚀 Restart Neovim to see tabs at the top!"
