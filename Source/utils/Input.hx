package utils;

import openfl.ui.Keyboard;

/**
 * Input — keyboard, mouse, multi-touch, mobile buttons.
 */
class Input {
    public static var keys:Map<Int, Bool> = new Map();
    public static var keysPressed:Map<Int, Bool> = new Map();
    public static var keysReleased:Map<Int, Bool> = new Map();

    public static var mouseX:Float = 0;
    public static var mouseY:Float = 0;
    public static var mouseDown:Bool = false;
    public static var mousePressed:Bool = false;
    public static var mouseReleased:Bool = false;

    public static var touchActive:Bool = false;
    public static var touchX:Float = 0;
    public static var touchY:Float = 0;

    // Multi-touch tracking
    public static var touchPoints:Map<Int, {x:Float, y:Float, active:Bool}> = new Map();

    // Back button
    public static var backPressed:Bool = false;

    // Mobile control buttons
    public static var leftButton:Bool = false;
    public static var rightButton:Bool = false;
    public static var jumpButton:Bool = false;
    public static var leftButtonPressed:Bool = false;
    public static var rightButtonPressed:Bool = false;
    public static var jumpButtonPressed:Bool = false;

    public static inline var KEY_LEFT = 37;
    public static inline var KEY_RIGHT = 39;
    public static inline var KEY_UP = 38;
    public static inline var KEY_DOWN = 40;
    public static inline var KEY_A = 65;
    public static inline var KEY_D = 68;
    public static inline var KEY_W = 87;
    public static inline var KEY_S = 83;
    public static inline var KEY_SPACE = 32;
    public static inline var KEY_ENTER = 13;
    public static inline var KEY_R = 82;
    public static inline var KEY_P = 80;
    public static inline var KEY_ESCAPE = 27;

    public static function setKey(keyCode:Int, down:Bool):Void {
        if (down) {
            if (!keys.exists(keyCode) || !keys.get(keyCode)) {
                keysPressed.set(keyCode, true);
            }
            keys.set(keyCode, true);
            if (keyCode == KEY_ESCAPE) backPressed = true;
        } else {
            if (keys.exists(keyCode) && keys.get(keyCode)) {
                keysReleased.set(keyCode, true);
            }
            keys.set(keyCode, false);
        }
    }

    public static function isKeyDown(keyCode:Int):Bool {
        return keys.exists(keyCode) && keys.get(keyCode);
    }

    public static function wasKeyPressed(keyCode:Int):Bool {
        return keysPressed.exists(keyCode) && keysPressed.get(keyCode);
    }

    public static function wasKeyReleased(keyCode:Int):Bool {
        return keysReleased.exists(keyCode) && keysReleased.get(keyCode);
    }

    public static function setMouseDown(down:Bool, x:Float, y:Float):Void {
        if (down && !mouseDown) mousePressed = true;
        if (!down && mouseDown) mouseReleased = true;
        mouseDown = down;
        mouseX = x;
        mouseY = y;
    }

    public static function setMousePosition(x:Float, y:Float):Void {
        mouseX = x;
        mouseY = y;
    }

    public static function setTouch(down:Bool, x:Float, y:Float, id:Int):Void {
        touchActive = down;
        touchX = x;
        touchY = y;
        setTouchPoint(id, x, y, down);
    }

    public static function setTouchPoint(id:Int, x:Float, y:Float, active:Bool):Void {
        touchPoints.set(id, {x: x, y: y, active: active});
    }

    public static function getTouchPoint(id:Int):{x:Float, y:Float, active:Bool} {
        return touchPoints.get(id);
    }

    public static function wasBackPressed():Bool { return backPressed; }

    public static function setMobileButton(button:String, pressed:Bool):Void {
        if (button == null) return;
        var b = button.toLowerCase();
        switch (b) {
            case "left":
                if (pressed && !leftButton) leftButtonPressed = true;
                leftButton = pressed;
            case "right":
                if (pressed && !rightButton) rightButtonPressed = true;
                rightButton = pressed;
            case "jump":
                if (pressed && !jumpButton) jumpButtonPressed = true;
                jumpButton = pressed;
        }
    }

    public static function isLeftDown():Bool {
        return isKeyDown(KEY_LEFT) || isKeyDown(KEY_A) || leftButton;
    }

    public static function isRightDown():Bool {
        return isKeyDown(KEY_RIGHT) || isKeyDown(KEY_D) || rightButton;
    }

    public static function wasJumpPressed():Bool {
        return wasKeyPressed(KEY_SPACE) || wasKeyPressed(KEY_UP) || wasKeyPressed(KEY_W) || jumpButtonPressed;
    }

    public static function isJumpDown():Bool {
        return isKeyDown(KEY_SPACE) || isKeyDown(KEY_UP) || isKeyDown(KEY_W) || jumpButton;
    }

    public static function update():Void {
        keysPressed = new Map();
        keysReleased = new Map();
        mousePressed = false;
        mouseReleased = false;
        leftButtonPressed = false;
        rightButtonPressed = false;
        jumpButtonPressed = false;
        backPressed = false;

        // Prune inactive touch points
        var toRemove = new Array<Int>();
        for (id in touchPoints.keys()) {
            var tp = touchPoints.get(id);
            if (tp == null || !tp.active) toRemove.push(id);
        }
        for (id in toRemove) touchPoints.remove(id);
    }
}
