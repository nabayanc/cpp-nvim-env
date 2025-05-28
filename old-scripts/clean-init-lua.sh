#!/bin/bash
echo "🧹 Cleaning up init.lua..."

# Remove the problematic icon loading lines
sed -i '/require("config\.icons")/d' ~/.config/nvim/init.lua
sed -i '/Load icon configuration/d' ~/.config/nvim/init.lua

# Also remove any leftover icon files
rm -f ~/.config/nvim/lua/config/icons.lua 2>/dev/null
rm -f ~/.config/nvim/lua/config/test-icons.lua 2>/dev/null
rm -f ~/.config/nvim/lua/config/theme-fallback.lua 2>/dev/null

echo "✅ Cleaned up init.lua"
echo "✅ Removed icon configuration files"
