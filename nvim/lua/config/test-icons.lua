-- Icon Test Utility
local M = {}

M.test_icons = function()
  print("=== Icon Test ===")
  
  local icons = require("config.icons")
  
  -- Test common file types
  local test_files = {
    {"main.cpp", "cpp"},
    {"main.c", "c"},
    {"header.h", "h"},
    {"CMakeLists.txt", "cmake"},
    {"README.md", "md"},
    {".gitignore", "gitignore"}
  }
  
  for _, file_info in ipairs(test_files) do
    local filename, ext = file_info[1], file_info[2]
    local icon, color = icons.get_file_icon(filename, ext)
    print(string.format("  %s %s", icon, filename))
  end
  
  print("=== End Test ===")
end

return M
