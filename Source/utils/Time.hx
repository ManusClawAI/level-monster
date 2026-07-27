package utils;

/**
 * Time - Global time tracking.
 */
class Time {
    public static var time:Float = 0;
    public static var deltaTime:Float = 0;
    public static var frameCount:Int = 0;

    public static function now():Float {
        return openfl.Lib.getTimer() / 1000.0;
    }
}
