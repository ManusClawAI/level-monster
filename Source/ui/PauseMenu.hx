package ui;

import engine.Engine;
import game.Game;

class PauseMenu extends UIScreen {
    public function new() {
        super();
        drawBackground(0x000000, 0.7);
        createTextField(0, 100, Engine.instance.screenWidth, "PAUSED", 48, 0xFF813F);
        var centerX = Engine.instance.screenWidth / 2;
        createButton(centerX - 110, 200, 220, 50, "RESUME", () -> Game.instance.resumeGame());
        createButton(centerX - 110, 270, 220, 50, "RESTART", () -> { Game.instance.resumeGame(); Game.instance.retryLevel(); });
        createButton(centerX - 110, 340, 220, 50, "MAIN MENU", () -> { Game.instance.resumeGame(); Game.instance.returnToMenu(); });
    }
}
