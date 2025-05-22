-- Telescope Configuration for Fuzzy Finding and Search
-- Provides powerful file and text search capabilities

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "%.git/", "node_modules", "%.o$", "%.so$", "%.a$" },
          mappings = {
            i = {
              ["<C-h>"] = "which_key",
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
            },
          },
          layout_config = {
            horizontal = {
              preview_width = 0.5,
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
            hidden = true,
          },
          live_grep = {
            theme = "ivy",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
          },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>pg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>pb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>ph", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>ps", function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end, { desc = "Grep string" })
      vim.keymap.set("n", "<leader>pc", builtin.git_commits, { desc = "Git commits" })
      vim.keymap.set("n", "<leader>pfc", builtin.git_bcommits, { desc = "Buffer git commits" })
      vim.keymap.set("n", "<leader>pr", builtin.oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader>pk", builtin.keymaps, { desc = "Find keymaps" })
    end,
  },
}
