package game;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.geom.Rectangle;
import engine.Engine;

/**
 * Scene — game level container.
 * 4 layers: background, tiles, actors, foreground.
 * Renders tiles visually (colored rects as placeholder).
 */
class Scene extends Sprite {
    public var sceneId:Int;
    public var sceneWidth:Int = 854;
    public var sceneHeight:Int = 480;
    public var tileWidth:Int = 32;
    public var tileHeight:Int = 32;

    public var backgroundLayer:Sprite;
    public var tileLayer:Sprite;
    public var actorLayer:Sprite;
    public var foregroundLayer:Sprite;

    public var tiles:Array<Array<Int>>;
    private var tileSprite:Shape;

    public var actors:Array<Actor> = new Array();
    public var actorsByType:Map<Int, Array<Actor>> = new Map();
    public var hero:Actor;

    public var sceneEvents:Dynamic;
    public var sceneTime:Float = 0;
    public var sceneComplete:Bool = false;
    public var sceneFailed:Bool = false;

    public var cameraMinX:Float = 0;
    public var cameraMaxX:Float = 0;
    public var cameraMinY:Float = 0;
    public var cameraMaxY:Float = 0;

    public function new(sceneId:Int) {
        super();
        this.sceneId = sceneId;
        backgroundLayer = new Sprite();
        tileLayer = new Sprite();
        actorLayer = new Sprite();
        foregroundLayer = new Sprite();
        addChild(backgroundLayer);
        addChild(tileLayer);
        addChild(actorLayer);
        addChild(foregroundLayer);
    }

    public function load():Void {
        try {
            SceneLoader.load(this);
        } catch (e:Dynamic) {
            // Fallback to demo level if loader crashes
            SceneLoader.createDemoLevel(this);
        }

        renderTiles();

        try {
            sceneEvents = SceneEventsFactory.create(sceneId);
            if (sceneEvents != null) {
                sceneEvents.scene = this;
                sceneEvents.init();
            }
        } catch (e:Dynamic) {
            sceneEvents = null;
        }

        cameraMaxX = Math.max(0, sceneWidth - Engine.instance.screenWidth);
        cameraMaxY = Math.max(0, sceneHeight - Engine.instance.screenHeight);
    }

    /**
     * Render the tilemap visually using colored rectangles.
     * Solid tiles = dark gray with lighter border.
     */
    public function renderTiles():Void {
        if (tileSprite != null && tileLayer.contains(tileSprite)) {
            tileLayer.removeChild(tileSprite);
        }
        tileSprite = new Shape();
        if (tiles != null) {
            for (y in 0...tiles.length) {
                var row = tiles[y];
                if (row == null) continue;
                for (x in 0...row.length) {
                    if (row[x] != 0) {
                        var px = x * tileWidth;
                        var py = y * tileHeight;
                        // Fill
                        tileSprite.graphics.beginFill(0x444444, 1);
                        tileSprite.graphics.drawRect(px, py, tileWidth, tileHeight);
                        tileSprite.graphics.endFill();
                        // Border
                        tileSprite.graphics.lineStyle(1, 0x666666, 1);
                        tileSprite.graphics.drawRect(px, py, tileWidth, tileHeight);
                        tileSprite.graphics.lineStyle();
                    }
                }
            }
        }
        tileLayer.addChild(tileSprite);
    }

    public function update(dt:Float):Void {
        sceneTime += dt;

        if (sceneEvents != null && !sceneComplete && !sceneFailed) {
            try { sceneEvents.update(dt); } catch (e:Dynamic) {}
        }

        for (actor in actors) {
            if (actor != null && !actor.dead && !actor.recycled) {
                actor.update(dt);
            }
        }

        checkCollisions();

        // Camera follow with smoothing
        if (hero != null && hero.isAlive()) {
            var targetX = hero.x - Engine.instance.screenWidth / 2;
            var targetY = hero.y - Engine.instance.screenHeight / 2;
            targetX = Math.max(cameraMinX, Math.min(cameraMaxX, targetX));
            targetY = Math.max(cameraMinY, Math.min(cameraMaxY, targetY));
            Engine.instance.setCameraTarget(targetX, targetY);
        }

        if (hero != null && hero.dead && !sceneFailed) {
            sceneFailed = true;
            onSceneFailed();
        }
    }

    public function render():Void {}

    public function getTileAt(worldX:Float, worldY:Float):Int {
        if (tiles == null) return 0;
        var tx = Math.floor(worldX / tileWidth);
        var ty = Math.floor(worldY / tileHeight);
        if (ty < 0 || ty >= tiles.length) return 0;
        if (tx < 0 || tx >= tiles[ty].length) return 0;
        return tiles[ty][tx];
    }

    public function isSolidAt(worldX:Float, worldY:Float):Bool {
        return getTileAt(worldX, worldY) != 0;
    }

    public function setTileAt(worldX:Float, worldY:Float, value:Int):Void {
        if (tiles == null) return;
        var tx = Math.floor(worldX / tileWidth);
        var ty = Math.floor(worldY / tileHeight);
        if (ty < 0 || ty >= tiles.length) return;
        if (tx < 0 || tx >= tiles[ty].length) return;
        tiles[ty][tx] = value;
        renderTiles();
    }

