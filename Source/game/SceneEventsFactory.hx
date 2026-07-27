package game;

import engine.Engine;

/**
 * SceneEventsFactory — creates per-scene event handlers.
 */
class SceneEventsFactory {
    public static function create(sceneId:Int):Dynamic {
        return new DefaultSceneEvents();
    }
}

class DefaultSceneEvents {
    public var scene:Scene;
    private var timer:Float = 0;

    public function new() {}

    public function init():Void {}

    public function update(dt:Float):Void {
        timer += dt;

        if (scene.hero != null && scene.hero.isAlive()) {
            var heroBehavior = scene.hero.behaviors.get("Jump and Run Movement modified");
            if (heroBehavior != null) heroBehavior.update(dt);
        }

        checkExitCondition();
    }

    private function checkExitCondition():Void {
        if (scene == null || scene.hero == null) return;
        if (scene.hero.x > scene.sceneWidth - 50) {
            scene.onSceneComplete();
        }
    }

    public function onActorCollision(a1:Actor, a2:Actor):Void {
        if (a1 == scene.hero || a2 == scene.hero) {
            var other = (a1 == scene.hero) ? a2 : a1;
            // Enemy/trap = death
            if (other.typeId == 661 || other.typeId == 778 || other.typeId == 785 ||
                other.typeId == 787 || other.typeId == 857 || other.typeId == 936) {
                scene.hero.die();
            }
            // Coin = collect
            if (other.typeId == 670) {
                other.die();
                Engine.instance.game.score += 10;
                Engine.instance.game.coinsCollected++;
                var sound = engine.AssetManager.instance.getSound(726);
                if (sound != null) engine.AudioManager.instance.playOnChannel(sound, 3);
            }
        }
    }
}
