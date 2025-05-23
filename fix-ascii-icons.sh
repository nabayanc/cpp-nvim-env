#!/bin/bash
# Simple ASCII-Only Icon Fix for File Explorer

echo "🔧 Setting up ASCII-only file icons..."

# Update nvim-tree to use simple ASCII characters
cat > ~/.config/nvim/lua/plugins/file-explorer-simple.lua << 'EOFNVIM'
-- Simple ASCII File Explorer (No Unicode Dependencies)
return {
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        
        view = {
          width = 35,
          side = "left",
        },
        
        renderer = {
          icons = {
            show = {
              file = false,        -- Disable file icons completely
              folder = true,       -- Keep folder indicators
              folder_arrow = true, -- Keep folder arrows
              git = true,         -- Keep git status
            },
            glyphs = {
              default = "",        -- No file icon
              symlink = "",
              bookmark = "",
              folder = {
                arrow_closed = ">", -- Simple ASCII arrow
                arrow_open = "v",   -- Simple ASCII arrow
                default = "[DIR]",  -- Simple folder indicator
                open = "[DIR]",
                empty = "[DIR]",
                empty_open = "[DIR]",
                symlink = "[LINK]",
                symlink_open = "[LINK]",
              },
              git = {
                unstaged = "M",     -- Modified
                staged = "A",       -- Added
                unmerged = "U",     -- Unmerged
                renamed = "R",      -- Renamed
                untracked = "?",    -- Untracked
                deleted = "D",      -- Deleted
                ignored = "I",      -- Ignored
              },
            },
          },
          indent_markers = {
            enable = true,
            icons = {
              corner = "+",
              edge = "|",
              item = "|",
              none = " ",
            },
          },
        },
        
        filters = {
          dotfiles = false,
          custom = { ".DS_Store", "node_modules", ".cache" },
        },
        
        git = {
          enable = true,
          ignore = false,
        },
        
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
      vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find File" })
      
      -- Auto-open
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            require("nvim-tree.api").tree.open()
          end
        end
      })
    end,
  },
}
EOFNVIM

# Remove the complex icon config
rm -f ~/.config/nvim/lua/plugins/file-explorer.lua 2>/dev/null
rm -f ~/.config/nvim/lua/config/icons.lua 2>/dev/null

# Clear plugin cache
rm -rf ~/.local/share/nvim/lazy/nvim-tree.lua 2>/dev/null
rm -rf ~/.local/share/nvim/lazy/nvim-web-devicons 2>/dev/null

echo "✅ Simple ASCII file explorer configured"
echo "Files will show as: filename.cpp (no icons)"
echo "Folders will show as: > [DIR] foldername"
echo "Git status: M modified, A added, ? untracked"
