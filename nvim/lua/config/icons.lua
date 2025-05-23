-- Enhanced Icon Configuration
-- For terminals with Unicode/Nerd Font support

local M = {}

M.setup = function()
  -- Try to set up nvim-web-devicons with enhanced icons
  local icons_ok, icons = pcall(require, "nvim-web-devicons")
  
  if icons_ok then
    icons.setup({
      override = {
        cpp = { icon = "", color = "#519aba", name = "Cpp" },
        c = { icon = "", color = "#519aba", name = "C" },
        h = { icon = "", color = "#a074c4", name = "H" },
        hpp = { icon = "", color = "#a074c4", name = "Hpp" },
        cmake = { icon = "", color = "#6d8086", name = "CMake" },
        txt = { icon = "", color = "#89e051", name = "Txt" },
        md = { icon = "", color = "#519aba", name = "Md" },
        json = { icon = "", color = "#cbcb41", name = "Json" },
        js = { icon = "", color = "#cbcb41", name = "Js" },
        py = { icon = "", color = "#519aba", name = "Py" },
        gitignore = { icon = "", color = "#41535b", name = "GitIgnore" },
        makefile = { icon = "", color = "#6d8086", name = "Makefile" },
      },
      default = true,
    })
    return true
  end
  
  return false
end

M.get_file_icon = function(filename, extension)
  local icons_ok, icons = pcall(require, "nvim-web-devicons")
  if icons_ok then
    return icons.get_icon(filename, extension)
  end
  
  -- Fallback icons
  local ext_icons = {
    cpp = "", c = "", h = "", hpp = "",
    cmake = "", txt = "", md = "",
    json = "", js = "", py = "",
    gitignore = "", makefile = "",
  }
  
  return ext_icons[extension] or "", "#ffffff"
end

return M
