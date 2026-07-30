package;

import openfl.display.Application;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import engine.Engine;
import engine.AssetManager;
import engine.AudioManager;

/**
 * Main application — extends openfl.display.Application.
 * ApplicationMain creates `new Main()` and calls createWindow/exec on it.
 * We override onWindowCreate to initialize the engine after the window is ready.
 */
class Main extends Application {
    public static var instance:Main;
    public static var engine:Engine;

    public function new() {
        super();
        instance = this;
    }

    public override function onWindowCreate():Void {
        super.onWindowCreate();
        // Window is now created, stage is available
        try {
            AssetManager.init();
            AudioManager.init();
            engine = new Engine(window.stage);
            engine.start();
        } catch (e:Dynamic) {
            trace("FATAL: Engine init failed: " + e);
        }
    }
}
