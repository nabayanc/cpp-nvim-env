#!/bin/bash

echo "🔧 Fixing nvim-tree to use Unicode icons instead of broken Nerd Font glyphs..."

# Replace the nvim-tree config to force Unicode icons
cat > ~/.config/nvim/lua/plugins/nvim-tree.lua << 'TREE_EOF'
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Setup web-devicons with Unicode fallbacks
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        devicons.setup({
          color_icons = true,
          default = true,
          strict = true,
          override = {
            default_icon = { icon = "📄", name = "Default" },
            txt = { icon = "📝", name = "Txt" },
            md = { icon = "📖", name = "Markdown" },
            json = { icon = "📋", name = "Json" },
            js = { icon = "📜", name = "JavaScript" },
            cpp = { icon = "⚙️", name = "Cpp" },
            c = { icon = "⚙️", name = "C" },
            h = { icon = "⚙️", name = "Header" },
            hpp = { icon = "⚙️", name = "HeaderPP" },
            py = { icon = "🐍", name = "Python" },
            sh = { icon = "🔧", name = "Shell" },
            zsh = { icon = "🔧", name = "Zsh" },
            html = { icon = "🌐", name = "Html" },
            css = { icon = "🎨", name = "Css" },
            dockerfile = { icon = "🐳", name = "Dockerfile" },
            yaml = { icon = "📄", name = "Yaml" },
            yml = { icon = "📄", name = "Yml" },
            xml = { icon = "📄", name = "Xml" },
            gitignore = { icon = "🚫", name = "Gitignore" },
          },
          override_by_filename = {
            [".gitignore"] = { icon = "🚫", name = "Gitignore" },
            ["README.md"] = { icon = "📚", name = "Readme" },
            ["Makefile"] = { icon = "⚙️", name = "Makefile" },
            ["makefile"] = { icon = "⚙️", name = "Makefile" },
            ["package.json"] = { icon = "📦", name = "PackageJson" },
            ["CMakeLists.txt"] = { icon = "⚙️", name = "CMake" },
          },
        })
      end
      
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        renderer = {
          icons = {
            webdev_colors = true,
            git_placement = "before",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "📄",
              symlink = "🔗",
              bookmark = "🔖",
              modified = "●",
              folder = {
                arrow_closed = "▶",
                arrow_open = "▼",
                default = "📁",
                open = "📂",
                empty = "📁",
                empty_open = "📂",
                symlink = "🔗",
                symlink_open = "🔗",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "⚠",
                renamed = "➜",
                untracked = "★",
                deleted = "🗑",
                ignored = "◌",
              },
            },
          },
          highlight_git = true,
          highlight_opened_files = "none",
          root_folder_modifier = ":~",
          indent_markers = {
            enable = false,
          },
        },
        view = { 
          width = 30, 
          side = "left",
          preserve_window_proportions = false,
        },
        git = { 
          enable = true, 
          ignore = false,
          timeout = 400,
        },
        actions = { 
          open_file = { 
            quit_on_open = false,
            resize_window = true,
          },
          use_system_clipboard = true,
        },
        filters = { 
          dotfiles = false,
          custom = { ".git", "node_modules", ".cache" },
          exclude = { ".gitignore" },
        },
        diagnostics = {
          enable = false,
        },
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
      })
    end,
  }
}
TREE_EOF

# Also update the icons.lua to be more explicit
cat > ~/.config/nvim/lua/config/icons.lua << 'ICON_EOF'
-- Force Unicode icons only
local M = {}

function M.setup()
  -- Disable nvim-web-devicons default setup to prevent Nerd Font usage
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    -- Force override all default icons with Unicode
    devicons.set_icon({
      default_icon = { icon = "📄", name = "Default" },
      txt = { icon = "📝", name = "Txt" },
      md = { icon = "📖", name = "Markdown" },
      json = { icon = "📋", name = "Json" },
      js = { icon = "📜", name = "JavaScript" },
      ts = { icon = "📜", name = "TypeScript" },
      cpp = { icon = "⚙️", name = "Cpp" },
      c = { icon = "⚙️", name = "C" },
      h = { icon = "⚙️", name = "Header" },
      hpp = { icon = "⚙️", name = "HeaderPP" },
      py = { icon = "🐍", name = "Python" },
      sh = { icon = "🔧", name = "Shell" },
      zsh = { icon = "🔧", name = "Zsh" },
      bash = { icon = "🔧", name = "Bash" },
      html = { icon = "🌐", name = "Html" },
      css = { icon = "🎨", name = "Css" },
      dockerfile = { icon = "🐳", name = "Dockerfile" },
      yaml = { icon = "📄", name = "Yaml" },
      yml = { icon = "📄", name = "Yml" },
      xml = { icon = "📄", name = "Xml" },
      gitignore = { icon = "🚫", name = "Gitignore" },
      go = { icon = "🔷", name = "Go" },
      rs = { icon = "🦀", name = "Rust" },
      lua = { icon = "🌙", name = "Lua" },
      vim = { icon = "📝", name = "Vim" },
    })
    print("✅ Unicode icons forced")
  else
    print("⚠️  nvim-web-devicons not available")
  end
end

return M
ICON_EOF

echo "✅ Fixed nvim-tree configuration"
echo "✅ Forced Unicode icons over Nerd Font glyphs"
echo ""
echo "🔄 Restart Neovim to see the fix"
echo "   The broken squares should now be proper Unicode icons"
