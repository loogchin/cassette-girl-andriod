package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.util.FlxTimer;
import Achievements;
import editors.MasterEditorMenu;
import WeekData;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['MENUPLAY', 'FREEPLAY', 'OPTIONS', 'CREDITS'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var cg:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		WeekData.reloadWeekFiles(true);
		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('MENU/MENU-BG'));
		bg.scrollFactor.set(0, yScroll);
		bg.updateHitbox();
		bg.scale.set(1.1,1.1);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var aa:FlxSprite = new FlxSprite();
		aa.frames = Paths.getSparrowAtlas('MENU/MENU-light');
		aa.scale.set(0.55,0.55);
		aa.screenCenter();
		aa.x -= 250;
		aa.y -= 360;
		aa.antialiasing = ClientPrefs.globalAntialiasing;
		aa.animation.addByPrefix('idle',"menulight1");		
		aa.animation.play('idle');
		add(aa);

		var bga:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('MENU/MENU-A'));
		bga.scrollFactor.set(0, yScroll);
		bga.updateHitbox();
		bga.scale.set(1.1,1.1);
		bga.screenCenter();
		bga.x += 70;
		bga.antialiasing = ClientPrefs.globalAntialiasing;
		add(bga);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('MENU/MENU-button');

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 160)  + 65);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + "-stop", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + "0", 24);
			menuItem.animation.addByPrefix('go', optionShit[i] + "-go", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			switch (i)
			{
				case 0:
					menuItem.x += 335;
					menuItem.y -= 50;
				case 1:
					menuItem.x += 325;
					menuItem.y += 50;
				case 2:
					menuItem.x += 380;
					menuItem.y += 80;
				case 3:
					menuItem.x += 420;
					menuItem.y += 53;
			}
		}

		cg = new FlxSprite();
		cg.frames = Paths.getSparrowAtlas('MENU/MENU-CGSP');
		cg.antialiasing = ClientPrefs.globalAntialiasing;
		cg.animation.addByPrefix('idle',"menu-cassette bopping",24);	
		cg.animation.addByPrefix('fix',"menu-cassette freeplay",24,false);		
		cg.animation.addByPrefix('tape',"menu-cassette options",24,false);	
		cg.animation.addByIndices('fix2', 'menu-cassette freeplay', CoolUtil.numberArray(39, 25), "", 24);
		cg.animation.addByIndices('tape2', 'menu-cassette options', CoolUtil.numberArray(26, 8), "", 24);
		cg.animation.play('idle');
		cg.x -= 850;
		cg.y -= 500;
		cg.scale.set(0.9,0.9);
		add(cg);

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if mobileC
 	 	addVirtualPad(FULL, A_B);
 	 	#end

		super.create();
	}


	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected == 0)
							menuItems.members[0].x += 2;
						if (curSelected != 1)
							menuItems.members[1].x -= 1;
						else
							menuItems.members[1].x += 1;
						menuItems.members[0].x -= 2;
						menuItems.members[0].y -= 1;
						menuItems.members[0].scale.set(0.97,0.97);
						spr.animation.play('go');
						var daChoice:String = optionShit[curSelected];

						switch (daChoice)
						{
							case 'MENUPLAY':
								var songArray:Array<String> = [];
								var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).songs;
								for (i in 0...leWeek.length) {
									songArray.push(leWeek[i][0]);
								}
					
								// Nevermind that's stupid lmao
								PlayState.storyPlaylist = songArray;
								PlayState.isStoryMode = true;
					
								var diffic = CoolUtil.difficultyStuff[2][1];
								if(diffic == null) diffic = '';
					
								PlayState.storyDifficulty = 2;
					
								PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
								PlayState.storyWeek = 0;
								PlayState.campaignScore = 0;
								PlayState.campaignMisses = 0;
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									LoadingState.loadAndSwitchState(new PlayState(), true);
									FreeplayState.destroyFreeplayVocals();
								});
							case 'FREEPLAY':
								MusicBeatState.switchState(new FreeplayState());
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							case 'CREDITS':
								MusicBeatState.switchState(new CreditsState());
							case 'OPTIONS':
								MusicBeatState.switchState(new OptionsState());
						}
					});
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		switch (curSelected)
		{
			case 0:
				cg.animation.play('idle');
			case 1:
				cg.animation.play('fix');
				cg.animation.finishCallback = function(fix)
					{
						cg.animation.play('fix2');
					}
			case 2:
				cg.animation.play('tape');
				cg.animation.finishCallback = function(tape)
					{
						cg.animation.play('tape2');
					}
			case 3:
				cg.animation.play('idle');
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.x = 0;
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				switch (spr.ID)
				{
					case 0:
						spr.offset.x = 10;
						spr.offset.y = 5;
					case 1:
						spr.offset.x = 13;
						spr.offset.y = 7;
					case 3:
						spr.offset.x = 11;
						spr.offset.y = 3;
				}
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
