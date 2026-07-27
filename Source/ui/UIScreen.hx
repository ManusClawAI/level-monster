package ui;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import engine.Engine;

class UIScreen extends Sprite {
    public function new() { super(); }
    public function onShow():Void {}
    public function onHide():Void {}
    public function update(dt:Float):Void {}

    public function drawBackground(color:Int = 0x000000, alpha:Float = 1.0):Void {
        var bg = new Shape();
        bg.graphics.beginFill(color, alpha);
        bg.graphics.drawRect(0, 0, Engine.instance.screenWidth, Engine.instance.screenHeight);
        bg.graphics.endFill();
        addChild(bg);
    }

    public function createButton(x:Float, y:Float, width:Float, height:Float, label:String, onClick:Void -> Void):UIButton {
        var btn = new UIButton(x, y, width, height, label, onClick);
        addChild(btn);
        return btn;
    }

    public function createTextField(x:Float, y:Float, width:Float, text:String, size:Int = 24, color:Int = 0xFFFFFF, center:Bool = true):TextField {
        var tf = new TextField();
        tf.x = x;
        tf.y = y;
        tf.width = width;
        tf.height = size + 10;
        var fmt = new TextFormat(null, size, color, false, false, false, null, null, center ? TextFormatAlign.CENTER : TextFormatAlign.LEFT);
        tf.defaultTextFormat = fmt;
        tf.text = text;
        tf.selectable = false;
        addChild(tf);
        return tf;
    }
}
