#!/usr/bin/env bash
# build-desktop.sh - Build Level Monster for desktop testing (Windows/Linux/macOS)
# Use this for quick testing without Android SDK.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

TARGET="${1:-windows}"

echo "=========================================="
echo "Building Level Monster (Desktop: $TARGET)"
echo "=========================================="

# Ensure haxelibs are installed
echo "Checking dependencies..."
haxelib install openfl 2>/dev/null || true
haxelib install lime 2>/dev/null || true
haxelib install actuate 2>/dev/null || true

# Build
echo "Building..."
haxelib run openfl build $TARGET

echo ""
echo "Build complete!"
echo "Executable: export/$TARGET/bin/LevelMonster*"
