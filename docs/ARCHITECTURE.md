# Architecture Documentation

This document describes the architecture of the Level Monster native Android edition.

## Engine Layer (`Source/engine/`)

### Engine.hx
The main game loop. Implements:
- **Fixed-timestep physics** at 60 Hz (STEP_SIZE = 1/60 second)
- **Accumulator pattern** for frame-rate-independent physics
- **Camera system** with target-following, smoothing, and shake
- **Input dispatch** (keyboard, mouse, touch)
- **Scene management** (load, transition, cleanup)
- **Time scaling** (for slow-mo effects)

### AssetManager.hx
Loads and caches all game assets. Key APIs:
- `getBitmapData(path)` — returns cached BitmapData
- `getSprite(resourceId, frame)` — gets a specific animation frame
- `getSound(resourceId)` — gets a sound by Stencyl resource ID
- `getText(path)` — gets text content (e.g., .fnt XML)
- `getBytes(path)` — gets raw bytes (e.g., .scn/.mbs)
- `getFont(resourceId)` — loads a BMFont by ID

Also contains the Stencyl resource ID → asset path mappings (extracted from `resources.mbs`):
- `actorTypeMap[590]` → Hero player
- `actorTypeMap[598]` → Trap door
- `actorTypeMap[661]` → Spike
- `soundMap[565]` → Jump sound
- `soundMap[568]` → Death sound
- etc.

### AudioManager.hx
Howler.js-compatible channel-based audio system. Key features:
- 16 channels for simultaneous sound effects
- Separate music channel with loop support
- Master/SFX/music volume control
- Mute toggle

### BitmapFont.hx
Loads and renders BMFont (AngelCode) XML format fonts. Used for all text rendering in the game.

## Game Layer (`Source/game/`)

### Game.hx
Top-level game state machine with states:
- `MENU` — Main menu screen
- `LEVEL_SELECT` — Level selection grid
- `PLAYING` — Active gameplay
- `PAUSED` — Pause menu overlay
- `LEVEL_COMPLETE` — Level complete screen
- `GAME_OVER` — Death screen
- `GAME_COMPLETE` — All levels beaten

Also handles:
- Save/load progress (via SharedObject)
- Score tracking
- Attempt counting
- Level unlocking

### Scene.hx
Represents a single game level. Contains:
- **4 render layers:** background, tile, actor, foreground
- **Tile grid:** 2D array of solid/empty flags
- **Actor list:** all entities in the scene
- **Camera bounds:** restricts camera to scene extents
- **Scene events:** per-scene logic handler

Per-frame:
1. Update scene events (traps, triggers)
2. Update all actors (physics, animation)
3. Check collisions (actor-vs-tile, actor-vs-actor)
4. Update camera to follow hero
5. Check win/lose conditions

### Actor.hx
Base entity class. Properties:
- **Physics:** velocity, acceleration, friction, gravity scale
- **Collision:** width, height, onGround, onWall, onCeiling flags
- **Animation:** sprite frames per state (idle, walk, jump, etc.)
- **Behaviors:** map of attached behavior objects (e.g., `JumpAndRunMovement`)
- **State:** alive, dead, recycled

Animation system uses Stencyl-style frame indices:
```haxe
actor.addAnimation("walk", [0, 1, 2, 3], 12, true);
actor.playAnimation("walk");
```

### SceneLoader.hx
Parses Stencyl binary scene formats:

**`.scn` format** (tilemap):
```
[4 bytes] total length (BE int32)
[4 bytes] reserved
[4 bytes] reserved
[4 bytes] flags (0xFFFFFFFF = empty scene)
[per row]:
  [1 byte] hasTiles (0 or 1)
  [if hasTiles:]
    [2 bytes] row tile count
    [per tile]:
      [2 bytes] tileX
      [2 bytes] tileY
      [2 bytes] tilesetID
      [2 bytes] tileIndex
```

**`.mbs` format** (scene metadata):
```
[8 bytes] magic (0x00000002 0xAF9290C0)
[4 bytes] data length
[4 bytes] reserved
[4 bytes] sceneWidth
[4 bytes] sceneHeight
[4 bytes] tileWidth
[4 bytes] tileHeight
[4 bytes] actor count
[per actor]:
  [4 bytes] actorTypeID
  [4 bytes] x
  [4 bytes] y
  [1 byte] layer
  ... (additional metadata)
```

