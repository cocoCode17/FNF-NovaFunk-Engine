package objects;

class StrumlineBG extends FlxSprite{
    
    public var strumsGrp:FlxTypedGroup<StrumNote>;

    public var bgAlpha:Float;
    
    public var bgColor:FlxColor;

    public var bgWidth:Float = 450;

    public var firstStrum:StrumNote = null;
    public var lastStrum:StrumNote = null;

    public var canUpdate:Bool = false;

    public function new (strumsGrp:FlxTypedGroup<StrumNote>, bgColor:FlxColor, bgAlpha:Float){
        super();

        this.strumsGrp = strumsGrp;
        this.bgAlpha = bgAlpha ?? 7.0;
        this.bgColor = bgColor ?? FlxColor.BLACK;

        var bgX:Float = 0;
        if (strumsGrp != null){
            firstStrum = strumsGrp.members[0];
            lastStrum = strumsGrp.members[strumsGrp.members.length-1];
            if (firstStrum == null) return;
            if (lastStrum == null) return;
            bgWidth = (firstStrum.width + (lastStrum.x - firstStrum.x) + 16);
            bgX = firstStrum.x - 8;
        }

        makeGraphic(Std.int(bgWidth), FlxG.height, bgColor);
        screenCenter(Y);
        x = bgX;
        alpha = 0;
        
        FlxTween.tween(this, {alpha: firstStrum.alpha * bgAlpha},0.35,{ease: FlxEase.quadIn,
            onComplete: twn->{
                canUpdate = true;
            }
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!canUpdate) return;
        
        if (firstStrum == null) return;
        if (lastStrum == null) return;

        x = firstStrum.x - 8;
        alpha = firstStrum.alpha * bgAlpha;
    }
}