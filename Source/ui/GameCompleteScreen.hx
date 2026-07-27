package ui;

import engine.Engine;
import game.Game;

class GameCompleteScreen extends UIScreen {
    public function new() {
        super();
        drawBackground(0x000000, 1);
        createTextField(0, 100, Engine.instance.screenWidth, "CONGRATULATIONS!", 56, 0xFFD700);
        createTextField(0, 200, Engine.instance.screenWidth, "You beat Level Monster!", 28, 0xFFFFFF);
        createTextField(0, 250, Engine.instance.screenWidth, "Final Score: " + Game.instance.score, 24, 0xFF813F);
        var centerX = Engine.instance.screenWidth / 2;
        createButton(centerX - 110, 320, 220, 50, "MAIN MENU", () -> Game.instance.returnToMenu());
    }
}
