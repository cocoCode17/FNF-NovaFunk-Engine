package objects;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import StringTools;

class JudgementSpr extends FlxSpriteGroup {
    private var FRAME_WIDTH:Int = 500;
    private var FRAME_HEIGHT:Int = 163;
    
    private var NUM_WIDTH:Int = 98;
    private var NUM_HEIGHT:Int = 120;

    public var judgementSpr:FlxSprite;
    public var numbers:Array<FlxSprite> = [];
    private var judges:Array<String> = [
        "sick",
        "good",
        "bad",
        "shit"
    ];

    private var game:PlayState = null;

    public static var DEFAULT_LIFE_TIME:Float = 1.2;
    public var lifeTime:Float = DEFAULT_LIFE_TIME;

    public var isPixel:Bool = false;

    private var baseScale:Float = 0.55;
    private var numScale:Float = 0.4;

    private var multScale:Float = 1.2;

    private var judgementTween:FlxTween = null;
    private var numTweens:Array<FlxTween> = [];

    public var isDownscroll = ClientPrefs.data.downScroll;
    public var isMiddleScroll = ClientPrefs.data.middleScroll;

    public function new(isPixel:Bool = false, game:PlayState) {
        super();

        this.game = game;
        this.isPixel = isPixel;

        if (isDownscroll && isMiddleScroll){
            isDownscroll = false; // better positions!
        }


        for (judge in judges){
            Paths.image(judge);
        }
        
        for (digit in 0...10) {
            Paths.image('num'+digit);
        }

        judgementSpr = new FlxSprite(0, 0);
        judgementSpr.loadGraphic(Paths.image(judges[0]), true, FRAME_WIDTH, FRAME_HEIGHT);
        
        // for (i in 0...judges.length) {
        //     judgementSpr.animation.add(judges[i], [i], 0, false);
        // }
        // judgementSpr.animation.play("shit", true);
        judgementSpr.alpha = 0;
        judgementSpr.scale.set(baseScale*this.scale.x, baseScale*this.scale.y);
        judgementSpr.updateHitbox();
        judgementSpr.screenCenter(isMiddleScroll ? XY : X);

        judgementSpr.y = isDownscroll ? (FlxG.height - judgementSpr.height) - 40 : 40;
        judgementSpr.cameras = [game.camHUD];
        add(judgementSpr);

        for (i in 0...3) {
            var numSpr:FlxSprite = new FlxSprite(0, 0);
            numSpr.loadGraphic(Paths.image("num0"), true, NUM_WIDTH, NUM_HEIGHT);
            
            // for (digit in 0...10) {
                // var frameIndex:Int = (digit == 0) ? 9 : (digit - 1);
                // numSpr.animation.add(Std.string(digit), [frameIndex], 0, false);
            // }
            numSpr.alpha = 0;
            numSpr.scale.set(numScale*this.scale.x, numScale*this.scale.y);
            numSpr.updateHitbox();
            numSpr.cameras = [game.camHUD];
            numbers.push(numSpr);
            add(numSpr);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (lifeTime <= 0) {
            judgementSpr.alpha = FlxMath.lerp(judgementSpr.alpha, 0, elapsed * 9);
            for (num in numbers) {
                num.alpha = FlxMath.lerp(num.alpha, 0, elapsed * 9);
            }
        }

        if (lifeTime > 0) {
            lifeTime -= elapsed;
        }
    }

    public function popUp(rating:String, combo:Int) {
        judgementSpr.loadGraphic(Paths.image(rating));
        judgementSpr.alpha = 1;
        lifeTime = DEFAULT_LIFE_TIME;

        final targetScale:Float = baseScale * multScale * this.scale.x;
        judgementSpr.scale.set(targetScale, targetScale);
        // judgementSpr.angle = FlxG.random.int(-10, 10);
        // judgementSpr.updateHitbox();
        judgementSpr.width = FRAME_WIDTH;
        judgementSpr.height = FRAME_HEIGHT;
        judgementSpr.centerOrigin();
        judgementSpr.screenCenter(isMiddleScroll ? XY : X);

        if (judgementTween != null) {
            judgementTween.cancel();
        }

        judgementTween = FlxTween.tween(judgementSpr.scale, {x: baseScale*this.scale.x, y: baseScale*this.scale.y}, 0.2 / game.playbackRate, {
            ease: FlxEase.cubeOut,
            onComplete: function(twn:FlxTween) {
                judgementTween = null;
            }
        });

        var comboString:String = StringTools.lpad(Std.string(combo), "0", 3);
        
        for (twn in numTweens) {
            if (twn != null) twn.cancel();
        }
        numTweens = [];

        var realNumWidth:Float = NUM_WIDTH * numScale;
        var realNumHeight:Float = NUM_HEIGHT * numScale;
        var spacing:Float = -3.0; 
        
        var totalWidth:Float = (comboString.length * realNumWidth) + ((comboString.length - 1) * spacing);
        
        var judgementCenterX:Float = judgementSpr.x + (judgementSpr.width / 2);
        var startX:Float = judgementCenterX - (totalWidth / 2);

        var targetY:Float = isDownscroll ? 
            (judgementSpr.y - realNumHeight - 2) : 
            (judgementSpr.y + judgementSpr.height + 2);

        for (i in 0...comboString.length) {
            var digitStr:String = comboString.charAt(i);
            var numSpr:FlxSprite = numbers[i];

            if (numSpr != null) {
                numSpr.animation.play(digitStr, true);
                numSpr.loadGraphic(Paths.image("num"+digitStr));
                numSpr.alpha = 1;
                numSpr.scale.set((numScale + 0.08)*this.scale.x, (numScale + 0.08)*this.scale.y);
                numSpr.updateHitbox();
                numSpr.centerOrigin();

                numSpr.x = startX + (i * (realNumWidth + spacing));
                numSpr.x -= 8;
                numSpr.y = targetY;
                numSpr.x *= this.scale.x;
                numSpr.y *= this.scale.y;
                if (!isDownscroll)
                numSpr.y -= numSpr.height/2;

                var twn:FlxTween = FlxTween.tween(numSpr.scale, {x: numScale*this.scale.x, y: numScale*this.scale.y}, 0.2 / game.playbackRate, {
                    ease: FlxEase.cubeOut
                });
                numTweens.push(twn);
            }
        }
    }
}