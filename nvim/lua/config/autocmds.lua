-- Auto Commands Configuration
-- Productivity and C++ development optimizations

-- Create augroup for better organization
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General autocommands
local general = augroup("General", { clear = true })

-- Highlight text on yank
autocmd("TextYankPost", {
  group = general,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Remove trailing whitespace",
})

-- Auto-save when focus is lost
autocmd("FocusLost", {
  group = general,
  pattern = "*",
  command = "silent! wa",
  desc = "Auto-save when focus lost",
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
  group = general,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Return to last edit position",
})

-- Auto-create missing directories
autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
  desc = "Auto-create missing directories",
})

-- C++ specific autocommands
local cpp_group = augroup("CppDev", { clear = true })

-- Set C++ file type for header files
autocmd({ "BufRead", "BufNewFile" }, {
  group = cpp_group,
  pattern = { "*.h", "*.hpp", "*.hxx" },
  command = "set filetype=cpp",
  desc = "Set C++ filetype for headers",
})

-- C++ specific settings
autocmd("FileType", {
  group = cpp_group,
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    
    -- Set include path for gf (go to file) command
    vim.opt_local.path:append("/usr/include,/usr/local/include")
    
    -- Enhanced syntax highlighting
    vim.opt_local.cindent = true
    vim.opt_local.cinoptions = "g0,:0,N-s,(0"
  end,
  desc = "C++ specific settings",
})

-- CMake files
autocmd({ "BufRead", "BufNewFile" }, {
  group = cpp_group,
  pattern = { "CMakeLists.txt", "*.cmake" },
  command = "set filetype=cmake",
  desc = "Set CMake filetype",
})

-- Makefile settings
autocmd("FileType", {
  group = cpp_group,
  pattern = "make",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
  desc = "Makefile settings (use tabs)",
})

-- Terminal autocommands
local terminal_group = augroup("Terminal", { clear = true })

-- Start terminal in insert mode
autocmd("TermOpen", {
  group = terminal_group,
  pattern = "*",
  command = "startinsert",
  desc = "Start terminal in insert mode",
})

-- Disable line numbers in terminal
autocmd("TermOpen", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
  desc = "Disable UI elements in terminal",
})

-- LSP autocommands
local lsp_group = augroup("LspConfig", { clear = true })

-- Format on save for C++ files if LSP is available
autocmd("BufWritePre", {
  group = lsp_group,
  pattern = { "*.cpp", "*.c", "*.h", "*.hpp" },
  callback = function()
    -- Only format if LSP is attached and supports formatting
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentFormattingProvider then
        vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
        break
      end
    end
  end,
  desc = "Format C++ files on save",
})

-- Show diagnostics on cursor hold
autocmd("CursorHold", {
  group = lsp_group,
  pattern = "*",
  callback = function()
    -- Only show if there are diagnostics and LSP is active
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #clients > 0 then
      local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
      if #diagnostics > 0 then
        vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
      end
    end
  end,
  desc = "Show diagnostics on cursor hold",
})

-- UI autocommands
local ui_group = augroup("UI", { clear = true })

-- Close certain windows with q
autocmd("FileType", {
  group = ui_group,
  pattern = { "help", "startuptime", "qf", "lspinfo", "man", "checkhealth" },
  command = "nnoremap <buffer><silent> q :close<CR>",
  desc = "Close special windows with q",
})

-- Equalize splits on resize
autocmd("VimResized", {
  group = ui_group,
  pattern = "*",
  command = "tabdo wincmd =",
  desc = "Equalize splits on resize",
})

-- Performance autocommands
local perf_group = augroup("Performance", { clear = true })

-- Limit syntax highlighting for large files
autocmd("BufReadPre", {
  group = perf_group,
  pattern = "*",
  callback = function()
    local file_size = vim.fn.getfsize(vim.fn.expand("<afile>"))
    if file_size > 1024 * 1024 then -- 1MB
      vim.opt_local.syntax = "off"
      vim.opt_local.wrap = false
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      print("Large file detected, some features disabled for performance")
    end
  end,
  desc = "Optimize for large files",
})

-- Build system integration
local build_group = augroup("BuildSystem", { clear = true })

-- Auto-detect compile_commands.json changes
autocmd({ "BufWritePost", "FileChangedShellPost" }, {
  group = build_group,
  pattern = "compile_commands.json",
  callback = function()
    -- Restart LSP to pick up new compile commands
    vim.cmd("LspRestart")
    print("Detected compile_commands.json change, restarted LSP")
  end,
  desc = "Restart LSP on compile_commands.json change",
})

-- Quick compile on save for single file projects
autocmd("BufWritePost", {
  group = build_group,
  pattern = { "*.cpp", "*.c" },
  callback = function()
    local file = vim.fn.expand("<afile>")
    local dir = vim.fn.expand("<afile>:p:h")
    
    -- Only auto-compile if no build system detected
    local has_cmake = vim.fn.filereadable(dir .. "/CMakeLists.txt") == 1
    local has_makefile = vim.fn.filereadable(dir .. "/Makefile") == 1
    local has_compile_commands = vim.fn.filereadable(dir .. "/compile_commands.json") == 1
    
    if not (has_cmake or has_makefile or has_compile_commands) then
      -- Simple compilation check (don't actually compile, just check syntax)
      vim.fn.system("g++ -std=c++17 -fsyntax-only " .. vim.fn.shellescape(file))
      if vim.v.shell_error == 0 then
        print("✓ Syntax check passed")
      else
        print("✗ Syntax errors detected")
      end
    end
  end,
  desc = "Quick syntax check for single files",
})
