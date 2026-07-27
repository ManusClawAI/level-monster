package game;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import engine.AssetManager;
import engine.Engine;

/**
 * Actor — base class for all game entities.
 * Physics in SI units: px/sec, px/sec².
 * Uses actorWidth/actorHeight to avoid conflict with DisplayObject.width/height.
 */
class Actor extends Sprite {
    static var nextId:Int = 0;

    public var id:Int;
    public var typeId:Int;
    public var actorName:String;
    public var dead:Bool = false;
    public var recycled:Bool = false;

    // Physics (SI: px/sec, px/sec²)
    public var xVelocity:Float = 0;
    public var yVelocity:Float = 0;
    public var xAcceleration:Float = 0;
    public var yAcceleration:Float = 0;
    public var maxRunningSpeed:Float = 480;     // px/sec
    public var friction:Float = 0.0001;          // per-second retention (0.0001 = nearly stop in 1 frame)
    public var gravityScale:Float = 1.0;
    public var immovable:Bool = false;
    public var ignoresGravity:Bool = false;

    // Collision (renamed to avoid DisplayObject conflicts)
    public var collideX:Bool = true;
    public var collideY:Bool = true;
    public var actorWidth:Float = 32;
    public var actorHeight:Float = 32;
    public var onGround:Bool = false;
    public var onWall:Bool = false;
    public var onCeiling:Bool = false;

    // Animation
    public var currentAnimation:String = "";
    public var frame:Int = 0;
    public var frameTime:Float = 0;
    public var animations:Map<String, Animation> = new Map();
    public var facingRight:Bool = true;

    // Sprite sheets
    public var spriteBitmaps:Map<String, Array<BitmapData>> = new Map();
    public var currentBitmap:Bitmap;

    // Behavior storage
    public var behaviors:Map<String, Dynamic> = new Map();
    public var valueMap:Map<String, Dynamic> = new Map();
    public var group:String = "default";

    public function new(typeId:Int = 0, name:String = "") {
        super();
        this.id = nextId++;
        this.typeId = typeId;
        this.actorName = name;
        currentBitmap = new Bitmap();
        addChild(currentBitmap);
    }

    public function loadSpriteFrames(baseName:String, frameCount:Int):Void {
        var frames = new Array<BitmapData>();
        for (i in 0...frameCount) {
            var bmp = AssetManager.instance.getSprite(typeId, i);
            if (bmp != null) frames.push(bmp);
        }
        spriteBitmaps.set(baseName, frames);
        if (currentAnimation == "" && frames.length > 0) {
            currentAnimation = baseName;
        }
        syncSizeFromBitmap();
        updateBitmap();
    }

    public function loadStaticSprite(resourceId:Int):Void {
        var bmp = AssetManager.instance.getSprite(resourceId, 0);
        if (bmp != null) {
            spriteBitmaps.set("idle", [bmp]);
            currentAnimation = "idle";
            addAnimation("idle", [0], 1, true);
            playAnimation("idle");
        }
        syncSizeFromBitmap();
        updateBitmap();
    }

    public function loadSpriteSheet(resourceId:Int, frameCount:Int):Void {
        loadSpriteFrames("default", frameCount);
    }

    private function syncSizeFromBitmap():Void {
        var frames = spriteBitmaps.get(currentAnimation);
        if (frames != null && frames.length > 0) {
            var bmp = frames[0];
            if (actorWidth == 32 && actorHeight == 32) {
                actorWidth = bmp.width;
                actorHeight = bmp.height;
            }
        }
    }

    public function addAnimation(name:String, frameIndices:Array<Int>, fps:Float = 12, loop:Bool = true):Void {
        var anim = new Animation();
        anim.name = name;
        anim.frameIndices = frameIndices;
        anim.fps = fps;
        anim.loop = loop;
        anim.frameTime = 1.0 / fps;
        animations.set(name, anim);
    }

    public function setAnimation(name:String, frames:Array<Int>, fps:Float = 12, loop:Bool = true):Void {
        addAnimation(name, frames, fps, loop);
    }

