package ui;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
 * MobileControlButton — press-and-hold button for touch controls.
 * Always registers touch events (Android needs them, not just #if mobile).
 */
class MobileControlButton extends Sprite {
    public var onPress:Void -> Void;
    public var onRelease:Void -> Void;
    public var isPressed:Bool = false;
    public var bg:Shape;
    public var labelField:TextField;
    public var buttonWidth:Float;
    public var buttonHeight:Float;

    public function new(x:Float, y:Float, w:Float, h:Float, label:String, onPress:Void -> Void, onRelease:Void -> Void) {
        super();
        this.x = x;
        this.y = y;
        this.buttonWidth = w;
        this.buttonHeight = h;
        this.onPress = onPress;
        this.onRelease = onRelease;

        bg = new Shape();
        addChild(bg);
        drawBackground(0x444444, 0.7);

        labelField = new TextField();
        labelField.width = w;
        labelField.height = h;
        labelField.x = 0;
        labelField.y = (h - 20) / 2;
        var fmt = new TextFormat(null, 20, 0xFFFFFF, true, false, false, null, null, TextFormatAlign.CENTER);
        labelField.defaultTextFormat = fmt;
        labelField.text = label;
        labelField.selectable = false;
        labelField.mouseEnabled = false;
        addChild(labelField);

        // Always register touch events (Android needs them)
        addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
        addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        addEventListener(TouchEvent.TOUCH_ROLL_OUT, onTouchEnd);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    }

    private function drawBackground(color:Int, alpha:Float):Void {
        bg.graphics.clear();
        bg.graphics.beginFill(color, alpha);
        bg.graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 12, 12);
        bg.graphics.endFill();
    }

    private function onMouseDown(e:MouseEvent):Void {
        isPressed = true;
        drawBackground(0xFF813F, 0.8);
        if (onPress != null) onPress();
    }

    private function onMouseUp(e:MouseEvent):Void {
        if (isPressed) {
            isPressed = false;
            drawBackground(0x444444, 0.7);
            if (onRelease != null) onRelease();
        }
    }

    private function onMouseOut(e:MouseEvent):Void {
        if (isPressed) {
            isPressed = false;
            drawBackground(0x444444, 0.7);
            if (onRelease != null) onRelease();
        }
    }

    private function onTouchBegin(e:TouchEvent):Void {
        e.stopPropagation();
        isPressed = true;
        drawBackground(0xFF813F, 0.8);
        if (onPress != null) onPress();
    }

    private function onTouchEnd(e:TouchEvent):Void {
        if (isPressed) {
            isPressed = false;
            drawBackground(0x444444, 0.7);
            if (onRelease != null) onRelease();
        }
    }
}
