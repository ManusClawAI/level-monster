package ui;

import openfl.display.Shape;
import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.net.URLRequest;
import engine.Engine;
import game.Game;

class MainMenu extends UIScreen {
    private var titleLine1:TextField;
    private var titleLine2:TextField;
    private var pulseTime:Float = 0;

    public function new() {
        super();
        drawGradientBackground(0x0A0A2A, 0x000000);

        var sw = (Engine.instance != null && Engine.instance.screenWidth > 10) ? Engine.instance.screenWidth : 854;
        var centerX = sw / 2;

        titleLine1 = createTextField(0, 80, sw, "LEVEL", 72, 0xFF813F);
        titleLine2 = createTextField(0, 160, sw, "MONSTER", 72, 0xFF813F);

        createTextField(0, 260, sw, "A rage platformer by Interstellar Coders", 18, 0xAAAAAA);

        createButton(centerX - 110, 320, 220, 50, "PLAY", () -> {
            Game.instance.startNewGame();
        });

        createButton(centerX - 110, 380, 220, 50, "LEVEL SELECT", () -> {
            Game.instance.showLevelSelect();
        });

        createButton(centerX - 110, 450, 220, 40, "BUY ME A COFFEE", () -> {
            openCoffeeLink();
        });

        createTextField(0, Engine.instance.screenHeight - 30, sw, "v2.0.0 - Native Android Edition", 12, 0x666666);
    }

    private function openCoffeeLink():Void {
        try {
            openfl.Lib.getURL(new URLRequest("https://buymeacoffee.com/interstellarcoders"), "_blank");
        } catch (e:Dynamic) {}
    }

    private function drawGradientBackground(topColor:Int, bottomColor:Int):Void {
        var sw = Engine.instance.screenWidth;
        var sh = Engine.instance.screenHeight;
        var bg = new Shape();
        var matrix = new Matrix();
        matrix.createGradientBox(sw, sh, Math.PI / 2, 0, 0);
        bg.graphics.beginGradientFill(GradientType.LINEAR, [topColor, bottomColor], [1.0, 1.0], [0, 255], matrix);
        bg.graphics.drawRect(0, 0, sw, sh);
        bg.graphics.endFill();
        addChild(bg);
    }

    public override function update(dt:Float):Void {
        pulseTime += dt;
        var pulse = 1.0 + 0.025 * (1 - Math.cos(Math.PI * pulseTime));
        var sw = Engine.instance.screenWidth;
        var titleH = 72 + 10;

        if (titleLine1 != null) {
            titleLine1.scaleX = pulse;
            titleLine1.scaleY = pulse;
            titleLine1.x = (1 - pulse) * sw / 2;
            titleLine1.y = 80 + (1 - pulse) * titleH / 2;
        }
        if (titleLine2 != null) {
            titleLine2.scaleX = pulse;
            titleLine2.scaleY = pulse;
            titleLine2.x = (1 - pulse) * sw / 2;
            titleLine2.y = 160 + (1 - pulse) * titleH / 2;
        }
    }
}
