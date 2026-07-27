package ui;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
 * UIButton — clickable button.
 * Always registers touch events (Android needs them).
 */
class UIButton extends Sprite {
    public var label:String;
    public var onClick:Void -> Void;
    public var normalColor:Int = 0xFF813F;
    public var hoverColor:Int = 0xFFA070;
    public var pressedColor:Int = 0xCC6630;
    public var bg:Shape;
    public var textField:TextField;
    public var isPressed:Bool = false;
    public var btnWidth:Float;
    public var btnHeight:Float;

    public function new(x:Float, y:Float, width:Float, height:Float, label:String, onClick:Void -> Void) {
        super();
        this.x = x;
        this.y = y;
        this.btnWidth = width;
        this.btnHeight = height;
        this.label = label;
        this.onClick = onClick;

        bg = new Shape();
        drawBackground(normalColor);
        addChild(bg);

        textField = new TextField();
        textField.width = width;
        textField.height = height;
        textField.x = 0;
        textField.y = (height - 24) / 2;
        var fmt = new TextFormat(null, 24, 0xFFFFFF, true, false, false, null, null, TextFormatAlign.CENTER);
        textField.defaultTextFormat = fmt;
        textField.text = label;
        textField.selectable = false;
        textField.mouseEnabled = false;
        addChild(textField);

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        addEventListener(MouseEvent.CLICK, onClickInternal);

        // Always register touch (Android)
        addEventListener(TouchEvent.TOUCH_TAP, onTouchTap);
        addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
        addEventListener(TouchEvent.TOUCH_END, onTouchEnd);

        this.buttonMode = true;
        this.useHandCursor = true;
    }

    private function drawBackground(color:Int):Void {
        bg.graphics.clear();
        bg.graphics.beginFill(color, 1);
        bg.graphics.drawRoundRect(0, 0, btnWidth, btnHeight, 8, 8);
        bg.graphics.endFill();
    }

    private function onMouseDown(e:MouseEvent):Void {
        isPressed = true;
        drawBackground(pressedColor);
    }

    private function onMouseUp(e:MouseEvent):Void {
        isPressed = false;
        drawBackground(hoverColor);
    }

    private function onMouseOver(e:MouseEvent):Void {
        if (!isPressed) drawBackground(hoverColor);
    }

    private function onMouseOut(e:MouseEvent):Void {
        if (!isPressed) drawBackground(normalColor);
    }

    private function onClickInternal(e:MouseEvent):Void {
        if (onClick != null) onClick();
    }

    private function onTouchTap(e:TouchEvent):Void {
        if (onClick != null) onClick();
    }

    private function onTouchBegin(e:TouchEvent):Void {
        isPressed = true;
        drawBackground(pressedColor);
    }

    private function onTouchEnd(e:TouchEvent):Void {
        isPressed = false;
        drawBackground(normalColor);
    }
}
