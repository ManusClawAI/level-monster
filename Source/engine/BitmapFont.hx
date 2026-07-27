package engine;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * BitmapFont — BMFont (AngelCode) XML format loader.
 * Uses haxe.xml.Access (not deprecated Fast).
 */
class BitmapFont {
    public var texture:BitmapData;
    public var info_face:String;
    public var info_size:Int;
    public var common_lineHeight:Int;
    public var common_base:Int;
    public var common_scaleW:Int;
    public var common_scaleH:Int;
    public var chars:Map<Int, CharDef> = new Map();
    public var kernings:Map<String, Int> = new Map();
    public var isDefault:Bool = false;

    public function new() {}

    public static function loadAngelCode(texture:BitmapData, fntText:String):BitmapFont {
        var font = new BitmapFont();
        font.texture = texture;
        try {
            var xml = Xml.parse(fntText);
            var fast = new haxe.xml.Access(xml.firstElement());

            if (fast.hasNode.info) {
                var info = fast.node.info;
                if (info.has.face) font.info_face = info.att.face;
                if (info.has.size) font.info_size = Std.parseInt(info.att.size);
            }

            if (fast.hasNode.common) {
                var common = fast.node.common;
                if (common.has.lineHeight) font.common_lineHeight = Std.parseInt(common.att.lineHeight);
                if (common.has.base) font.common_base = Std.parseInt(common.att.base);
                if (common.has.scaleW) font.common_scaleW = Std.parseInt(common.att.scaleW);
                if (common.has.scaleH) font.common_scaleH = Std.parseInt(common.att.scaleH);
            }

            if (fast.hasNode.chars) {
                for (charNode in fast.node.chars.nodes.char) {
                    var def = new CharDef();
                    def.id = Std.parseInt(charNode.att.id);
                    def.x = Std.parseInt(charNode.att.x);
                    def.y = Std.parseInt(charNode.att.y);
                    def.width = Std.parseInt(charNode.att.width);
                    def.height = Std.parseInt(charNode.att.height);
                    def.xoffset = Std.parseInt(charNode.att.xoffset);
                    def.yoffset = Std.parseInt(charNode.att.yoffset);
                    def.xadvance = Std.parseInt(charNode.att.xadvance);
                    font.chars.set(def.id, def);
                }
            }

            if (fast.hasNode.kernings) {
                for (kernNode in fast.node.kernings.nodes.kerning) {
                    var first = Std.parseInt(kernNode.att.first);
                    var second = Std.parseInt(kernNode.att.second);
                    var amount = Std.parseInt(kernNode.att.amount);
                    font.kernings.set(first + "_" + second, amount);
                }
            }
        } catch (e:Dynamic) {
            // Font parsing failed — return empty font
        }
        return font;
    }

    public function getFontHeight(scale:Float = 1.0):Int {
        return Std.int(common_lineHeight * scale);
    }

    public function getTextWidth(text:String, scale:Float = 1.0):Int {
        var width = 0;
        for (i in 0...text.length) {
            var charCode = text.charCodeAt(i);
            var charDef = chars.get(charCode);
            if (charDef != null) width += Std.int(charDef.xadvance * scale);
        }
        return width;
    }

    public function drawText(target:BitmapData, x:Float, y:Float, text:String, scale:Float = 1.0, color:Int = 0xFFFFFF):Void {
        var curX = x;
        var curY = y;
        for (i in 0...text.length) {
            var charCode = text.charCodeAt(i);
            var charDef = chars.get(charCode);
            if (charDef != null) {
                var srcRect = new Rectangle(charDef.x, charDef.y, charDef.width, charDef.height);
                var dest = new Point(curX + charDef.xoffset * scale, curY + charDef.yoffset * scale);
                target.copyPixels(texture, srcRect, dest);
                curX += Std.int(charDef.xadvance * scale);
            } else if (charCode == 10) {
                curY += Std.int(common_lineHeight * scale);
                curX = x;
            }
        }
    }
}

class CharDef {
    public var id:Int;
    public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;
    public var xoffset:Int;
    public var yoffset:Int;
    public var xadvance:Int;
    public function new() {}
}
