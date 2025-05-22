#!/bin/bash
# C++ Build Helper with LSP Support
# Automatically detects build system and generates compile_commands.json

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
PROJECT_DIR="${1:-.}"
BUILD_DIR="$PROJECT_DIR/build"
COMPILE_COMMANDS="$PROJECT_DIR/compile_commands.json"

# Default C++ flags
DEFAULT_CXX_FLAGS="-std=c++17 -Wall -Wextra -g -O0"
RELEASE_CXX_FLAGS="-std=c++17 -Wall -Wextra -O2 -DNDEBUG"

# Parse command line arguments
BUILD_TYPE="Debug"
CLEAN_BUILD=false
VERBOSE=false
JOBS=$(nproc)

show_help() {
    echo "Usage: $0 [PROJECT_DIR] [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -r, --release     Build in release mode"
    echo "  -c, --clean       Clean build (remove build directory)"
    echo "  -v, --verbose     Verbose output"
    echo "  -j, --jobs N      Number of parallel jobs (default: $JOBS)"
    echo "  -h, --help        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                  # Build current directory"
    echo "  $0 my-project       # Build specific project"
    echo "  $0 . --release      # Release build"
    echo "  $0 . --clean        # Clean and build"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--release)
            BUILD_TYPE="Release"
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*|--*)
            print_error "Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$1" || "$1" == "." ]]; then
                PROJECT_DIR="$(pwd)"
            else
                PROJECT_DIR="$1"
            fi
            shift
            ;;
    esac
done

# Validate project directory
if [[ ! -d "$PROJECT_DIR" ]]; then
    print_error "Project directory '$PROJECT_DIR' does not exist"
    exit 1
fi

cd "$PROJECT_DIR"
PROJECT_DIR="$(pwd)"
BUILD_DIR="$PROJECT_DIR/build"

print_status "Building C++ project in $PROJECT_DIR"
print_status "Build type: $BUILD_TYPE"

# Clean build if requested
if [[ "$CLEAN_BUILD" == true && -d "$BUILD_DIR" ]]; then
    print_status "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

# Detect build system and build accordingly
if [[ -f "$PROJECT_DIR/CMakeLists.txt" ]]; then
    print_status "Detected CMake project"
    
    cd "$BUILD_DIR"
    
    CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    
    if [[ "$VERBOSE" == true ]]; then
        CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_VERBOSE_MAKEFILE=ON"
    fi
    
    print_status "Running CMake configuration..."
    cmake $CMAKE_FLAGS "$PROJECT_DIR"
    
    print_status "Building with make (using $JOBS jobs)..."
    make -j"$JOBS"
    
    # Link compile_commands.json to project root
    if [[ -f "$BUILD_DIR/compile_commands.json" ]]; then
        ln -sf "$BUILD_DIR/compile_commands.json" "$PROJECT_DIR/"
        print_success "Created compile_commands.json for LSP"
    fi
    
elif [[ -f "$PROJECT_DIR/Makefile" ]]; then
    print_status "Detected existing Makefile"
    
    if [[ "$VERBOSE" == true ]]; then
        make -j"$JOBS" V=1
    else
        make -j"$JOBS"
    fi
    
    # Try to generate compile_commands.json using bear if available
    if command -v bear >/dev/null 2>&1; then
        print_status "Generating compile_commands.json with bear..."
        bear -- make clean && bear -- make -j"$JOBS"
    else
        print_warning "bear not available, LSP support may be limited"
        print_warning "Install bear for better LSP integration: apt install bear"
    fi
    
elif [[ -f "$PROJECT_DIR/meson.build" ]]; then
    print_status "Detected Meson project"
    
    if [[ ! -d "$BUILD_DIR" || "$CLEAN_BUILD" == true ]]; then
        print_status "Setting up Meson build..."
        meson setup "$BUILD_DIR" --buildtype="$(echo "$BUILD_TYPE" | tr '[:upper:]' '[:lower:]')"
    fi
    
    print_status "Building with Meson..."
    meson compile -C "$BUILD_DIR" -j "$JOBS"
    
    # Meson generates compile_commands.json by default
    if [[ -f "$BUILD_DIR/compile_commands.json" ]]; then
        ln -sf "$BUILD_DIR/compile_commands.json" "$PROJECT_DIR/"
        print_success "Created compile_commands.json for LSP"
    fi
    