### SceneEventsFactory.hx
Factory that creates per-scene event handlers. Each Level Devil scene has unique trap configurations — this factory dispatches to the appropriate handler based on scene ID.

### JumpAndRunMovement.hx
The player controller. Implements Stencyl's `Design_277_277_JumpandRunMovementmodified` behavior with:
- **Max running speed:** modifiable at runtime (Level Devil's signature mechanic — traps can slow you down)
- **Acceleration:** 0.8 px/frame² on ground, 0.48 in air (air mobility 60%)
- **Deceleration:** 0.7 px/frame²
- **Jump power:** 16 px/frame initial velocity
- **Variable jump height:** holding jump adds 0.4 px/frame² for up to 0.18s
- **Coyote time:** 0.15s after leaving ground
- **Jump buffer:** 0.15s before landing

## UI Layer (`Source/ui/`)

### UIManager.hx
Manages a stack of UI screens. Supports:
- `show(screen)` — replace current screen
- `showOverlay(screen)` — add overlay (e.g., pause menu on top of HUD)
- `clear()` — remove all UI

### UIScreen.hx
Base class for UI screens. Provides:
- `drawBackground(color, alpha)` — full-screen background
- `createButton(x, y, w, h, label, onClick)` — add a button
- `createTextField(x, y, w, text, size, color, center)` — add text

### Screens.hx
All concrete UI screens:
- `MainMenu` — title, Play, Level Select
- `LevelSelectScreen` — grid of unlockable levels
- `HUD` — in-game overlay (level #, attempts, score, mobile controls)
- `PauseMenu` — Resume / Restart / Main Menu
- `GameOverScreen` — Retry / Main Menu
- `LevelCompleteScreen` — Next Level / Main Menu
- `GameCompleteScreen` — final victory screen

### UIButton.hx / MobileControlButton.hx
Click/touch buttons. `MobileControlButton` supports press-and-hold for movement controls.

## Utils (`Source/utils/`)

### Input.hx
Global input state. Tracks:
- Per-key down/pressed/released state
- Mouse position and button state
- Touch position and active state
- Virtual mobile buttons (left, right, jump)
- Convenience methods: `isLeftDown()`, `isRightDown()`, `wasJumpPressed()`, `isJumpDown()`

### Time.hx
Global time tracking. `Time.deltaTime` and `Time.time` are updated by the engine each fixed timestep.

## Build System

### Project.xml
OpenFL project configuration. Key settings:
- Main class: `Main`
- App file: `LevelMonster`
- Window: 854×480, 60 FPS, landscape orientation
- Android: min SDK 26, target SDK 34
- Assets: bundled from `Assets/graphics`, `Assets/sfx`, `Assets/data`, `Assets/fonts`
- Architecture: arm64 + armv7

### Build scripts
- `scripts/build.sh` — Linux/macOS Android build
- `scripts/build.bat` — Windows Android build
- `scripts/build-desktop.sh` — Desktop test build

## Asset Pipeline

All 2,910 original assets are bundled directly into the APK:
- **2,357 PNG sprites** — 12.3 MB
- **93 BMFont files** — 1.6 MB
- **24 MP3 sounds** — 3.6 MB
- **460 scene files** — 1.1 MB

Total uncompressed: ~18.6 MB. APK compression brings this to ~12 MB.

The AssetManager loads assets on demand and caches them. The `IMG_BASE` variable (1x/1.5x/2x/4x) is chosen at startup based on screen DPI for optimal visual quality.

## Android Integration

### MainActivity.java
Extends `org.haxe.lime.GameActivity` (provided by Lime). Adds:
- Keep-screen-on flag during gameplay
- Back-button handling (delegates to engine)

### AndroidManifest.xml
- Package: `com.levelmonster.game`
- Min SDK: 26 (Android 8.0)
- Target SDK: 34 (Android 14)
- Landscape orientation
- Fullscreen theme
- Hardware acceleration
- Large heap for asset caching
- Vibrate permission (for haptic feedback)
- Wake lock permission (to keep screen on)

### Permissions
- `android.permission.VIBRATE` — haptic feedback on death
- `android.permission.WAKE_LOCK` — keep screen on during gameplay

No internet permission. No analytics. No ads. No tracking.
