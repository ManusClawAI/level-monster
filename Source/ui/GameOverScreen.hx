package ui;

import engine.Engine;
import game.Game;

class GameOverScreen extends UIScreen {
    public function new() {
        super();
        drawBackground(0x000000, 0.7);
        createTextField(0, 100, Engine.instance.screenWidth, "YOU DIED", 56, 0xFF4444);
        createTextField(0, 180, Engine.instance.screenWidth, "Press R to retry", 24, 0xCCCCCC);
        var centerX = Engine.instance.screenWidth / 2;
        createButton(centerX - 110, 240, 220, 50, "RETRY", () -> Game.instance.retryLevel());
        createButton(centerX - 110, 310, 220, 50, "MAIN MENU", () -> Game.instance.returnToMenu());
    }
}
