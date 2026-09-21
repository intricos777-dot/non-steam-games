#!/usr/bin/env bash
# game-launcher.sh — Build and launch any non-steam game
# Usage: ./game-launcher.sh <game-name>

set -e

GAMES_DIR="$(cd "$(dirname "$0")" && pwd)"
GAME="$1"

if [ -z "$GAME" ]; then
    echo "Available games:"
    for d in "$GAMES_DIR"/*/; do
        name=$(basename "$d")
        if [ "$name" != "non-steam" ] && [ -d "$d" ]; then
            echo "  - $name"
        fi
    done
    echo ""
    echo "Usage: $0 <game-name>"
    exit 0
fi

GAME_DIR="$GAMES_DIR/$GAME"

if [ ! -d "$GAME_DIR" ]; then
    echo "Game not found: $GAME"
    echo "Run without arguments to see available games."
    exit 1
fi

echo "=== Building $GAME ==="
cd "$GAME_DIR"

# Create build dir if missing
mkdir -p build
cd build

# Configure and build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)

# Find the main binary (heuristic: first executable in build dir that's not a test)
BINARY=$(find . -maxdepth 1 -type f -executable ! -name "*.so*" ! -name "test_*" ! -name "*test" ! -name "CMake*" | head -1)

if [ -z "$BINARY" ]; then
    echo "Build succeeded but no main binary found."
    echo "Binaries in build/:"
    find . -maxdepth 1 -type f -executable | head -10
    exit 0
fi

echo "=== Launching $BINARY ==="
echo ""
./"$BINARY"
