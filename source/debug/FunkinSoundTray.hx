package debug;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSoundTray;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.Bitmap;

/**
 * The flixel sound tray, extended with custom Friday Night Funkin' assets!
 */
@:allow(flixel.system.frontEnds.SoundFrontEnd)
class FunkinSoundTray extends FlxSoundTray
{
    /** Custom sound assets **/
    public var volumeMaxSound:FlxSoundAsset = 'assets/shared/sounds/soundTray/VolMAX.ogg';

    /** Image paths **/
    static inline var BG_IMAGE_PATH:String = "assets/shared/images/soundTray/volumebox.png";
    static inline var BARS_IMAGE_PATH:String = "assets/shared/images/soundTray/bars_";

    var _bounceTween:FlxTween;

    public function new()
    {
        super();

        _defaultScale = 1.25;
        volumeUpSound = "assets/shared/sounds/soundTray/Volup.ogg";
        volumeDownSound = "assets/shared/sounds/soundTray/Voldown.ogg";

        if (_label != null)
        {
            if (contains(_label)) removeChild(_label);
        }

        if (_bg != null && contains(_bg)) removeChild(_bg);
        for (bar in _bars)
        {
            if (bar != null && contains(bar)) removeChild(bar);
        }
        _bars = [];

        _bg = new Bitmap(FlxAssets.getBitmapData(BG_IMAGE_PATH));
        _bg.width = Std.int(_bg.width * 0.5);
        _bg.height = Std.int(_bg.height * 0.5);
        addChildAt(_bg, 0);

        var fakeBar = new Bitmap(FlxAssets.getBitmapData('${BARS_IMAGE_PATH}10.png'));
        fakeBar.width = Std.int(fakeBar.width * 0.5);
        fakeBar.height = Std.int(fakeBar.height * 0.5);
        fakeBar.alpha = 0.5;
        fakeBar.x = _bg.x + ((_bg.width - fakeBar.width) / 2);
        fakeBar.y = _bg.y + ((_bg.height - fakeBar.height) / 2) - (_bg.height / 4) + 5;
        addChild(fakeBar);

        for (i in 0...10)
        {
            var barNumber = i + 1;
            var bar = new Bitmap(FlxAssets.getBitmapData('${BARS_IMAGE_PATH}${barNumber}.png'));
            bar.x = fakeBar.x;
            bar.y = fakeBar.y;
            bar.width = Std.int(bar.width * 0.5);
            bar.height = Std.int(bar.height * 0.5);
            addChild(bar);
            _bars.push(bar);
        }

        updateSize();
    }

    override public function update(MS:Float):Void
    {
        if (FlxG.sound.muted)
        {
            _timer = 1.0;

            if (_bounceTween == null || !_bounceTween.active)
                y = 0;

            visible = true;
            active = true;
            alpha = 1.0;
        }

        if (_timer > 0)
        {
            _timer -= (MS / 1000);
        }
        else if (y > -height)
        {
            y -= (MS / 1000) * height * 3.0;

            alpha = 1.0 - (-y / height);

            if (y <= -height)
            {
                visible = false;
                active = false;
                alpha = 0.0;

                #if FLX_SAVE
                // Save sound preferences
                if (FlxG.save.isBound)
                {
                    FlxG.save.data.mute = FlxG.sound.muted;
                    FlxG.save.data.volume = FlxG.sound.volume;
                    FlxG.save.flush();
                }
                #end
            }
        }
    }

    override public function showAnim(volume:Float, ?sound:FlxSoundAsset, duration = 1.0, label = "VOLUME"):Void
    {
        if (sound != null)
            FlxG.sound.play(sound);

        _timer = duration;
        visible = true;
        active = true;
        alpha = 1.0;

        final numBars = Math.round(volume * 10);
        for (i in 0..._bars.length)
        {
            _bars[i].visible = (i < numBars);
        }

        if (_label != null)
            _label.text = label;

        updateSize();

        if (_bounceTween != null)
            _bounceTween.cancel();

        y = 10;
        _bounceTween = FlxTween.tween(this, {y: 0}, 0.15, {ease: FlxEase.quadOut});
    }

    override function showIncrement():Void
    {
        final volume = FlxG.sound.muted ? 0 : FlxG.sound.volume;
        showAnim(volume, silent ? null : (FlxG.sound.volume == 1 ? volumeMaxSound : volumeUpSound), 0.7);
    }

    override function updateSize():Void
    {
        if (_label != null && _bg != null)
        {
            if (_label.textWidth + 10 > _bg.width)
                _label.width = _label.textWidth + 10;

            _label.width = _bg.width;
        }

        screenCenter();
    }
}
#end