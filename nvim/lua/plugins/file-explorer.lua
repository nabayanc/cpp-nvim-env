-- File Explorer with Compatible Icon Configuration
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Setup icons first
      require("config.icons").setup()

      require("nvim-tree").setup({
        -- Auto-open behavior
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        
        update_focused_file = {
          enable = true,
          update_cwd = true,
          ignore_list = {},
        },
        
        -- View configuration
        view = {
          width = 35,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        
        -- Renderer with compatible icons
        renderer = {
          add_trailing = false,
          group_empty = true,
          highlight_git = true,
          full_name = false,
          highlight_opened_files = "name",
          root_folder_label = ":t",
          indent_width = 2,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "+",
              edge = "|",
              item = "|",
              none = " ",
            },
          },
          icons = {
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " -> ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "F",
              symlink = "L",
              bookmark = "B",
              folder = {
                arrow_closed = ">",
                arrow_open = "v",
                default = "D",
                open = "O",
                empty = "E",
                empty_open = "e",
                symlink = "S",
                symlink_open = "s",
              },
              git = {
                unstaged = "M",
                staged = "A",
                unmerged = "U",
                renamed = "R",
                untracked = "?",
                deleted = "D",
                ignored = "I",
              },
            },
          },
          special_files = { 
            "Cargo.toml", "Makefile", "README.md", "readme.md", 
            "CMakeLists.txt", ".gitignore" 
          },
        },
        
        -- Filters
        filters = {
          dotfiles = false,
          git_clean = false,
          no_buffer = false,
          custom = { ".DS_Store", "__pycache__", "node_modules", ".cache" },
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
        
        -- Performance
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
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer", silent = true })
      vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find File in Explorer", silent = true })
      vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", { desc = "Refresh Explorer", silent = true })
      
      -- Auto-open behaviors
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          local directory = vim.fn.isdirectory(data.file) == 1
          if directory then
            vim.cmd.cd(data.file)
            require("nvim-tree.api").tree.open()
          end
        end
      })
      
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            require("nvim-tree.api").tree.open()
          end
        end
      })
    end,
  },
  
  -- Web dev icons with fallback support
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("config.icons").setup()
    end,
  },
}
