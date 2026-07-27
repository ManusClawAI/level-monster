package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import lime.app.Application;
import engine.Engine;
import engine.AssetManager;
import engine.AudioManager;

/**
 * Main application — extends lime.app.Application.
 * OpenFL's ApplicationMain expects Main to be a lime.app.Application.
 */
class Main extends Application {
    public static var instance:Main;
    public static var engine:Engine;
    public static var stage:openfl.display.Stage;

    public function new() {
        super();
        instance = this;
    }

    public override function onWindowCreate():Void {
        super.onWindowCreate();
        stage = window.stage;
        AssetManager.init();
        AudioManager.init();
        engine = new Engine(stage);
        engine.start();
    }
}
