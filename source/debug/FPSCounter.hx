package debug;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

@:font("assets/fonts/vcr.ttf")
class FPSFont extends Font {}

class FPSCounter extends Sprite 
{
    private var textField:TextField;
    private var textSize:Int = 18;
    private var times:Array<Float>;
    private var lastTime:Float;
	// maybe added in a future...
    // private var buildNum:Int = 0;

    private var msGraphSprite:Sprite;
    private var memGraphSprite:Sprite;

    private var msHistory:Array<Float>;
    private var memHistory:Array<Float>;

    private final maxPoints:Int = 35;
    private final graphWidth:Float = 110;
    private final graphHeight:Float = 18;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFF) 
    {
        super();

        this.x = x;
        this.y = y;

        Font.registerFont(FPSFont);
        var font = new FPSFont();

        var format = new TextFormat(font.fontName, textSize, color);
        format.align = TextFormatAlign.LEFT;

        textField = new TextField();
        textField.defaultTextFormat = format;
        textField.embedFonts = true;
        textField.selectable = false;
        textField.multiline = true;
        textField.wordWrap = false;
        textField.width = 250;
        textField.height = 85;
        
        textField.sharpness = 400;
        addChild(textField);

        msGraphSprite = new Sprite();
        msGraphSprite.x = 0;
        msGraphSprite.y = 88;
        addChild(msGraphSprite);

        memGraphSprite = new Sprite();
        memGraphSprite.x = 0;
        memGraphSprite.y = 112;
        addChild(memGraphSprite);

        msHistory = [];
        memHistory = [];
        times = [];
        lastTime = Lib.getTimer();

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        // buildNum = debug.BuildMacro.getBuildNumber();
        // trace(buildNum);
    }

    private function onEnterFrame(e:Event):Void 
    {
        var currentTime = Lib.getTimer();
        var deltaTime = currentTime - lastTime;
        lastTime = currentTime;

        times.push(currentTime);
        while (times[0] < currentTime - 1000) {
            times.shift();
        }

        var currentFPS = times.length;
        var memoryMB = System.totalMemory / (1024 * 1024);
        var frameTimeMS = deltaTime;

        textField.text = 'FPS: $currentFPS\n' +
                         'FMS: ${Math.round(frameTimeMS * 10) / 10}ms\n' +
                         'MEM: ${Math.round(memoryMB * 100) / 100} MB\n' /*+
                         'BUILD NUM: ' + buildNum*/;

        msHistory.push(frameTimeMS);
        if (msHistory.length > maxPoints) msHistory.shift();

        memHistory.push(memoryMB);
        if (memHistory.length > maxPoints) memHistory.shift();

        drawMSGraph();
        drawMemGraph();
    }

    private function drawMSGraph():Void 
    {
        var g = msGraphSprite.graphics;
        g.clear();

        if (msHistory.length < 2) return;

        g.lineStyle(1.5, 0xFFFFFF, 0.9);
        var stepX = graphWidth / (maxPoints - 1);
        var maxMS:Float = 33.3;

        for (i in 0...msHistory.length) {
            var ratio = Math.min(msHistory[i] / maxMS, 1.0);
            var px = i * stepX;
            var py = graphHeight - (ratio * graphHeight);

            if (i == 0) g.moveTo(px, py);
            else g.lineTo(px, py);
        }
    }

    private function drawMemGraph():Void 
    {
        var g = memGraphSprite.graphics;
        g.clear();

        if (memHistory.length < 2) return;

        var maxMem:Float = 1.0;
        for (m in memHistory) if (m > maxMem) maxMem = m;

        var stepX = graphWidth / (maxPoints - 1);

        g.beginFill(0xFFFFFF, 0.4); 
        g.lineStyle(1, 0xFFFFFF, 1.0);
        
        g.moveTo(0, graphHeight);

        for (i in 0...memHistory.length) {
            var ratio = memHistory[i] / maxMem;
            var px = i * stepX;
            var py = graphHeight - (ratio * graphHeight);
            g.lineTo(px, py);
        }

        g.lineTo((memHistory.length - 1) * stepX, graphHeight);
        g.lineTo(0, graphHeight);
        g.endFill();
    }
}