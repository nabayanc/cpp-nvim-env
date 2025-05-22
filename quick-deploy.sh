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
    chmod +x restore-shell-features.sh
    ./restore-shell-features.sh
else
    echo "❌ restore-shell-features.sh not found!"
    exit 1
fi

echo ""
echo "✅ Quick deployment complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Close terminal and SSH back in"
echo "  2. Try: cpp-init my-project"
echo "  3. Try: cd my-project && nvim ."
echo ""
echo "📚 See REFERENCE.md for all commands and shortcuts"
