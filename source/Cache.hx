#if sys
package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Cache extends MusicBeatState
{
	public static var bitmapData:Map<String,FlxGraphic>;
	public static var bitmapData2:Map<String,FlxGraphic>;

	var images = [];
	var images2 = [];
	var music = [];

	var aaaaa:FlxText;

	override function create()
	{
		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();
		bitmapData2 = new Map<String,FlxGraphic>();

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('promo'));
		menuBG.screenCenter();
		add(menuBG);

		aaaaa = new FlxText(12, 12, 0, "Loading...", 12);
		aaaaa.scrollFactor.set();
		aaaaa.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(aaaaa);
		changetext();

		#if cpp
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/weekcg")))
			{
				if (!i.endsWith(".png"))
					continue;
				images2.push(i);
			}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
		#end

		sys.thread.Thread.create(() -> {
			cache();
		});

		super.create();
	}

	override function update(elapsed) 
	{
		super.update(elapsed);
	}

	function changetext() {
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				aaaaa.text = 'Loading.';
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						aaaaa.text = 'Loading..';
						new FlxTimer().start(0.5, function(tmr:FlxTimer)
							{
								aaaaa.text = 'Loading...';
								changetext();
							});
					});
			});
	}

	function cache()
	{
		#if !linux
			var aaa:FlxSprite;
			aaa = new FlxSprite();
			aaa.frames = Paths.getSparrowAtlas('characters/cassettegirl-st','shared');
			aaa.animation.addByPrefix('idle',"cassettegirl cut",22,false);
			aaa.animation.play('idle');
			aaa.antialiasing = true;
			aaa.alpha = 0.00001;
			add(aaa);

			var sound1:FlxSound;
			sound1 = new FlxSound().loadEmbedded(Paths.voices('machina'));
			sound1.play();
			sound1.volume = 0.00001;
			FlxG.sound.list.add(sound1);

			var sound2:FlxSound;
			sound2 = new FlxSound().loadEmbedded(Paths.inst('machina'));
			sound2.play();
			sound2.volume = 0.00001;
			FlxG.sound.list.add(sound2);
		for (i in images)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			trace(i);
		}

		for (i in images2)
			{
				var replaced2 = i.replace(".png","");
				var data2:BitmapData = BitmapData.fromFile("assets/shared/images/weekcg/" + i);
				var graph2 = FlxGraphic.fromBitmapData(data2);
				graph2.persist = true;
				graph2.destroyOnNoUse = false;
				bitmapData2.set(replaced2,graph2);
				trace(i);
			}



		for (i in music)
		{
			trace(i);
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
		}


		#end
		FlxG.switchState(new TitleState());
	}

}
#end