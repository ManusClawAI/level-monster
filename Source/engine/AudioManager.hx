package engine;

import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

/**
 * AudioManager — Howler.js-compatible channel-based audio.
 * 16 SFX channels + 1 music channel.
 */
class AudioManager {
    public static var instance:AudioManager;

    private var channels:Map<Int, SoundChannel> = new Map();
    private var musicChannel:SoundChannel = null;
    private var musicSound:Sound = null;

    public var masterVolume:Float = 1.0;
    public var sfxVolume:Float = 1.0;
    public var musicVolume:Float = 0.7;
    public var muted:Bool = false;

    public function new() { instance = this; }

    public static function init():Void { new AudioManager(); }

    public function playOnChannel(sound:Sound, channel:Int = 0, loop:Bool = false):SoundChannel {
        if (sound == null) return null;
        stopChannel(channel);
        var vol = muted ? 0 : sfxVolume * masterVolume;
        var sc = sound.play(0, new SoundTransform(vol));
        if (sc == null) return null;
        if (loop) {
            var soundRef = sound;
            var channelRef = channel;
            sc.addEventListener(openfl.events.Event.SOUND_COMPLETE, function(_) {
                playOnChannel(soundRef, channelRef, true);
            });
        }
        channels.set(channel, sc);
        return sc;
    }

    public function stopChannel(channel:Int):Void {
        if (channels.exists(channel)) {
            var sc = channels.get(channel);
            if (sc != null) sc.stop();
            channels.remove(channel);
        }
    }

    public function stopAll():Void {
        for (ch in channels.keys()) stopChannel(ch);
        stopMusic();
    }

    public function playMusic(sound:Sound, loop:Bool = true):Void {
        if (sound == null) return;
        stopMusic();
        musicSound = sound;
        var vol = muted ? 0 : musicVolume * masterVolume;
        musicChannel = sound.play(0, new SoundTransform(vol));
        if (loop && musicChannel != null) attachMusicLoop();
    }

    private function attachMusicLoop():Void {
        if (musicChannel == null) return;
        musicChannel.addEventListener(openfl.events.Event.SOUND_COMPLETE, onMusicComplete);
    }

    private function onMusicComplete(_):Void {
        if (musicSound != null) {
            var vol = muted ? 0 : musicVolume * masterVolume;
            musicChannel = musicSound.play(0, new SoundTransform(vol));
            if (musicChannel != null) attachMusicLoop();
        }
    }

    public function stopMusic():Void {
        if (musicChannel != null) {
            musicChannel.stop();
            musicChannel = null;
        }
        musicSound = null;
    }

    public function setMuted(m:Bool):Void {
        muted = m;
        for (sc in channels) {
            if (sc != null) {
                var t = sc.soundTransform;
                t.volume = muted ? 0 : sfxVolume * masterVolume;
                sc.soundTransform = t;
            }
        }
        if (musicChannel != null) {
            var t = musicChannel.soundTransform;
            t.volume = muted ? 0 : musicVolume * masterVolume;
            musicChannel.soundTransform = t;
        }
    }
}