    public function playAnimation(name:String):Void {
        if (currentAnimation != name && animations.exists(name)) {
            currentAnimation = name;
            frame = 0;
            frameTime = 0;
        }
    }

    public function update(dt:Float):Void {
        if (dead || recycled) return;

        // Gravity (px/sec²)
        if (!ignoresGravity && Engine.instance != null && Engine.instance.game != null) {
            yVelocity += Engine.instance.game.gravity * gravityScale * dt;
        }

        // Acceleration
        xVelocity += xAcceleration * dt;
        yVelocity += yAcceleration * dt;

        // Friction (per-second exponential decay)
        if (xAcceleration == 0 && onGround) {
            xVelocity *= Math.pow(friction, dt);
            if (Math.abs(xVelocity) < 1) xVelocity = 0;
        }

        // Clamp to max speed
        if (Math.abs(xVelocity) > maxRunningSpeed) {
            xVelocity = maxRunningSpeed * (xVelocity > 0 ? 1 : -1);
        }

        // Move (px/sec * dt)
        x += xVelocity * dt;
        y += yVelocity * dt;

        // Animation
        if (currentAnimation != "" && animations.exists(currentAnimation)) {
            var anim = animations.get(currentAnimation);
            frameTime += dt;
            if (frameTime >= anim.frameTime) {
                frameTime -= anim.frameTime;
                frame++;
                if (frame >= anim.frameIndices.length) {
                    frame = anim.loop ? 0 : anim.frameIndices.length - 1;
                }
            }
            updateBitmap();
        }

        // Facing
        if (xVelocity > 5) facingRight = true;
        else if (xVelocity < -5) facingRight = false;
        currentBitmap.scaleX = facingRight ? 1 : -1;
    }

    private function updateBitmap():Void {
        if (currentAnimation == "" || !animations.exists(currentAnimation)) return;
        var anim = animations.get(currentAnimation);
        if (frame < 0 || frame >= anim.frameIndices.length) return;
        var actualFrame = anim.frameIndices[frame];
        var frames = spriteBitmaps.get(currentAnimation);
        if (frames != null && actualFrame < frames.length) {
            currentBitmap.bitmapData = frames[actualFrame];
            currentBitmap.x = -currentBitmap.bitmapData.width / 2;
            currentBitmap.y = -currentBitmap.bitmapData.height / 2;
        }
    }

    public function die():Void {
        dead = true;
        visible = false;
    }

    public function kill():Void { die(); }

    public function recycle():Void {
        recycled = true;
        visible = false;
    }

    public function reset(x:Float, y:Float):Void {
        this.x = x;
        this.y = y;
        dead = false;
        recycled = false;
        visible = true;
        xVelocity = 0;
        yVelocity = 0;
    }

    public function applyImpulse(vx:Float, vy:Float):Void {
        xVelocity = vx;
        yVelocity = vy;
    }

    public function setActorSize(w:Float, h:Float):Void {
        actorWidth = w;
        actorHeight = h;
    }

    // Stencyl-compatible getters/setters
    public function getX():Float { return x; }
    public function getY():Float { return y; }
    public function getXVelocity():Float { return xVelocity; }
    public function getYVelocity():Float { return yVelocity; }
    public function getXCenter():Float { return x + actorWidth / 2; }
    public function getYCenter():Float { return y + actorHeight / 2; }
    public function getWidth():Float { return actorWidth; }
    public function getHeight():Float { return actorHeight; }
    public function setX(v:Float):Void { x = v; }
    public function setY(v:Float):Void { y = v; }
    public function setXVelocity(v:Float):Void { xVelocity = v; }
    public function setYVelocity(v:Float):Void { yVelocity = v; }
    public function isAlive():Bool { return !dead && !recycled; }
    public function getAnimation():String { return currentAnimation; }
    public function setAnim(a:String):Void { playAnimation(a); }
}

class Animation {
    public var name:String;
    public var frameIndices:Array<Int>;
    public var fps:Float;
    public var loop:Bool;
    public var frameTime:Float;
    public function new() {}
}
