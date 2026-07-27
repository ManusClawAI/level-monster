package ui;

import openfl.text.TextField;
import engine.Engine;
import game.Game;
import utils.Input;

class HUD extends UIScreen {
    private var levelText:TextField;
    private var attemptsText:TextField;
    private var scoreText:TextField;
    private var coinsText:TextField;
    private var pauseButton:UIButton;

    public function new() {
        super();

        var sw = Engine.instance.screenWidth;

        levelText = createTextField(10, 5, 220, "Level " + Game.instance.currentLevel + " / " + Game.instance.totalLevels, 18, 0xFFFFFF, false);
        attemptsText = createTextField(10, 28, 220, "Attempts: " + Game.instance.attempts, 14, 0xCCCCCC, false);
        scoreText = createTextField(sw / 2 - 90, 8, 180, "Score: " + Game.instance.score, 22, 0xFF813F, true);
        coinsText = createTextField(sw - 160, 8, 100, "Coins: " + Game.instance.coinsCollected, 18, 0xFFD700, false);

        pauseButton = new UIButton(sw - 50, 8, 40, 40, "II", () -> {
            Game.instance.pauseGame();
        });
        addChild(pauseButton);

        // Mobile controls — always show on Android (not just #if mobile)
        setupMobileControls();
    }

    private function setupMobileControls():Void {
        var sw = Engine.instance.screenWidth;
        var sh = Engine.instance.screenHeight;
        var minDim = Math.min(sw, sh);

        var dirSize = Math.min(80, minDim * 0.18);
        var dirY = sh - dirSize - 20;

        var leftBtn = new MobileControlButton(20, dirY, dirSize, dirSize, "<",
            () -> { Input.setMobileButton("left", true); },
            () -> { Input.setMobileButton("left", false); }
        );
        addChild(leftBtn);

        var rightBtn = new MobileControlButton(20 + dirSize + 10, dirY, dirSize, dirSize, ">",
            () -> { Input.setMobileButton("right", true); },
            () -> { Input.setMobileButton("right", false); }
        );
        addChild(rightBtn);

        var jumpSize = Math.min(110, minDim * 0.25);
        var jumpX = sw - jumpSize - 20;
        var jumpY = sh - jumpSize - 20;
        var jumpBtn = new MobileControlButton(jumpX, jumpY, jumpSize, jumpSize, "JUMP",
            () -> { Input.setMobileButton("jump", true); },
            () -> { Input.setMobileButton("jump", false); }
        );
        addChild(jumpBtn);
    }

    public override function update(dt:Float):Void {
        if (levelText != null) levelText.text = "Level " + Game.instance.currentLevel + " / " + Game.instance.totalLevels;
        if (attemptsText != null) attemptsText.text = "Attempts: " + Game.instance.attempts;
        if (scoreText != null) scoreText.text = "Score: " + Game.instance.score;
        if (coinsText != null) coinsText.text = "Coins: " + Game.instance.coinsCollected;
    }
}
