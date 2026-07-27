package engine;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;

/**
 * AssetManager — loads and caches game assets.
 * Mirrors Stencyl's com.stencyl.api.Script.
 */
class AssetManager {
    public static var instance:AssetManager;

    private var bitmapCache:Map<String, BitmapData> = new Map();
    private var soundCache:Map<String, Sound> = new Map();
    private var textCache:Map<String, String> = new Map();
    private var byteCache:Map<String, ByteArray> = new Map();

    public static var IMG_BASE:String = "2x";
    public static var SCALE:Float = 2.0;

    public var soundMap:Map<Int, String> = new Map();

    public function new() {
        instance = this;
        loadResourceMappings();
    }

    public static function init():Void {
        new AssetManager();
    }

    private function loadResourceMappings():Void {
        soundMap.set(565, "sound-565");   // Jump
        soundMap.set(566, "sound-566");   // Land
        soundMap.set(568, "sound-568");   // Death
        soundMap.set(720, "sound-720");   // Button click
        soundMap.set(721, "sound-721");   // Menu move
        soundMap.set(726, "sound-726");   // Coin pickup
        soundMap.set(727, "sound-727");   // Switch
        soundMap.set(730, "sound-730");   // Door open
        soundMap.set(731, "sound-731");   // Trap activate
        soundMap.set(732, "sound-732");   // Spike
        soundMap.set(733, "sound-733");   // Fall
        soundMap.set(734, "sound-734");   // Background noise
        soundMap.set(735, "sound-735");   // Level start
        soundMap.set(736, "sound-736");   // Level complete
        soundMap.set(741, "sound-741");   // Boss sound
        soundMap.set(742, "sound-742");   // Special event
        soundMap.set(858, "sound-858");   // Music change
        soundMap.set(889, "sound-889");   // Trigger sound
        soundMap.set(890, "sound-890");   // Pickup
        soundMap.set(1075, "sound-1075"); // Music track 1
        soundMap.set(1076, "sound-1076"); // Music track 2
        soundMap.set(1077, "sound-1077"); // Music track 3
        soundMap.set(1078, "sound-1078"); // Music track 4
        soundMap.set(1079, "sound-1079"); // Music track 5
    }

    /**
     * Get a BitmapData. If useScale and path doesn't already start with
     * assets/graphics/, prepend the scale folder.
     */
    public function getBitmapData(path:String, useScale:Bool = true):BitmapData {
        var fullPath = path;
        if (useScale && !StringTools.startsWith(path, "assets/graphics/")) {
            fullPath = 'assets/graphics/$IMG_BASE/$path';
        }
        if (bitmapCache.exists(fullPath)) return bitmapCache.get(fullPath);
        var bmp = Assets.getBitmapData(fullPath);
        if (bmp != null) bitmapCache.set(fullPath, bmp);
        return bmp;
    }

    /**
     * Get a sprite by resource ID and frame.
     * Sprites are stored as sprite-<ID>-<frame>.png
     */
    public function getSprite(resourceId:Int, frame:Int):BitmapData {
        var path = 'sprite-$resourceId-$frame.png';
        return getBitmapData(path);
    }

    public function spriteExists(resourceId:Int, frame:Int):Bool {
        var path = 'assets/graphics/$IMG_BASE/sprite-$resourceId-$frame.png';
        return Assets.exists(path);
    }

    public function getSpriteFrameCount(resourceId:Int):Int {
        var count = 0;
        for (i in 0...32) {
            if (spriteExists(resourceId, i)) count++;
            else break;
        }
        return count;
    }

    public function getSound(resourceId:Int):Sound {
        var soundName = soundMap.get(resourceId);
        if (soundName == null) return null;
        var path = 'assets/sfx/$soundName.mp3';
        if (soundCache.exists(path)) return soundCache.get(path);
        var s = Assets.getSound(path);
        if (s != null) soundCache.set(path, s);
        return s;
    }

    public function getSoundByName(name:String):Sound {
        var path = 'assets/sfx/$name';
        if (soundCache.exists(path)) return soundCache.get(path);
        var s = Assets.getSound(path);
        if (s != null) soundCache.set(path, s);
        return s;
    }

    public function getText(path:String):String {
        if (textCache.exists(path)) return textCache.get(path);
        var t = Assets.getText(path);
        if (t != null) textCache.set(path, t);
        return t;
    }

    public function getBytes(path:String):ByteArray {
        if (byteCache.exists(path)) return byteCache.get(path);
        var b = Assets.getBytes(path);
        if (b != null) byteCache.set(path, b);
        return b;
    }

    public function exists(path:String):Bool {
        return Assets.exists(path);
    }

    public function getDefaultFont():BitmapFont {
        // Try multiple paths for the default font
        var fontText = getText("assets/graphics/default-font.fnt");
        var fontImg = getBitmapData("default-font.png", false);
        if (fontText != null && fontImg != null) {
            return BitmapFont.loadAngelCode(fontImg, fontText);
        }
        return null;
    }

    public function getFont(resourceId:Int):BitmapFont {
        var fontTextPath = 'assets/graphics/$IMG_BASE/font-$resourceId.fnt';
        var fontImgPath = 'font-$resourceId.png';
        var fontText = getText(fontTextPath);
        var fontImg = getBitmapData(fontImgPath);
        if (fontText != null && fontImg != null) {
            return BitmapFont.loadAngelCode(fontImg, fontText);
        }
        return getDefaultFont();
    }
}
