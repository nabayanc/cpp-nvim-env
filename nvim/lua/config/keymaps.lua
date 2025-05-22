-- Key Mappings Configuration
local keymap = vim.keymap.set

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
keymap("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease height" })
keymap("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase height" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Better line movement
keymap("n", "j", "gj", { desc = "Move down (display line)" })
keymap("n", "k", "gk", { desc = "Move up (display line)" })

-- Keep cursor centered
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
keymap("n", "n", "nzzzv", { desc = "Next search (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search (centered)" })

-- Visual mode - stay in indent mode
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("v", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "p", '"_dP', { desc = "Paste without yanking" })

-- File operations
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })

-- Search and replace
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlights" })

-- Splits
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertical" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Split horizontal" })
keymap("n", "<leader>sx", ":close<CR>", { desc = "Close split" })

-- Terminal
keymap("n", "<leader>tt", ":terminal<CR>", { desc = "Open terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- C++ specific
keymap("n", "<leader>cc", ":!g++ -std=c++17 -Wall -Wextra -g % -o %:r<CR>", { desc = "Compile file" })
keymap("n", "<leader>cb", ":!cpp-build<CR>", { desc = "Build project" })

-- Diagnostics
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Insert mode shortcuts
keymap("i", "jk", "<Esc>", { desc = "Quick escape" })
keymap("i", "kj", "<Esc>", { desc = "Quick escape" })
