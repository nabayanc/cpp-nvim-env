-- Key Mappings Configuration
-- Optimized for C++ development workflow

local keymap = vim.keymap.set

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", { silent = true })

-- Normal mode mappings
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Better line movement
keymap("n", "j", "gj", { desc = "Move down (display line)" })
keymap("n", "k", "gk", { desc = "Move up (display line)" })

-- Keep cursor centered when jumping
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Visual mode mappings
-- Stay in indent mode
keymap("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("v", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Visual Block mode
keymap("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move selection down" })
keymap("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move selection up" })
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move selection down" })
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move selection up" })

-- Leader key mappings
-- File operations
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>W", ":wa<CR>", { desc = "Save all files" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })
keymap("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })

-- Search and replace
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })
keymap("n", "<leader>sr", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word under cursor" })

-- Quick fix and location list
keymap("n", "<leader>co", ":copen<CR>", { desc = "Open quickfix" })
keymap("n", "<leader>cc", ":cclose<CR>", { desc = "Close quickfix" })
keymap("n", "<leader>cn", ":cnext<CR>", { desc = "Next quickfix item" })
keymap("n", "<leader>cp", ":cprevious<CR>", { desc = "Previous quickfix item" })

-- Tab management
keymap("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
keymap("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
keymap("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs" })

-- Split management
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equal split sizes" })
keymap("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })

-- Terminal
keymap("n", "<leader>tt", ":terminal<CR>", { desc = "Open terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- C++ specific mappings
-- Compile current file
keymap("n", "<leader>cc", ":!g++ -std=c++17 -Wall -Wextra -g % -o %:r<CR>", { desc = "Compile current C++ file" })
keymap("n", "<leader>cr", ":!./%:r<CR>", { desc = "Run compiled program" })

-- Build project (if cpp-build is available)
keymap("n", "<leader>cb", ":!cpp-build<CR>", { desc = "Build C++ project" })

-- Format code (will be overridden by LSP if available)
keymap("n", "<leader>f", "gg=G<C-o>", { desc = "Format current buffer" })

-- Toggle options
keymap("n", "<leader>on", ":set number!<CR>", { desc = "Toggle line numbers" })
keymap("n", "<leader>or", ":set relativenumber!<CR>", { desc = "Toggle relative numbers" })
keymap("n", "<leader>ow", ":set wrap!<CR>", { desc = "Toggle line wrap" })
keymap("n", "<leader>os", ":set spell!<CR>", { desc = "Toggle spell check" })

-- Diagnostic navigation (will be enhanced by LSP)
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })

-- Better command line editing
keymap("c", "<C-j>", "<Down>", { desc = "Next command" })
keymap("c", "<C-k>", "<Up>", { desc = "Previous command" })

-- Insert mode mappings
-- Quick escape
keymap("i", "jk", "<Esc>", { desc = "Quick escape" })
keymap("i", "kj", "<Esc>", { desc = "Quick escape" })

-- Navigation in insert mode
keymap("i", "<C-h>", "<Left>", { desc = "Move left" })
keymap("i", "<C-j>", "<Down>", { desc = "Move down" })
keymap("i", "<C-k>", "<Up>", { desc = "Move up" })
keymap("i", "<C-l>", "<Right>", { desc = "Move right" })
