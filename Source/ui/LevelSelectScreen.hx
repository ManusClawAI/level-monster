package ui;

import engine.Engine;
import game.Game;

class LevelSelectScreen extends UIScreen {
    public function new() {
        super();
        drawBackground(0x1a1a2e, 1);
        createTextField(0, 20, Engine.instance.screenWidth, "SELECT LEVEL", 36, 0xFF813F);

        var startX = 40;
        var startY = 80;
        var buttonSize = 60;
        var spacing = 10;
        var cols = Math.floor((Engine.instance.screenWidth - 80) / (buttonSize + spacing));

        var maxLevel = Game.instance.maxUnlockedLevel;
        for (i in 1...Game.instance.totalLevels + 1) {
            var col = (i - 1) % cols;
            var row = Math.floor((i - 1) / cols);
            var x = startX + col * (buttonSize + spacing);
            var y = startY + row * (buttonSize + spacing);

            var levelNum = i;
            var btn = createButton(x, y, buttonSize, buttonSize, Std.string(i), () -> {
                Game.instance.loadLevel(levelNum);
            });
            if (i > maxLevel) {
                btn.alpha = 0.4;
                btn.mouseEnabled = false;
            }
        }

        createButton(10, 10, 80, 40, "BACK", () -> {
            Game.instance.returnToMenu();
        });
    }
}
