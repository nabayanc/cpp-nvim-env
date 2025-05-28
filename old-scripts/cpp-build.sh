#!/bin/bash
# Simple C++ Build Helper

set -e

PROJECT_DIR="${1:-.}"
BUILD_DIR="$PROJECT_DIR/build"

echo "🔨 Building C++ project in $PROJECT_DIR..."

cd "$PROJECT_DIR"

if [[ -f "CMakeLists.txt" ]]; then
    echo "📋 CMake project detected"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
    make -j$(nproc)
    
    # Link compile_commands.json for LSP
    if [[ -f "compile_commands.json" ]]; then
        ln -sf "$BUILD_DIR/compile_commands.json" "$PROJECT_DIR/"
        echo "✅ Created compile_commands.json for LSP"
    fi
    
elif [[ -f "Makefile" ]]; then
    echo "📋 Makefile detected"
    make -j$(nproc)
    
else
    echo "📋 Single file compilation"
    CPP_FILES=($(find . -maxdepth 1 -name "*.cpp"))
    
    if [[ ${#CPP_FILES[@]} -eq 0 ]]; then
        echo "❌ No C++ files found"
        exit 1
    fi
    
    # Create compile_commands.json for LSP
    echo '[' > compile_commands.json
    for i in "${!CPP_FILES[@]}"; do
        file="${CPP_FILES[$i]}"
        if [[ $i -gt 0 ]]; then echo ',' >> compile_commands.json; fi
        cat >> compile_commands.json << EOJ
  {
    "directory": "$(pwd)",
    "command": "g++ -std=c++17 -Wall -Wextra -g $(basename "$file")",
    "file": "$file"
  }
EOJ
    done
    echo ']' >> compile_commands.json
    
    # Compile
    OUTPUT_NAME="${CPP_FILES[0]%.*}"
    g++ -std=c++17 -Wall -Wextra -g "${CPP_FILES[@]}" -o "$OUTPUT_NAME"
    echo "✅ Compiled to $OUTPUT_NAME"
fi

echo "🎉 Build complete!"