    public function checkCollisions():Void {
        for (actor in actors) {
            if (actor == null || actor.dead || actor.recycled) continue;
            if (!actor.collideX && !actor.collideY) continue;
            checkActorTileCollision(actor);
        }

        for (i in 0...actors.length) {
            var a1 = actors[i];
            if (a1 == null || a1.dead || a1.recycled) continue;
            for (j in (i+1)...actors.length) {
                var a2 = actors[j];
                if (a2 == null || a2.dead || a2.recycled) continue;
                if (rectOverlap(a1.x - a1.actorWidth/2, a1.y - a1.actorHeight/2, a1.actorWidth, a1.actorHeight,
                                 a2.x - a2.actorWidth/2, a2.y - a2.actorHeight/2, a2.actorWidth, a2.actorHeight)) {
                    handleActorCollision(a1, a2);
                }
            }
        }
    }

    private function checkActorTileCollision(actor:Actor):Void {
        actor.onGround = false;
        actor.onWall = false;
        actor.onCeiling = false;

        if (tiles == null) return;

        var EPS = 0.001;
        var left = Math.floor((actor.x - actor.actorWidth/2 + EPS) / tileWidth);
        var right = Math.floor((actor.x + actor.actorWidth/2 - EPS) / tileWidth);
        var top = Math.floor((actor.y - actor.actorHeight/2 + EPS) / tileHeight);
        var bottom = Math.floor((actor.y + actor.actorHeight/2 - EPS) / tileHeight);

        for (ty in top...bottom+1) {
            for (tx in left...right+1) {
                if (ty < 0 || ty >= tiles.length) continue;
                if (tx < 0 || tx >= tiles[ty].length) continue;
                if (tiles[ty][tx] == 0) continue;

                var tileLeft = tx * tileWidth;
                var tileTop = ty * tileHeight;
                var tileRight = tileLeft + tileWidth;
                var tileBottom = tileTop + tileHeight;

                var overlapLeft = (actor.x + actor.actorWidth/2) - tileLeft;
                var overlapRight = tileRight - (actor.x - actor.actorWidth/2);
                var overlapTop = (actor.y + actor.actorHeight/2) - tileTop;
                var overlapBottom = tileBottom - (actor.y - actor.actorHeight/2);

                if (overlapLeft < 0 || overlapRight < 0 || overlapTop < 0 || overlapBottom < 0) continue;

                var minOverlap = Math.min(Math.min(overlapLeft, overlapRight), Math.min(overlapTop, overlapBottom));

                if (minOverlap == overlapTop && actor.yVelocity >= 0) {
                    actor.y = tileTop - actor.actorHeight/2;
                    actor.yVelocity = 0;
                    actor.onGround = true;
                } else if (minOverlap == overlapBottom && actor.yVelocity <= 0) {
                    actor.y = tileBottom + actor.actorHeight/2;
                    actor.yVelocity = 0;
                    actor.onCeiling = true;
                } else if (minOverlap == overlapLeft && actor.xVelocity > 0) {
                    actor.x = tileLeft - actor.actorWidth/2;
                    actor.xVelocity = 0;
                    actor.onWall = true;
                } else if (minOverlap == overlapRight && actor.xVelocity < 0) {
                    actor.x = tileRight + actor.actorWidth/2;
                    actor.xVelocity = 0;
                    actor.onWall = true;
                }
            }
        }
    }

    private function handleActorCollision(a1:Actor, a2:Actor):Void {
        if (sceneEvents != null) {
            try { sceneEvents.onActorCollision(a1, a2); } catch (e:Dynamic) {}
        }
    }

    private function rectOverlap(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Bool {
        return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
    }

    public function addActor(a:Actor):Void {
        actors.push(a);
        if (!actorsByType.exists(a.typeId)) actorsByType.set(a.typeId, new Array());
        actorsByType.get(a.typeId).push(a);
        actorLayer.addChild(a);
    }

    public function removeActor(a:Actor):Void {
        actors.remove(a);
        if (actorsByType.exists(a.typeId)) actorsByType.get(a.typeId).remove(a);
        if (actorLayer.contains(a)) actorLayer.removeChild(a);
    }

    public function getActorsOfType(typeId:Int):Array<Actor> {
        if (!actorsByType.exists(typeId)) return [];
        return actorsByType.get(typeId);
    }

    public function createActor(typeId:Int, x:Float, y:Float, layer:Int = 0):Actor {
        var a = new Actor(typeId);
        a.x = x;
        a.y = y;
        addActor(a);
        return a;
    }

    public function createRecycledActor(typeId:Int, x:Float, y:Float, layer:Int = 0):Actor {
        if (actorsByType.exists(typeId)) {
            for (a in actorsByType.get(typeId)) {
                if (a.recycled) {
                    a.reset(x, y);
                    return a;
                }
            }
        }
        return createActor(typeId, x, y, layer);
    }

    public function onSceneComplete():Void {
        sceneComplete = true;
        if (Engine.instance != null && Engine.instance.game != null) {
            Engine.instance.game.onSceneComplete();
        }
    }

    public function onSceneFailed():Void {
        sceneFailed = true;
        if (Engine.instance != null && Engine.instance.game != null) {
            Engine.instance.game.onSceneFailed();
        }
    }

    public function cleanup():Void {
        actors = [];
        actorsByType = new Map();
        hero = null;
        sceneEvents = null;
        tileSprite = null;
        backgroundLayer.removeChildren();
        tileLayer.removeChildren();
        actorLayer.removeChildren();
        foregroundLayer.removeChildren();
        removeChildren();
    }
}
