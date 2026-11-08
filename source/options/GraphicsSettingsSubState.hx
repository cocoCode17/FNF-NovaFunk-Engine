package options;

import objects.Character;
import openfl.Lib;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = Language.getPhrase('graphics_menu', 'Graphics Settings');
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			BOOL);
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Shaders', //Name
			"If unchecked, disables shaders.\nIt's used for some visual effects, and also CPU intensive for weaker PCs.", //Description
			'shaders',
			BOOL);
		addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a shitty Graphics Card.", //Description
			'cacheOnGPU',
			BOOL);
		addOption(option);

		#if lime_vorbis
		var option:Option = new Option('Use Streamed Audio', //Name
			"If checked, reads music files in chunks instead of loading them entirely into RAM.\nReduces memory usage and improves load times.", //Description
			'streamedAudio',
			BOOL);
		addOption(option);
		#end

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			INT);
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 60;
		option.maxValue = 240;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Unlock Framerate cap', //Name
			"Removes the framerate cap, allowing the game to run at the maximum possible FPS your system can achieve.", //Description
			'unlockedFramerate',
			BOOL);
		option.onChange = applyUnlockedFramerate;
		addOption(option);

		var option:Option = new Option('Enable VSync', //Name
			"Synchronizes the game's framerate with your monitor's refresh rate to prevent screen tearing.", //Description
			'vsync',
			BOOL);
			option.onChange = applyVSync;
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if (ClientPrefs.data?.unlockedFramerate) return;
		
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	function applyUnlockedFramerate(){
		if (ClientPrefs.data?.unlockedFramerate)
		{
			FlxG.updateFramerate = 1000;
			FlxG.drawFramerate = 1000;
		}
		else
		{
			if (ClientPrefs.data?.vsync)
			{
				applyVSync();
			}
			else
			{
				FlxG.updateFramerate = ClientPrefs.data?.framerate;
				FlxG.drawFramerate = ClientPrefs.data?.framerate;
			}
		}
	}

	function applyVSync(){
		var vsyncEnabled:Bool = (ClientPrefs.data.vsync == true);

		if (vsyncEnabled)
		{
			if (Lib.current.stage.window != null)
			{
				var refreshRate:Int = Lib.current.stage.window.displayMode.refreshRate;
				if (refreshRate > 0)
				{
					FlxG.updateFramerate = refreshRate;
					FlxG.drawFramerate = refreshRate;
				}
				else
				{
					FlxG.updateFramerate = 60;
					FlxG.drawFramerate = 60;
				}
			}
		}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}