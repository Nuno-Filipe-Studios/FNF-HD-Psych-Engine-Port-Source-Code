package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import GalleryData;

using StringTools;

class GallerySubState extends MusicBeatSubstate
{
	var images:Array<String>;
	var curSelected:Int = 0;
	public var camFollow:FlxObject;
	var artSprites:FlxTypedGroup<FlxSprite>;
	var colorBG:FlxSprite;
	var canSelect:Bool = true;
	var text:Alphabet;

	public function new(_images:Array<String>)
	{
		super();

		images = _images;
		trace(images);

		colorBG = new FlxSprite(-2700,-1500).makeGraphic(FlxG.width * 6, FlxG.height * 6 );
		colorBG.scrollFactor.set(0,0);
		add(colorBG);

		camFollow = new FlxObject(0, 0, 1, 1);

		artSprites = new FlxTypedGroup<FlxSprite>();
		add(artSprites);

		FlxG.camera.zoom = 0.2;

		for (i in 0...images.length) {
			var art:FlxSprite = new FlxSprite(4200 * i, 50).loadGraphic(Paths.image("gallery/art/" + images[i]));
			art.antialiasing = ClientPrefs.globalAntialiasing;
			artSprites.add(art);
		}

		camFollow.x = artSprites.members[0].getMidpoint().x;
		camFollow.y = artSprites.members[0].getMidpoint().y;
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		FlxG.camera.focusOn(camFollow.getPosition());
		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
		if (controls.UI_LEFT_P && canSelect)
			changeSelection(-1);
		if (controls.UI_RIGHT_P && canSelect)
			changeSelection(1);
		if (controls.UI_UP_P)
			camFollow.y += 5;
		if (controls.UI_DOWN_P)
			camFollow.y -= 5;
		if (controls.UI_UP_P && FlxG.keys.pressed.SHIFT)
			camFollow.y += 20;
		if (controls.UI_DOWN_P && FlxG.keys.pressed.SHIFT)
			camFollow.y -= 20;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0):Void
	{
		canSelect = false;
		curSelected += change;

		if (curSelected < 0)
			curSelected = images.length - 1;
		if (curSelected >= images.length)
			curSelected = 0;

        switch (images[curSelected]) {
			case 'bf':
				tweencol(79, 88, 151);
			case 'gf':
				tweencol(184, 90, 186);
			case 'dad':
				tweencol(228, 188, 74);
			case 'skump':
				tweencol(103, 76, 208);
			case 'monster':
				tweencol(61, 91, 62);
			case 'pico':
				tweencol(160, 56, 137);
			case 'darnell':
				tweencol(73, 144, 57);
			case 'nene':
				tweencol(57, 106, 144);
			case 'mom':
				tweencol(194, 85, 163);
			case 'sonic':
				tweencol(146, 113, 253);
			case 'carol':
				tweencol(151, 36, 60);
		}

		FlxTween.tween(camFollow, {x : artSprites.members[curSelected].getMidpoint().x, y:artSprites.members[curSelected].getMidpoint().y}, 0.8, {ease: FlxEase.smoothStepOut, onComplete: function(twn:FlxTween){canSelect = true;}});
	}

	function tweencol(color1:Int, color2:Int, color3:Int) {
		FlxTween.color(colorBG, 1.0, colorBG.color,FlxColor.fromRGB(color1, color2, color3));
	}
}