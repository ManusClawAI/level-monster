package game;

import engine.Engine;
import engine.AssetManager;
import ui.UIManager;
import ui.MainMenu;
import ui.LevelSelectScreen;
import ui.PauseMenu;
import ui.HUD;
import ui.GameOverScreen;
import ui.LevelCompleteScreen;
import ui.GameCompleteScreen;
import utils.Input;

/**
 * Game — top-level state machine.
 * Level IDs map to scene IDs 14..247 (233 levels from original Stencyl project).
 */
class Game {
    public static var instance:Game;

    public var state:GameState = MENU;
    public var currentLevel:Int = 1;
    public var maxUnlockedLevel:Int = 1;
    public var gravity:Float = 1500;  // px/sec² (was 1.2 per-frame)

    public var score:Int = 0;
    public var attempts:Int = 0;
    public var coinsCollected:Int = 0;

    public var gameStarted:Bool = false;
    public var levelComplete:Bool = false;
    public var gameOver:Bool = false;

    // Scene IDs 14..247 = 233 levels
    public static var FIRST_SCENE_ID:Int = 14;
    public static var LAST_SCENE_ID:Int = 247;

    public function new() { instance = this; }

    public static function getTotalLevels():Int {
        return LAST_SCENE_ID - FIRST_SCENE_ID + 1;  // 234
    }

    public var totalLevels(get, never):Int;
    private function get_totalLevels():Int { return getTotalLevels(); }

    public function init():Void {
        if (gameStarted) return;
        loadProgress();
        state = MENU;
        UIManager.instance.show(new MainMenu());
    }

    public function startNewGame():Void {
        gameStarted = true;
        currentLevel = 1;
        attempts = 0;
        score = 0;
        coinsCollected = 0;
        loadLevel(currentLevel);
    }

    private function levelToSceneId(levelNum:Int):Int {
        return FIRST_SCENE_ID + (levelNum - 1);
    }

    public function loadLevel(levelId:Int):Void {
        state = PLAYING;
        currentLevel = levelId;
        levelComplete = false;
        gameOver = false;
        UIManager.instance.clear();
        var sceneId = levelToSceneId(levelId);
        Engine.instance.loadScene(sceneId);
        Engine.instance.cameraX = 0;
        Engine.instance.cameraY = 0;
        Engine.instance.cameraTargetX = 0;
        Engine.instance.cameraTargetY = 0;
        UIManager.instance.show(new HUD());
    }

    public function retryLevel():Void { loadLevel(currentLevel); }

    public function nextLevel():Void {
        currentLevel++;
        if (currentLevel > totalLevels) {
            state = GAME_COMPLETE;
            UIManager.instance.show(new GameCompleteScreen());
            return;
        }
        if (currentLevel > maxUnlockedLevel) {
            maxUnlockedLevel = currentLevel;
            saveProgress();
        }
        loadLevel(currentLevel);
    }

    public function returnToMenu():Void {
        state = MENU;
        if (Engine.instance.currentScene != null) {
            Engine.instance.currentScene.cleanup();
            Engine.instance.currentScene = null;
            Engine.instance.worldContainer.removeChildren();
        }
        UIManager.instance.clear();
        UIManager.instance.show(new MainMenu());
    }

    public function showLevelSelect():Void {
        state = LEVEL_SELECT;
        UIManager.instance.clear();
        UIManager.instance.show(new LevelSelectScreen());
    }

    public function update(dt:Float):Void {
        switch (state) {
            case MENU, LEVEL_SELECT:
            case PLAYING:
                if (Input.wasKeyPressed(Input.KEY_P)) pauseGame();
                if (Input.wasKeyPressed(Input.KEY_R)) retryLevel();
            case PAUSED:
                if (Input.wasKeyPressed(Input.KEY_P)) resumeGame();
            case LEVEL_COMPLETE:
                if (Input.wasKeyPressed(Input.KEY_ENTER) || Input.wasKeyPressed(Input.KEY_SPACE)) nextLevel();
            case GAME_OVER:
                if (Input.wasKeyPressed(Input.KEY_ENTER) || Input.wasKeyPressed(Input.KEY_SPACE)) retryLevel();
            case GAME_COMPLETE:
                if (Input.wasKeyPressed(Input.KEY_ENTER) || Input.wasKeyPressed(Input.KEY_SPACE)) returnToMenu();
        }
    }

    public function pauseGame():Void {
        if (state == PLAYING) {
            state = PAUSED;
            Engine.instance.paused = true;
            UIManager.instance.show(new PauseMenu());
        }
    }

    public function resumeGame():Void {
        if (state == PAUSED) {
            state = PLAYING;
            Engine.instance.paused = false;
            UIManager.instance.clear();
            UIManager.instance.show(new HUD());
        }
    }

    public function onSceneLoaded(sceneId:Int):Void {
        attempts++;
        playSoundSafe(735, 1);
    }

    public function onSceneComplete():Void {
        state = LEVEL_COMPLETE;
        playSoundSafe(736, 1);
        UIManager.instance.show(new LevelCompleteScreen());
    }

    public function onSceneFailed():Void {
        state = GAME_OVER;
        playSoundSafe(568, 1);
        Engine.instance.startShakingScreen(8, 0.5);
        UIManager.instance.show(new GameOverScreen());
    }

    private function playSoundSafe(soundId:Int, channel:Int):Void {
        try {
            var sound = AssetManager.instance.getSound(soundId);
            if (sound != null) engine.AudioManager.instance.playOnChannel(sound, channel);
        } catch (e:Dynamic) {}
    }

    public function handleBackButton():Void {
        switch (state) {
            case PLAYING: pauseGame();
            case PAUSED: resumeGame();
            case LEVEL_SELECT, GAME_COMPLETE: returnToMenu();
            case GAME_OVER: retryLevel();
            case LEVEL_COMPLETE: nextLevel();
            case MENU:
                try { lime.system.System.exit(0); } catch (e:Dynamic) {
                    if (Engine.instance != null) Engine.instance.running = false;
                }
        }
    }

    public function saveProgress():Void {
        try {
            var saved = openfl.net.SharedObject.getLocal("levelmonster_save");
            saved.data.maxUnlockedLevel = maxUnlockedLevel;
            saved.data.totalScore = score;
            saved.flush();
        } catch (e:Dynamic) {}
    }

    public function loadProgress():Void {
        try {
            var saved = openfl.net.SharedObject.getLocal("levelmonster_save");
            if (saved.data.maxUnlockedLevel != null) maxUnlockedLevel = saved.data.maxUnlockedLevel;
            if (saved.data.totalScore != null) score = saved.data.totalScore;
        } catch (e:Dynamic) {}
    }
}

enum GameState {
    MENU;
    LEVEL_SELECT;
    PLAYING;
    PAUSED;
    LEVEL_COMPLETE;
    GAME_OVER;
    GAME_COMPLETE;
}
