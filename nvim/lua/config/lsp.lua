-- Manual LSP Configuration for Neovim 0.9.5
-- Works without nvim-lspconfig

-- LSP setup for C++ files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    local clangd_path = vim.fn.expand("~/.local/bin/clangd")
    
    if vim.fn.executable(clangd_path) == 1 then
      print("🚀 Starting clangd for " .. vim.fn.expand("%:t"))
      
      local client_id = vim.lsp.start({
        name = "clangd",
        cmd = { 
          clangd_path, 
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu"
        },
        root_dir = vim.fs.dirname(
          vim.fs.find({"compile_commands.json", ".git"}, { upward = true })[1]
        ) or vim.fn.getcwd(),
        capabilities = {
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = true,
                resolveSupport = {
                  properties = { "documentation", "detail", "additionalTextEdits" }
                }
              }
            }
          }
        },
        on_attach = function(client, bufnr)
          print("✅ clangd attached! LSP features active")
          
          -- LSP Keymaps
          local opts = { buffer = bufnr, silent = true }
          
          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          
          -- Information
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          
          -- Actions
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
          
          -- Workspace
          vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          
          -- Type definition
          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
        end,
      })
      
      if client_id then
        print("✓ clangd client started (ID: " .. client_id .. ")")
      else
        print("✗ Failed to start clangd client")
      end
    else
      print("❌ clangd not found at: " .. clangd_path)
      print("Run setup.sh to install clangd")
    end
  end,
})

-- Enhanced diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Auto-format on save for C++ files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.c", "*.h", "*.hpp" },
  callback = function()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentFormattingProvider then
        vim.lsp.buf.format({ async = false })
        break
      end
    end
  end,
})
