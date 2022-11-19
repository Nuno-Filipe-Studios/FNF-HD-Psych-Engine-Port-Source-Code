package;

import flixel.addons.display.FlxExtendedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.animation.FlxAnimation;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import lime.utils.AssetCache;
import flixel.util.FlxTimer;
import flixel.FlxObject;

class SecretMenuState extends MusicBeatState
{
	var txtOptionTitle:FlxText;
	var weeks:Array<String> = ['week1', 'week3'];

	var weekImages:Array<Dynamic> =[
		['void', 'bf', 'void'],
		['void','pico', 'void'],
	];
	var weekTexts:FlxTypedGroup<FlxSprite>;
	var selectionBG:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;
	var checkers:FlxBackdrop;
	var logoBl:FlxSprite;
	var rightArrow:FlxSprite;
	var leftArrow:FlxSprite;
	var art:FlxSprite;
	var blackBG:BGSprite;
	var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
	var artSprites:FlxTypedGroup<FlxSprite>;
	var stopspamming:Bool = false;
	var canSelect:Bool = true;
	var isDebug:Bool = false;
	var Text:FlxText;
	var Text1:FlxText;
	var Text2:FlxText;
	var Text3:FlxText;
	var Text4:FlxText;
	private var shit:FlxObject;
	override function create()
	{

		#if debug
		isDebug = true;
		#end
		
		shit = new FlxObject(0, 0, 1, 1);

		Conductor.changeBPM(95);
		FlxG.sound.playMusic(Paths.music('gallery'), 1);
		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 720,FlxColor.fromRGB(69, 108, 207), false);
		add(bg);

		checkers = new FlxBackdrop(Paths.image('gallery/checkers'), 0, 0, true, true, 0, 0);
		checkers.velocity.x = 20;
		checkers.velocity.y = 20;
		add(checkers);

		weekTexts = new FlxTypedGroup<FlxSprite>();
		selectionBG = new FlxTypedGroup<FlxSprite>();
		add(selectionBG);
		add(weekTexts);

		rightArrow = new FlxSprite(1100, 300);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrow);

		leftArrow = new FlxSprite(200, 300);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrow);

		Text = new FlxText(200, 100, 640, "Choose Your", 40);
		Text.scrollFactor.set(0, 0);
		Text.setFormat(Paths.font("funkin.ttf"), 45, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Text.antialiasing = ClientPrefs.globalAntialiasing;
		Text.borderSize = 2;
		Text.borderQuality = 2;
		add(Text);

		Text1 = new FlxText(Text.x + 20, Text.y + 35, 640, "Character", 40);
		Text1.scrollFactor.set(0, 0);
		Text1.setFormat(Paths.font("funkin.ttf"), 45, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Text1.antialiasing = ClientPrefs.globalAntialiasing;
		Text1.borderSize = 2;
		Text1.borderQuality = 2;
		add(Text1);

		Text2 = new FlxText(930, 100, 640, "WARNING :", 40);
		Text2.scrollFactor.set(0, 0);
		Text2.setFormat(Paths.font("funkin.ttf"), 45, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Text2.antialiasing = ClientPrefs.globalAntialiasing;
		Text2.borderSize = 2;
		Text2.borderQuality = 2;
		add(Text2);

		Text3 = new FlxText(Text2.x - 110, Text2.y + 30, 640, "You can only play as pico", 40);
		Text3.scrollFactor.set(0, 0);
		Text3.setFormat(Paths.font("funkin.ttf"), 45, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Text3.antialiasing = ClientPrefs.globalAntialiasing;
		Text3.borderSize = 2;
		Text3.borderQuality = 2;
		add(Text3);

		Text4 = new FlxText(Text3.x + 70, Text3.y + 40, 640, "in Story Mode!", 40);
		Text4.scrollFactor.set(0, 0);
		Text4.setFormat(Paths.font("funkin.ttf"), 45, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Text4.antialiasing = ClientPrefs.globalAntialiasing;
		Text4.borderSize = 2;
		Text4.borderQuality = 2;
		add(Text4);

		blackBG = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
		blackBG.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.BLACK);
		blackBG.visible = false;
		add(blackBG);
	
		for (i in 0...weeks.length){
			var weekText:FlxSprite = new FlxSprite(20 + (300 * i), 40).loadGraphic(Paths.image('storymenu/' + weeks[i]));
			weekText.antialiasing = ClientPrefs.globalAntialiasing;
			weekText.ID = i;
			weekText.visible = false;
			weekText.setGraphicSize(Std.int(weekText.width * 0.7));
			weekTexts.add(weekText);
		}

		artSprites = new FlxTypedGroup<FlxSprite>();
		add(artSprites);

		for (i in 0...weekImages[0].length){
			art = new FlxSprite(60 +(400 * i), 70).loadGraphic(Paths.image('gallery/art/' + weekImages[0][i]));
			art.setGraphicSize(Std.int(art.width * 0.20));
			art.updateHitbox();
			art.antialiasing = ClientPrefs.globalAntialiasing;
			artSprites.add(art);
		}

		changeCharacter();

		super.create();
	}

	override public function update(elapsed:Float){
	
		if (controls.UI_RIGHT_P && canSelect)
			changeCharacter(1);
		if (controls.UI_LEFT_P && canSelect)
			changeCharacter(-1);
		if (controls.UI_RIGHT)
			rightArrow.animation.play('press')
		else
			rightArrow.animation.play('idle');
		if (controls.UI_LEFT)
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');

		if (controls.ACCEPT) {
			selectCharacter(curSelected);
			stopspamming = true;
			canSelect = false;
		}
		if (controls.BACK) {
			checkers.velocity.x = 0;
			checkers.velocity.y = 0;
			stopspamming = true;
			canSelect = false;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new StoryMenuState());
		}

		if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	public function changeCharacter(change:Int = 0):Void{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);

		curSelected += change;

		if (curSelected >= weeks.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = weeks.length - 1;

		weekTexts.forEach(function(weekText:FlxSprite){
			if (weekText.ID == curSelected)
				FlxTween.tween(weekText, {alpha: 0}, 1,{type:PINGPONG});
			else
			{
				FlxTween.cancelTweensOf(weekText);
				weekText.alpha = 1;
			}
		});
		artSprites.members[0].loadGraphic(Paths.image('gallery/art/' + weekImages[curSelected][0]));
		artSprites.members[1].loadGraphic(Paths.image('gallery/art/' + weekImages[curSelected][1]));
		artSprites.members[2].loadGraphic(Paths.image('gallery/art/' + weekImages[curSelected][2]));
	}

	function selectCharacter(selection:Int) {
		FlxG.sound.music.stop();
		blackBG.visible = true;
		FlxG.camera.flash(FlxColor.WHITE, 1.3);
		FlxG.sound.play(Paths.sound('confirmMenu'));
		if(curSelected == 0) {
			ClientPrefs.PicoPlayer = false;
			trace('Boyfriend Selected');
			new FlxTimer().start(1.3, function(tmr:FlxTimer) {
				MusicBeatState.switchState(new StoryMenuState());
			});
		} else if(curSelected == 1) {
			ClientPrefs.PicoPlayer = true;
			trace('Pico Selected');
			new FlxTimer().start(1.3, function(tmr:FlxTimer) {
				MusicBeatState.switchState(new StoryMenuState());
			});
		}
	}
}