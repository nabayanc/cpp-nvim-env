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
