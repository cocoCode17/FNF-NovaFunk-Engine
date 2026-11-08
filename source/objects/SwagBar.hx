package objects;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

enum BarFillDirection
{
    LEFT_TO_RIGHT;
    RIGHT_TO_LEFT;
    TOP_TO_BOTTOM;
    BOTTOM_TO_TOP;
}

class SwagBar extends FlxSpriteGroup
{
    public var background:FlxSprite;
    public var fill:FlxSprite;

    public var value(default, set):Float = 100;

    public var percent(get, set):Float;

    public var currentValue(default, null):Float = 100;

    public var maxValue(default, set):Float = 100;

    public var direction(default, set):BarFillDirection = LEFT_TO_RIGHT;

    public var enabled:Bool = true;

    public var lerpEnabled:Bool = true;
    public var lerpSpeed:Float = 10;

    public var onSetupBackground:FlxSprite->Void;
    public var onSetupFill:FlxSprite->Void;

    public var onValueChanged:(Float, Float)->Void;

    public var onBarUpdate:(Float, Float)->Void;

    private var _clipRect:FlxRect;

    public function new(
        X:Float = 0,
        Y:Float = 0,
        MaxValue:Float = 100,
        Value:Float = 100,
        Direction:BarFillDirection = LEFT_TO_RIGHT,
        LerpSpeed:Float = 10,
        ?BackgroundSprite:FlxSprite,
        ?FillSprite:FlxSprite,
        ?OnSetupBackground:FlxSprite->Void,
        ?OnSetupFill:FlxSprite->Void,
        ?OnValueChanged:(Float, Float)->Void,
        ?OnBarUpdate:(Float, Float)->Void
    ) {
        super(X, Y);

        _clipRect = FlxRect.get();

        this.maxValue = MaxValue;
        this.value = Value;
        this.currentValue = Value;
        this.direction = Direction;
        this.lerpSpeed = LerpSpeed;

        this.onSetupBackground = OnSetupBackground;
        this.onSetupFill = OnSetupFill;
        this.onValueChanged = OnValueChanged;
        this.onBarUpdate = OnBarUpdate;

        background = (BackgroundSprite != null) ? BackgroundSprite : new FlxSprite();
        fill = (FillSprite != null) ? FillSprite : new FlxSprite();

        if (onSetupBackground != null)
            onSetupBackground(background);

        if (onSetupFill != null)
            onSetupFill(fill);

        add(background);
        add(fill);

        fill.y = background.y;

        fill.clipRect = _clipRect;

        updateBar();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!enabled) return;

        if (lerpEnabled && currentValue != value)
        {
            currentValue = FlxMath.lerp(currentValue, value, FlxMath.bound(elapsed * lerpSpeed, 0, 1));

            if (Math.abs(currentValue - value) < 0.001)
            {
                currentValue = value;
            }

            updateBar();
        }
    }

     public function updateBar():Void
    {
        if (fill == null || fill.frame == null) return;

        var pct:Float = (maxValue <= 0) ? 0 : FlxMath.bound(currentValue / maxValue, 0, 1);
        var frameWidth:Float = fill.frameWidth;
        var frameHeight:Float = fill.frameHeight;

        switch (direction)
        {
            case LEFT_TO_RIGHT:
                _clipRect.set(0, 0, frameWidth * pct, frameHeight);

            case RIGHT_TO_LEFT:
                var clipW:Float = frameWidth * pct;
                _clipRect.set(frameWidth - clipW, 0, clipW, frameHeight);

            case TOP_TO_BOTTOM:
                _clipRect.set(0, 0, frameWidth, frameHeight * pct);

            case BOTTOM_TO_TOP:
                var clipH:Float = frameHeight * pct;
                _clipRect.set(0, frameHeight - clipH, frameWidth, clipH);
        }

        fill.clipRect = _clipRect;

        if (onBarUpdate != null)
            onBarUpdate(currentValue, pct);
    }

    public function setColors(backgroundColor:Null<FlxColor> = null, fillColor:Null<FlxColor> = null):Void
    {
        if (fill != null)
            fill.color = (fillColor != null) ? fillColor : FlxColor.LIME;

        if (background != null)
            background.color = (backgroundColor != null) ? backgroundColor : FlxColor.RED;

        updateBar();
    }

    public function setValueSnap(v:Float):Void
    {
        var old:Float = value;
        value = v;
        currentValue = v;

        if (onValueChanged != null && old != value)
            onValueChanged(value, old);

        updateBar();
    }

    private function get_percent():Float
    {
        if (maxValue <= 0) return 0;
        return (value / maxValue) * 100;
    }

    private function set_percent(p:Float):Float
    {
        p = FlxMath.bound(p, 0, 100);
        this.value = (p / 100) * maxValue;
        return p;
    }

    private function set_value(v:Float):Float
    {
        var oldValue:Float = value;
        value = v;

        if (onValueChanged != null && oldValue != value)
        {
            onValueChanged(value, oldValue);
        }

        if (!lerpEnabled)
        {
            currentValue = v;
            updateBar();
        }

        return value;
    }

    private function set_maxValue(v:Float):Float
    {
        maxValue = v;
        updateBar();
        return maxValue;
    }

    private function set_direction(d:BarFillDirection):BarFillDirection
    {
        direction = d;
        updateBar();
        return direction;
    }

    override public function destroy():Void
    {
        if (_clipRect != null)
        {
            _clipRect.put();
            _clipRect = null;
        }

        onSetupBackground = null;
        onSetupFill = null;
        onValueChanged = null;
        onBarUpdate = null;

        super.destroy();
    }
}