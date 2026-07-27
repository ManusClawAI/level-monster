#!/usr/bin/env bash
# build.sh - Build Level Monster for Android
#
# Prerequisites:
#   - Haxe 4.3+ installed (https://haxe.org/download/)
#   - OpenFL and Lime haxelibs installed:
#       haxelib install openfl
#       haxelib install lime
#       haxelib install actuate
#   - Android SDK with NDK installed
#   - Java JDK 17+
#
# Usage:
#   ./scripts/build.sh           # Debug build
#   ./scripts/build.sh release   # Release build (signed)
#   ./scripts/build.sh test      # Build and install on connected device

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

BUILD_TYPE="${1:-debug}"

echo "=========================================="
echo "Building Level Monster (Android)"
echo "Build type: $BUILD_TYPE"
echo "=========================================="

# Ensure haxelibs are installed
echo "Checking dependencies..."
haxelib install openfl 2>/dev/null || true
haxelib install lime 2>/dev/null || true
haxelib install actuate 2>/dev/null || true

# Setup Android SDK path (if not already set)
if [ -z "$ANDROID_SDK" ] && [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_SDK="$HOME/Android/Sdk"
    export ANDROID_NDK_ROOT="$ANDROID_SDK/ndk/$(ls $ANDROID_SDK/ndk | tail -1)"
    echo "Using Android SDK: $ANDROID_SDK"
    echo "Using Android NDK: $ANDROID_NDK_ROOT"
fi

# Run OpenFL setup
echo "Setting up OpenFL..."
haxelib run openfl setup 2>/dev/null || true

# Build
case "$BUILD_TYPE" in
    release)
        echo "Building release APK..."
        haxelib run openfl build android -DHXCPP_M64 -Drelease
        echo ""
        echo "Release APK: $PROJECT_DIR/export/android/bin/bin/LevelMonster-release.apk"
        ;;
    test)
        echo "Building and installing debug APK..."
        haxelib run openfl build android -DHXCPP_M64
        echo "Installing on connected device..."
        adb install -r "$PROJECT_DIR/export/android/bin/bin/LevelMonster-debug.apk"
        echo "Launching..."
        adb shell am start -n com.levelmonster.game/.MainActivity
        ;;
    *)
        echo "Building debug APK..."
        haxelib run openfl build android -DHXCPP_M64
        echo ""
        echo "Debug APK: $PROJECT_DIR/export/android/bin/bin/LevelMonster-debug.apk"
        ;;
esac

echo ""
echo "Build complete!"
