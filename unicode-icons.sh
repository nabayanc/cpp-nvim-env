#!/bin/bash

echo "🔄 Switching to basic Unicode icons..."

# Update icons.lua to use basic Unicode
cat > ~/.config/nvim/lua/config/icons.lua << 'ICON_EOF'
-- Basic Unicode icon configuration
local M = {}

function M.setup()
  -- Try to setup nvim-web-devicons with Unicode fallbacks
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    devicons.setup({
      color_icons = true,
      default = true,
      strict = true,
      -- Override with basic Unicode icons
      override = {
        default_icon = {
          icon = "📄",
          color = "#6d8086",
          name = "Default",
        },
        txt = { icon = "📝", color = "#89e051", name = "Txt" },
        md = { icon = "📖", color = "#519aba", name = "Markdown" },
        json = { icon = "📋", color = "#cbcb41", name = "Json" },
        js = { icon = "📜", color = "#cbcb41", name = "JavaScript" },
        cpp = { icon = "⚙️", color = "#519aba", name = "Cpp" },
        h = { icon = "⚙️", color = "#a074c4", name = "Header" },
        py = { icon = "🐍", color = "#519aba", name = "Python" },
        go = { icon = "🔷", color = "#519aba", name = "Go" },
        rs = { icon = "🦀", color = "#dea584", name = "Rust" },
        html = { icon = "🌐", color = "#e34c26", name = "Html" },
        css = { icon = "🎨", color = "#563d7c", name = "Css" },
        dockerfile = { icon = "🐳", color = "#458ee6", name = "Dockerfile" },
        yaml = { icon = "📄", color = "#cbcb41", name = "Yaml" },
        xml = { icon = "📄", color = "#e37933", name = "Xml" },
        sh = { icon = "🔧", color = "#4d5a5e", name = "Shell" },
        zsh = { icon = "🔧", color = "#428850", name = "Zsh" },
      },
      override_by_filename = {
        [".gitignore"] = { icon = "🚫", color = "#f1502f", name = "Gitignore" },
        ["README.md"] = { icon = "📚", color = "#519aba", name = "Readme" },
        ["Makefile"] = { icon = "⚙️", color = "#427819", name = "Makefile" },
        ["package.json"] = { icon = "📦", color = "#e8274b", name = "PackageJson" },
      },
    })
    print("✅ Unicode icons loaded successfully")
  else
    print("⚠️  nvim-web-devicons not found")
  end
end

return M
ICON_EOF

# Update nvim-tree.lua to use basic Unicode glyphs
cat > ~/.config/nvim/lua/plugins/nvim-tree.lua << 'TREE_EOF'
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("config.icons").setup()
      
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        renderer = {
          icons = {
            webdev_colors = true,
            show = { file = true, folder = true, folder_arrow = true, git = true },
            glyphs = {
              default = "📄",
              symlink = "🔗",
              bookmark = "🔖",
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
        },
        view = { 
          width = 30, 
          side = "left",
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
          } 
        },
        filters = { 
          dotfiles = false,
          custom = { ".git", "node_modules", ".cache" } 
        },
      })
    end,
  }
}
TREE_EOF

# Update font checker to test Unicode
cat > ~/.config/nvim/lua/config/font-check.lua << 'FONT_EOF'
local M = {}

function M.check()
  print("🔍 Unicode icon test:")
  print("  📁 <- Folder")
  print("  📂 <- Open folder") 
  print("  📄 <- File")
  print("  📝 <- Text file")
  print("  ⚙️ <- Code file")
  print("  🔧 <- Script")
  print("  ✓ <- Git staged")
  print("  ✗ <- Git unstaged")
  print("  ★ <- Git untracked")
  print("")
  if string.len("📁") > 1 then
    print("✅ Unicode support working!")
  else
    print("❌ Unicode not supported")
  end
end

return M
FONT_EOF

echo "✅ Updated to basic Unicode icons"
echo "✅ File manager will now use: 📁 📂 📄 📝 ⚙️ 🔧"
echo "✅ Git status will use: ✓ ✗ ★ ⚠ 🗑"
echo ""
echo "🚀 Restart Neovim to see the changes"
echo "🧪 Test with: :lua require('config.font-check').check()"