else
    print_status "No build system detected, using direct compilation"
    
    # Find all C++ source files
    CPP_FILES=($(find "$PROJECT_DIR" -maxdepth 1 -name "*.cpp" -o -name "*.cc" -o -name "*.cxx"))
    C_FILES=($(find "$PROJECT_DIR" -maxdepth 1 -name "*.c"))
    
    if [[ ${#CPP_FILES[@]} -eq 0 && ${#C_FILES[@]} -eq 0 ]]; then
        print_error "No C/C++ source files found in $PROJECT_DIR"
        exit 1
    fi
    
    # Use appropriate compiler and flags
    if [[ ${#CPP_FILES[@]} -gt 0 ]]; then
        COMPILER="g++"
        if [[ "$BUILD_TYPE" == "Release" ]]; then
            FLAGS="$RELEASE_CXX_FLAGS"
        else
            FLAGS="$DEFAULT_CXX_FLAGS"
        fi
        SOURCE_FILES=("${CPP_FILES[@]}")
    else
        COMPILER="gcc"
        FLAGS="-Wall -Wextra -g"
        if [[ "$BUILD_TYPE" == "Release" ]]; then
            FLAGS="$FLAGS -O2 -DNDEBUG"
        fi
        SOURCE_FILES=("${C_FILES[@]}")
    fi
    
    # Generate compile_commands.json for LSP
    print_status "Generating compile_commands.json for LSP..."
    echo '[' > "$COMPILE_COMMANDS"
    
    for i in "${!SOURCE_FILES[@]}"; do
        file="${SOURCE_FILES[$i]}"
        filename=$(basename "$file")
        
        if [[ $i -gt 0 ]]; then
            echo ',' >> "$COMPILE_COMMANDS"
        fi
        
        cat >> "$COMPILE_COMMANDS" << EOF
  {
    "directory": "$PROJECT_DIR",
    "command": "$COMPILER $FLAGS $(basename "$file")",
    "file": "$file"
  }
EOF
    done
    
    echo ']' >> "$COMPILE_COMMANDS"
    print_success "Created compile_commands.json for LSP"
    
    # Determine output name
    if [[ ${#SOURCE_FILES[@]} -eq 1 ]]; then
        OUTPUT_NAME="${SOURCE_FILES[0]%.*}"
    else
        OUTPUT_NAME="main"
    fi
    
    # Compile
    print_status "Compiling ${#SOURCE_FILES[@]} source file(s)..."
    COMPILE_CMD="$COMPILER $FLAGS ${SOURCE_FILES[*]} -o $OUTPUT_NAME"
    
    if [[ "$VERBOSE" == true ]]; then
        echo "Command: $COMPILE_CMD"
    fi
    
    $COMPILE_CMD
    
    print_success "Compilation successful: $OUTPUT_NAME"
fi

# Final status
print_success "Build complete!"

# Show useful information
echo ""
print_status "Useful commands:"
echo "  nvim .                    # Open project in Neovim with LSP"
echo "  nvim +checkhealth         # Check LSP health"

if [[ -f "$PROJECT_DIR/compile_commands.json" ]]; then
    echo "  clangd --check=main.cpp   # Test LSP directly"
fi

if [[ -x "$PROJECT_DIR/main" ]]; then
    echo "  ./main                    # Run the compiled program"
elif [[ -x "$PROJECT_DIR/${SOURCE_FILES[0]%.*}" ]]; then
    echo "  ./${SOURCE_FILES[0]%.*}   # Run the compiled program"
fi

# Show build artifacts
echo ""
print_status "Build artifacts:"
if [[ -d "$BUILD_DIR" ]]; then
    echo "  Build directory: $BUILD_DIR"
fi

if [[ -f "$COMPILE_COMMANDS" ]]; then
    echo "  LSP config: $COMPILE_COMMANDS"
fi

# Find executables
EXECUTABLES=($(find "$PROJECT_DIR" -maxdepth 1 -type f -executable ! -name "*.sh" ! -name ".*"))
if [[ ${#EXECUTABLES[@]} -gt 0 ]]; then
    echo "  Executables: ${EXECUTABLES[*]}"
fi

print_success "Ready for development with full LSP support!"
