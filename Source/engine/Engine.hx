package engine;

import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
import openfl.system.Capabilities;
import game.Game;
import game.Scene;
import game.Actor;
import ui.UIManager;
import utils.Input;
import utils.Time;

/**
 * The core engine — Stencyl-compatible runtime.
 * Fixed-timestep loop (60 Hz), camera with shake/zoom,
 * input dispatch, scene management.
 */
class Engine {
    public static var instance:Engine;

    public var stage:Stage;
    public var game:Game;
    public var currentScene:Scene;
    public var container:Sprite;
    public var worldContainer:Sprite;
    public var uiContainer:Sprite;

    public static inline var STEP_SIZE:Float = 1.0 / 60.0;
    private var accumulator:Float = 0;
    private var lastTime:Float = 0;

    public var timeScale:Float = 1.0;
    public var paused:Bool = false;
    public var running:Bool = false;
    public var frameCount:Int = 0;

    // Camera
    public var cameraX:Float = 0;
    public var cameraY:Float = 0;
    public var cameraTargetX:Float = 0;
    public var cameraTargetY:Float = 0;
    public var cameraShakeIntensity:Float = 0;
    public var cameraShakeTimer:Float = 0;
    public var cameraZoom:Float = 1.0;

    public var screenWidth:Int = 854;
    public var screenHeight:Int = 480;

    private var inputAttached:Bool = false;
    private var resizeAttached:Bool = false;

    public function new(stage:Stage) {
        instance = this;
        this.stage = stage;
        refreshScreenSize();

        container = new Sprite();
        worldContainer = new Sprite();
        uiContainer = new Sprite();
        container.addChild(worldContainer);
        container.addChild(uiContainer);
        stage.addChild(container);

        setupInput();
    }

    private function refreshScreenSize():Void {
        try {
            var w = stage.stageWidth;
            var h = stage.stageHeight;
            if (w > 10) screenWidth = w;
            if (h > 10) screenHeight = h;
        } catch (e:Dynamic) {}
    }

    private function setupInput():Void {
        if (inputAttached) return;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
        stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(Event.RESIZE, onResize);
        inputAttached = true;
        resizeAttached = true;
    }

    public function start():Void {
        new UIManager();
        game = new Game();
        game.init();
        running = true;
        lastTime = getTime();
        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function getTime():Float {
        return openfl.Lib.getTimer() / 1000.0;
    }

    private function onEnterFrame(_):Void {
        var currentTime = getTime();
        var frameTime = currentTime - lastTime;
        lastTime = currentTime;
        if (frameTime > 0.25) frameTime = 0.25;
        frameTime *= timeScale;

        frameCount++;

        if (!paused && running) {
            accumulator += frameTime;
            while (accumulator >= STEP_SIZE) {
                update(STEP_SIZE);
                accumulator -= STEP_SIZE;
            }
        }

        // UI always updates (even when paused)
        if (UIManager.instance != null) {
            UIManager.instance.update(frameTime);
        }

        render();
        Input.update();
    }

    private function update(dt:Float):Void {
        Time.deltaTime = dt;
        Time.time += dt;

        if (cameraShakeTimer > 0) {
            cameraShakeTimer -= dt;
            if (cameraShakeTimer <= 0) cameraShakeIntensity = 0;
        }

        if (game != null) game.update(dt);
        if (currentScene != null) currentScene.update(dt);

        // dt-scaled camera smoothing (5 per second = reaches 99% in ~1s)
        var lerp = Math.min(1, 5 * dt);
        cameraX += (cameraTargetX - cameraX) * lerp;
        cameraY += (cameraTargetY - cameraY) * lerp;
    }

    private function render():Void {
        var shakeX = 0.0;
        var shakeY = 0.0;
        if (cameraShakeIntensity > 0 && cameraShakeTimer > 0) {
            shakeX = (Math.random() - 0.5) * cameraShakeIntensity * 2;
            shakeY = (Math.random() - 0.5) * cameraShakeIntensity * 2;
        }
        // Apply camera translate scaled by zoom, then shake in screen pixels
        worldContainer.x = -cameraX * cameraZoom + shakeX;
        worldContainer.y = -cameraY * cameraZoom + shakeY;
        worldContainer.scaleX = cameraZoom;
        worldContainer.scaleY = cameraZoom;
    }

    public function loadScene(sceneId:Int):Void {
        if (currentScene != null) {
            currentScene.cleanup();
            worldContainer.removeChildren();
        }
        currentScene = new Scene(sceneId);
        currentScene.load();
        worldContainer.addChild(currentScene);
        currentScene.visible = true;
        if (game != null) game.onSceneLoaded(sceneId);
    }

    public function startShakingScreen(intensity:Float, duration:Float):Void {
        cameraShakeIntensity = intensity;
        cameraShakeTimer = duration;
    }

    public function setCameraTarget(x:Float, y:Float):Void {
        cameraTargetX = x;
        cameraTargetY = y;
    }

    public function getStageWidth():Int {
        refreshScreenSize();
        return screenWidth;
    }

    public function getStageHeight():Int {
        refreshScreenSize();
        return screenHeight;
    }

    private function onResize(_):Void {
        refreshScreenSize();
    }

    // Input handlers
    private function onKeyDown(e:KeyboardEvent):Void {
        Input.setKey(e.keyCode, true);
        if (e.keyCode == Keyboard.ESCAPE) {
            if (game != null) game.handleBackButton();
        }
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        Input.setKey(e.keyCode, false);
    }

    private function onMouseDown(e:MouseEvent):Void {
        Input.setMouseDown(true, e.stageX, e.stageY);
    }

    private function onMouseUp(e:MouseEvent):Void {
        Input.setMouseDown(false, e.stageX, e.stageY);
    }

    private function onMouseMove(e:MouseEvent):Void {
        Input.setMousePosition(e.stageX, e.stageY);
    }

    private function onTouchBegin(e:TouchEvent):Void {
        Input.setTouchPoint(e.touchPointID, e.stageX, e.stageY, true);
    }

    private function onTouchEnd(e:TouchEvent):Void {
        Input.setTouchPoint(e.touchPointID, e.stageX, e.stageY, false);
    }

    private function onTouchMove(e:TouchEvent):Void {
        Input.setTouchPoint(e.touchPointID, e.stageX, e.stageY, true);
    }

    public function cleanup():Void {
        if (inputAttached) {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
            stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            inputAttached = false;
        }
        if (resizeAttached) {
            stage.removeEventListener(Event.RESIZE, onResize);
            resizeAttached = false;
        }
        stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        if (currentScene != null) {
            currentScene.cleanup();
            currentScene = null;
        }
        if (container != null && stage.contains(container)) {
            stage.removeChild(container);
        }
        running = false;
    }
}
