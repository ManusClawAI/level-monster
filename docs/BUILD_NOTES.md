# Level Monster - Build Notes

## Quick Start

1. Install Haxe 4.3+ from https://haxe.org/download/
2. Install haxelibs:
   ```
   haxelib install openfl
   haxelib install lime
   haxelib install actuate
   haxelib run openfl setup
   ```
3. Install Android Studio (includes Android SDK + NDK)
4. Set environment variables:
   - `ANDROID_SDK` = path to Android SDK
   - `ANDROID_NDK_ROOT` = path to Android NDK
5. Run build:
   ```
   ./scripts/build.sh
   ```

## Common Build Issues

### "Could not find android.jar"
- Open Android Studio's SDK Manager
- Install Android SDK Platform 34 (Android 14)

### "NDK not configured"
- Install NDK side-by-side from SDK Manager
- Set `ANDROID_NDK_ROOT` environment variable

### "hxcpp compilation error"
- Ensure you have C++ build tools installed:
  - Linux: `sudo apt install build-essential`
  - macOS: `xcode-select --install`
  - Windows: Visual Studio Build Tools

### "OutOfMemoryError" during build
- Add to `Project.xml`:
  ```xml
  <haxeflag name="--macro" value="keep('com.stencyl.models')" />
  ```
- Or build only one architecture at a time:
  ```
  haxelib run openfl build android -DHXCPP_M64 -Darm64-only
  ```

## Build Targets

| Target       | Command                                | Output                          |
|--------------|----------------------------------------|---------------------------------|
| Android Debug  | `./scripts/build.sh`                 | `export/android/bin/bin/LevelMonster-debug.apk` |
| Android Release | `./scripts/build.sh release`        | `export/android/bin/bin/LevelMonster-release.apk` |
| Windows       | `./scripts/build-desktop.sh windows` | `export/windows/bin/LevelMonster.exe` |
| Linux         | `./scripts/build-desktop.sh linux`   | `export/linux/bin/LevelMonster` |
| macOS         | `./scripts/build-desktop.sh mac`     | `export/mac/bin/LevelMonster.app` |

## Signing a Release APK

1. Generate a keystore (one-time):
   ```
   keytool -genkey -v -keystore levelmonster.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias levelmonster
   ```
2. Add to `Project.xml`:
   ```xml
   <certificate path="levelmonster.keystore" alias="levelmonster" password="YOUR_PASSWORD" if="android" />
   ```
3. Build release:
   ```
   ./scripts/build.sh release
   ```

## Reducing APK Size

The current APK is ~12 MB. To reduce further:

1. Strip unused asset scales (only ship 2x):
   - Remove `Assets/graphics/1x`, `1.5x`, `4x` directories
   - Update `AssetManager.determineScale()` to always use `2x`

2. Compress PNGs more aggressively:
   ```
   find Assets -name "*.png" -exec optipng -o7 {} \;
   ```

3. Convert MP3s to lower bitrate:
   ```
   for f in Assets/sfx/*.mp3; do
     lame --mp3input -b 64 "$f" "/tmp/$(basename $f)"
     mv "/tmp/$(basename $f)" "$f"
   done
   ```

## Testing

### On a physical device
1. Enable USB debugging on your Android phone
2. Connect via USB
3. Verify: `adb devices`
4. Install + launch: `./scripts/build.sh test`

### On an emulator
1. Create an AVD with Android 8.0+ in Android Studio
2. Start the emulator
3. Install the APK:
   ```
   adb install -r export/android/bin/bin/LevelMonster-debug.apk
   ```

### Profiling
- Use Android Studio's CPU Profiler
- Or: `adb shell am start --profile start -n com.levelmonster.game/.MainActivity`
