package game;

import engine.Engine;
import engine.AssetManager;
import openfl.utils.ByteArray;

/**
 * SceneLoader — parses Stencyl .scn and .mbs files.
 * Falls back to demo level on any parse error.
 */
class SceneLoader {
    public static function load(scene:Scene):Void {
        scene.sceneWidth = 854;
        scene.sceneHeight = 480;
        scene.tileWidth = 32;
        scene.tileHeight = 32;

        var scnPath = 'assets/data/scene-${scene.sceneId}.scn';
        var scnData = AssetManager.instance.getBytes(scnPath);

        var mbsPath = 'assets/data/scene-${scene.sceneId}.mbs';
        var mbsData = AssetManager.instance.getBytes(mbsPath);

        if (scnData != null) {
            try { parseScnFile(scene, scnData); } catch (e:Dynamic) {}
        }

        if (mbsData != null) {
            try { parseMbsFile(scene, mbsData); } catch (e:Dynamic) {}
        }

        if (scene.actors.length == 0) {
            createDemoLevel(scene);
        }

        // Always attach hero behavior
        if (scene.hero != null && !scene.hero.behaviors.exists("Jump and Run Movement modified")) {
            scene.hero.behaviors.set("Jump and Run Movement modified", new game.behaviors.JumpAndRunMovement(scene.hero));
        }

        scene.cameraMaxX = Math.max(0, scene.sceneWidth - Engine.instance.screenWidth);
        scene.cameraMaxY = Math.max(0, scene.sceneHeight - Engine.instance.screenHeight);
    }

    private static function parseScnFile(scene:Scene, data:ByteArray):Void {
        data.position = 0;
        if (data.length < 16) return;

        var totalLen = data.readInt();
        var reserved1 = data.readInt();
        var reserved2 = data.readInt();
        var flags = data.readInt();

        if (flags == -1 || data.length <= 16) {
            var tileCols = Std.int(Math.ceil(scene.sceneWidth / scene.tileWidth));
            var tileRows = Std.int(Math.ceil(scene.sceneHeight / scene.tileHeight));
            scene.tiles = [for (y in 0...tileRows) [for (x in 0...tileCols) 0]];
            return;
        }

        var tiles:Array<Array<Int>> = [];
        var maxCol = 0;
        var iter = 0;
        while (data.position < data.length && iter < 100000) {
            iter++;
            var rowHasTiles = data.readByte();
            if (rowHasTiles == 0) {
                tiles.push([]);
                continue;
            }
            var row = new Array<Int>();
            var rowTileCount = data.readShort();
            for (i in 0...rowTileCount) {
                var tileX = data.readShort();
                var tileY = data.readShort();
                var tileId = data.readShort();
                var tileIdx = data.readShort();
                if (tileX > maxCol) maxCol = tileX;
                while (row.length <= tileX) row.push(0);
                row[tileX] = 1;
            }
            tiles.push(row);
        }
        scene.tiles = tiles;
        scene.sceneWidth = (maxCol + 1) * scene.tileWidth;
        scene.sceneHeight = tiles.length * scene.tileHeight;
    }

    private static function parseMbsFile(scene:Scene, data:ByteArray):Void {
        data.position = 0;
        if (data.length < 24) return;

        var magic1 = data.readInt();
        var magic2 = data.readInt();
        var dataLength = data.readInt();
        var reserved = data.readInt();

        // Best-effort read of scene dimensions
        if (data.position + 8 <= data.length) {
            var sw = data.readInt();
            var sh = data.readInt();
            if (sw > 0 && sw < 10000) scene.sceneWidth = sw;
            if (sh > 0 && sh < 10000) scene.sceneHeight = sh;
        }

        if (data.position + 8 <= data.length) {
            var tw = data.readInt();
            var th = data.readInt();
            if (tw > 0 && tw < 1000) scene.tileWidth = tw;
            if (th > 0 && th < 1000) scene.tileHeight = th;
        }

        // Actor placements — best-effort
        try {
            if (data.position + 4 <= data.length) {
                var actorCount = data.readInt();
                if (actorCount > 0 && actorCount < 1000) {
                    for (i in 0...actorCount) {
                        if (data.position + 12 > data.length) break;
                        var actorTypeId = data.readInt();
                        var x = data.readInt();
                        var y = data.readInt();
                        var layer = data.readByte();
                        var actor = scene.createActor(actorTypeId, x, y, layer);
                        loadActorSprites(actor, actorTypeId);
                        if (actorTypeId == 590) scene.hero = actor;
                    }
                }
            }
        } catch (e:Dynamic) {}
    }

    /**
     * Auto-detect how many sprite frames this actor has and load them.
     */
    public static function loadActorSprites(actor:Actor, typeId:Int):Void {
        var frameCount = AssetManager.instance.getSpriteFrameCount(typeId);
        if (frameCount > 0) {
            actor.loadSpriteFrames('default', frameCount);
            actor.addAnimation('idle', [for (i in 0...frameCount) i], 8, true);
            actor.addAnimation('walk', [for (i in 0...frameCount) i], 12, true);
            actor.addAnimation('jump', [0], 8, true);
            actor.playAnimation('idle');
        }
    }

    /**
     * Create a demo level with platforms, gaps, and a goal.
     */
    public static function createDemoLevel(scene:Scene):Void {
        scene.sceneWidth = 854 * 2;
        scene.sceneHeight = 480;
        scene.tileWidth = 32;
        scene.tileHeight = 32;

        var cols = Std.int(Math.ceil(scene.sceneWidth / scene.tileWidth));
        var rows = Std.int(Math.ceil(scene.sceneHeight / scene.tileHeight));
        scene.tiles = [for (y in 0...rows) [for (x in 0...cols) 0]];

        // Ground with 2 gaps
        var groundRow = rows - 3;
        for (x in 0...cols) {
            if (x >= 15 && x <= 17) continue;  // gap 1
            if (x >= 30 && x <= 32) continue;  // gap 2
            scene.tiles[groundRow][x] = 1;
            scene.tiles[groundRow + 1][x] = 1;
            scene.tiles[groundRow + 2][x] = 1;
        }

        // Floating platforms
        for (x in 10...14) scene.tiles[groundRow - 1][x] = 1;
        for (x in 20...22) scene.tiles[groundRow - 1][x] = 1;
        for (x in 25...28) {
            scene.tiles[groundRow - 2][x] = 1;
            scene.tiles[groundRow - 3][x] = 1;
        }
        for (x in 38...42) scene.tiles[groundRow - 1][x] = 1;

        // Walls at edges
        for (y in 0...rows) {
            scene.tiles[y][0] = 1;
            scene.tiles[y][cols - 1] = 1;
        }

        // Hero
        var hero = scene.createActor(590, 100, 300);
        loadActorSprites(hero, 590);
        hero.setActorSize(24, 32);
        scene.hero = hero;
    }
}
