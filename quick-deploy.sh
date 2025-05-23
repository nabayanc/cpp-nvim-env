#!/bin/bash
# Quick Deployment Script for New SSH Nodes
# Run this after cloning the repository

set -e

echo "🚀 Quick deployment starting..."

# Check system compatibility
echo "📋 System check:"
echo "  OS: $(uname -s)"
echo "  Architecture: $(uname -m)"
echo "  User: $(whoami)"
echo "  Home: $HOME"
echo ""

# Run main setup
echo "🔧 Installing development tools..."
if [[ -f "setup.sh" ]]; then
    chmod +x setup.sh
    ./setup.sh
else
    echo "❌ setup.sh not found!"
    exit 1
fi

# Apply shell enhancements
echo "🎨 Enhancing shell..."
if [[ -f "restore-shell-features.sh" ]]; then

# Fix file icons
if [[ -f "fix-file-icons.sh" ]]; then
    chmod +x fix-file-icons.sh
    echo "🎨 Fixing file icons..."
    echo "y" | ./fix-file-icons.sh
fi
    chmod +x restore-shell-features.sh

# Fix file icons
if [[ -f "fix-file-icons.sh" ]]; then
    chmod +x fix-file-icons.sh
    echo "🎨 Fixing file icons..."
    echo "y" | ./fix-file-icons.sh
fi
    ./restore-shell-features.sh

# Fix file icons
if [[ -f "fix-file-icons.sh" ]]; then
    chmod +x fix-file-icons.sh
    echo "🎨 Fixing file icons..."
    echo "y" | ./fix-file-icons.sh
fi
else
    echo "❌ restore-shell-features.sh not found!"

# Fix file icons
if [[ -f "fix-file-icons.sh" ]]; then
    chmod +x fix-file-icons.sh
    echo "🎨 Fixing file icons..."
    echo "y" | ./fix-file-icons.sh
fi
    exit 1
fi

./fix-tree-icons.sh

echo ""
echo "✅ Quick deployment complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Close terminal and SSH back in"
echo "  2. Try: cpp-init my-project"
echo "  3. Try: cd my-project && nvim ."
echo ""
echo "📚 See REFERENCE.md for all commands and shortcuts"
