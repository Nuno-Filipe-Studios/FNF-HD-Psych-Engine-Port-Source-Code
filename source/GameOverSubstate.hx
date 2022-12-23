package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var lmao:FlxText;
	var textCrap:String = '';
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;

		var dodgeKeys = ClientPrefs.keyBinds.get('dodge');

		var keysText = getKey(dodgeKeys[0]).toUpperCase() //yeah i used this code from wednesdays infidelity, yeah so credits to their awesome work
			+ (!checkKey(getKey(dodgeKeys[0])) && !checkKey(getKey(dodgeKeys[1])) ? " " : "")
			+ getKey(dodgeKeys[1]).toUpperCase();

		if(PlayState.poleDeathCounter < 4) {
			textCrap = 'Try pressing ' + keysText + 'next time';
		} else if(PlayState.poleDeathCounter == 4) {
			textCrap = 'Ok so just press ' + keysText + "it's not that hard";
		} else if(PlayState.poleDeathCounter == 5) {
			textCrap = 'BRO! PRESS ' + keysText + 'GOD DAMN IT';
		} else if(PlayState.poleDeathCounter == 6) {
			textCrap = 'PRESS ' + keysText + 'PLEASE';
		} else if(PlayState.poleDeathCounter == 7) {
			textCrap = keysText + keysText + keysText + keysText + keysText + keysText + keysText + keysText + keysText + keysText;
		} else if(PlayState.poleDeathCounter == 8) {
			textCrap = 'I give up...';
		} else if(PlayState.poleDeathCounter > 8) {
			textCrap = '...';
		}

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		lmao = new FlxText(0, 600, 0, textCrap, 32);
		lmao.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0, 2, 1);
		lmao.alpha = 0;
		lmao.scrollFactor.set();
		lmao.screenCenter(FlxAxes.X);
		add(lmao);

		if(PlayState.gofuckingdecked && !isEnding) {
			new FlxTimer().start(1, function(e:FlxTimer) {
				FlxTween.tween(lmao, {alpha: 1}, 0.7, {ease: FlxEase.quadIn});
			});
		}

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		PlayState.fuckCval = false;
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.poleDeathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.gofuckingdecked = false;
			PlayState.badEnding = false;
			PlayState.fuckCval = false;

			if (PlayState.isStoryMode) {
				MusicBeatState.switchState(new StoryMenuState());
				FlxG.sound.music.stop();
			} else {
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}

			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.curStage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			if(PlayState.gofuckingdecked) {
				lmao.alpha = 1;
			}
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
					PlayState.gofuckingdecked = false;
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}

	function getKey(t)
	{
		var s = InputFormatter.getKeyName(t);

		return checkKey(s) ? '' : s;
	}

	function checkKey(s)
	{
		return !(s != null && s != '---');
	}
}
