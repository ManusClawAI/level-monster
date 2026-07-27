package ui;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import engine.Engine;
import utils.Input;

/**
 * UIManager — screen stack with overlay support.
 * UI updates every frame (even when paused).
 */
class UIManager {
    public static var instance:UIManager;

    public var container:Sprite;
    private var currentScreen:UIScreen;
    private var overlays:Array<UIScreen> = new Array();

    public function new() {
        instance = this;
        container = Engine.instance.uiContainer;
    }

    public function show(screen:UIScreen):Void {
        if (currentScreen != null) {
            if (container.contains(currentScreen)) container.removeChild(currentScreen);
            currentScreen.onHide();
        }
        currentScreen = screen;
        screen.onShow();
        container.addChild(screen);
    }

    public function showOverlay(screen:UIScreen):Void {
        screen.onShow();
        container.addChild(screen);
        overlays.push(screen);
    }

    public function hideOverlay(screen:UIScreen):Void {
        if (container.contains(screen)) container.removeChild(screen);
        overlays.remove(screen);
        screen.onHide();
    }

    public function clearOverlays():Void {
        for (overlay in overlays) {
            if (container.contains(overlay)) container.removeChild(overlay);
            overlay.onHide();
        }
        overlays = [];
    }

    public function clear():Void {
        if (currentScreen != null) {
            if (container.contains(currentScreen)) container.removeChild(currentScreen);
            currentScreen.onHide();
            currentScreen = null;
        }
        clearOverlays();
    }

    public function getCurrentScreen():UIScreen { return currentScreen; }

    public function hasScreenOfType(className:String):Bool {
        if (currentScreen != null && matchesType(currentScreen, className)) return true;
        for (overlay in overlays) {
            if (matchesType(overlay, className)) return true;
        }
        return false;
    }

    private static function matchesType(screen:UIScreen, className:String):Bool {
        if (screen == null || className == null) return false;
        var fullName = Type.getClassName(Type.getClass(screen));
        if (fullName == className) return true;
        var lastDot = fullName.lastIndexOf(".");
        var simple = (lastDot >= 0) ? fullName.substr(lastDot + 1) : fullName;
        return simple == className;
    }

    public function update(dt:Float):Void {
        if (currentScreen != null) currentScreen.update(dt);
        for (overlay in overlays) overlay.update(dt);
    }
}
