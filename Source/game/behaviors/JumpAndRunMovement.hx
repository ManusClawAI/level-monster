package game.behaviors;

import game.Actor;
import engine.Engine;
import utils.Input;

/**
 * Player controller — Stencyl's Design_277_277_JumpandRunMovementmodified.
 * SI units: px/sec, px/sec².
 *
 * Features:
 * - Variable acceleration/deceleration (per-second)
 * - Max running speed (modifiable by traps)
 * - Variable jump height (hold to jump higher)
 * - Coyote time (100ms after leaving platform)
 * - Jump buffer (100ms before landing)
 * - Jump cut-short (release for short hop)
 */
class JumpAndRunMovement {
    public var actor:Actor;

    // SI values (px/sec, px/sec²)
    public var _MaximumRunningSpeed:Float = 480;   // 8 px/frame * 60
    public var _Acceleration:Float = 3000;          // px/sec²
    public var _Deceleration:Float = 3000;          // px/sec²
    public var _JumpingPower:Float = 700;            // px/sec upward
    public var _AirMobility:Float = 0.6;             // 60% control in air
    public var _CoyoteTime:Float = 0.10;             // seconds
    public var _JumpBufferTime:Float = 0.10;         // seconds

    private var coyoteTimer:Float = 0;
    private var jumpBufferTimer:Float = 0;
    private var isJumping:Bool = false;
    private var jumpHoldTime:Float = 0;
    private var maxJumpHoldTime:Float = 0.15;

    public function new(actor:Actor) { this.actor = actor; }

    public function update(dt:Float):Void {
        if (actor.dead || actor.recycled) return;

        // Coyote time
        if (actor.onGround) coyoteTimer = _CoyoteTime;
        else coyoteTimer -= dt;

        // Jump buffer
        if (jumpBufferTimer > 0) jumpBufferTimer -= dt;

        // Horizontal movement
        var moveDir = 0;
        if (Input.isLeftDown()) moveDir = -1;
        else if (Input.isRightDown()) moveDir = 1;

        var targetSpeed = _MaximumRunningSpeed * moveDir;
        var accel = actor.onGround ? _Acceleration : _Acceleration * _AirMobility;
        var decel = actor.onGround ? _Deceleration : _Deceleration * _AirMobility;

        if (moveDir != 0) {
            // Accelerate toward target
            if (actor.xVelocity < targetSpeed) {
                actor.xVelocity = Math.min(targetSpeed, actor.xVelocity + accel * dt);
            } else if (actor.xVelocity > targetSpeed) {
                actor.xVelocity = Math.max(targetSpeed, actor.xVelocity - accel * dt);
            }
        } else {
            // Decelerate
            var decelAmount = decel * dt;
            if (Math.abs(actor.xVelocity) <= decelAmount) {
                actor.xVelocity = 0;
            } else {
                actor.xVelocity -= decelAmount * (actor.xVelocity > 0 ? 1 : -1);
            }
        }

        // Clamp max speed
        if (Math.abs(actor.xVelocity) > _MaximumRunningSpeed) {
            actor.xVelocity = _MaximumRunningSpeed * (actor.xVelocity > 0 ? 1 : -1);
        }

        // Jump buffer set
        if (Input.wasJumpPressed()) {
            jumpBufferTimer = _JumpBufferTime;
        }

        // Execute jump
        if (jumpBufferTimer > 0 && coyoteTimer > 0 && !isJumping) {
            actor.yVelocity = -_JumpingPower;
            isJumping = true;
            jumpHoldTime = 0;
            jumpBufferTimer = 0;
            coyoteTimer = 0;
            actor.onGround = false;
            // Play jump sound
            var sound = engine.AssetManager.instance.getSound(565);
            if (sound != null) {
                engine.AudioManager.instance.playOnChannel(sound, 2);
            }
        }

        // Variable jump height — hold for extra upward boost
        if (isJumping && Input.isJumpDown() && jumpHoldTime < maxJumpHoldTime && actor.yVelocity < 0) {
            actor.yVelocity -= 800 * dt;
            jumpHoldTime += dt;
        }

        // Cut jump short on release
        if (isJumping && !Input.isJumpDown() && actor.yVelocity < -200) {
            actor.yVelocity *= 0.5;
            isJumping = false;
        }

        // Reset on landing
        if (actor.onGround && isJumping && actor.yVelocity >= 0) {
            isJumping = false;
        }

        // Animation state
        if (!actor.onGround) {
            actor.playAnimation("jump");
        } else if (Math.abs(actor.xVelocity) > 10) {
            actor.playAnimation("walk");
        } else {
            actor.playAnimation("idle");
        }

        // Death from falling
        if (Engine.instance != null && Engine.instance.currentScene != null) {
            if (actor.y > Engine.instance.currentScene.sceneHeight + 100) {
                actor.die();
            }
        }
    }

    public function setMaxRunningSpeed(speed:Float):Void {
        _MaximumRunningSpeed = speed;
    }
}
