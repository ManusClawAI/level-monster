package ui;

import engine.Engine;
import game.Game;

class LevelCompleteScreen extends UIScreen {
    public function new() {
        super();
        drawBackground(0x000000, 0.7);
        createTextField(0, 100, Engine.instance.screenWidth, "LEVEL COMPLETE!", 48, 0x44FF44);
        createTextField(0, 180, Engine.instance.screenWidth, "Press SPACE for next level", 24, 0xCCCCCC);
        var centerX = Engine.instance.screenWidth / 2;
        createButton(centerX - 110, 240, 220, 50, "NEXT LEVEL", () -> Game.instance.nextLevel());
        createButton(centerX - 110, 310, 220, 50, "MAIN MENU", () -> Game.instance.returnToMenu());
    }
}
