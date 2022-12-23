package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.util.FlxAxes;
import flixel.effects.FlxFlicker;
import animateatlas.AtlasFrameMaker;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flash.system.System;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import Conductor.Rating;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;
	public static var pubCurBeat = 0;

	public static var ratingStuff:Array<Dynamic> = [
		['You Are Trash Bro!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var modchartObjects:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var isDateStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var fuckCval:Bool = false;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	var isStressed:String;
	var blammedAnim:String = "";
	var blammedAnimPicoPlayer:String = "";
	//var lampMilf:Int = 320;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private var camDoTheThing:Bool = true;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	
	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camOverlay:FlxCamera;
	public var camDialogue:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogueJson:DialogueFile = null;
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var bg:BGSprite;
	var stageFront:BGSprite;
	var stageCurtains:BGSprite;
	var freshCrowd:BGSprite;
	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;
	var dadbattleSpotlightEventTimer:FlxTimer;
	var dadbattleSmokesTween:FlxTween;

	var halloweenBG:BGSprite;
	var railing:BGSprite;
	var overlaySpook:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var boppers:Week3Boppers;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var OGlimo:BGSprite;
	var OGfastCar:BGSprite;
	var OGlimoMetalPole:BGSprite;
	var OGlimoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var OGbgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;

	var billboard:BGSprite;
	var limo:BGSprite;
	var skyBG:BGSprite;
	var dodgelamp:BGSprite;
	var dodgepole:BGSprite;
	var hitbox:BGSprite;
	var bgLimo:BGSprite;
	var rails:BGSprite;
	var road:BGSprite;
	var michael:HDBackgroundDancer;
	var alvin:HDBackgroundDancer;
	var bojangles:HDBackgroundDancer;
	var bubbles:HDBackgroundDancer;
	var michaelDead:HDBackgroundDancerDead;
	var alvinDead:HDBackgroundDancerDead;
	var bojanglesDead:HDBackgroundDancerDead;
	var bubblesDead:HDBackgroundDancerDead;
	var fastCar:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var ayoLookOut:BGSprite;
	//var overlayShit:BGSprite;
	public var overlay:BGSprite;
	var momLaser:BGSprite;
	var dodgeEvent:Bool = false;
	public static var badEnding:Bool = false;

	var upperBoppers:BGSprite;
	var bgEscalator:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var overlayChristmas:BGSprite;
	var heyTimer:Float;

	var overlayPoison:BGSprite;
	var startDrain:Bool = false;
	var gfFallTimer:FlxTimer;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var datebg:BGSprite;
	var overlayDate:BGSprite;

	var platforms:BGSprite;
	var amy:Amy;
	var leftBoppers:BGSprite;
	var rightBoppers:BGSprite;
	var platformsTween:FlxTween;
	var amyTween:FlxTween;
	var leftBoppersTween:FlxTween;
	var rightBoppersTween:FlxTween;

	var superTransform:BGSprite;
	var grass:BGSprite;
	var terrain:BGSprite;
	var clouds:BGSprite;
	var trees:BGSprite;
	var sonicBody:BGSprite = null;
	var bfBody:BGSprite;
	var bgDarken:BGSprite;
	var aura:BGSprite = null;
	var boomCamTween:FlxTween;

	var foreground:BGSprite;
	var wiggleEffect:WiggleEffect;

	var bgStudio:BGSprite;
	var mom:BGSprite;
	var imp:BGSprite;

	var car:BGSprite;

	var white:BGSprite;

	var tiddies:BGSprite;

	var talking:Bool = true;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var supershit:Bool = false;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var poleDeathCounter:Int = 0;
	public static var gofuckingdecked:Bool = false;
	public static var gftiddies:Bool = false;
	public static var timerStop:Bool = false;
	public static var poleTimer:FlxTimer;
	public static var EasterEggTimer:FlxTimer;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;
	
	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('dodge'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camOverlay = new FlxCamera();
		camHUD = new FlxCamera();
		camDialogue = new FlxCamera();
		camOther = new FlxCamera();

		camOverlay.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camDialogue.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camOverlay, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camDialogue, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = PlayState.SONG.stage;
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'tutorial':
					curStage = 'stage-tutorial';
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				case 'breaking-point':
					curStage = 'date';
				case 'green-hill':
					curStage = 'green-hills';
				case 'racing' | 'boom':
					curStage = 'sonic-stage';
				case 'happy-time':
					curStage = 'omochao-stage';
				case 'blueballed':
					curStage = 'studio';
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
				isDateStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		isDateStage = stageData.isDateStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
		
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage-tutorial': //Week Tutorial
				if(!ClientPrefs.OldHDbg) {
					bg = new BGSprite('stageback', -626, -437, 0.9, 0.9);
					bg.setGraphicSize(Std.int(bg.width * 0.5));
					bg.updateHitbox();
					add(bg);

					stageFront = new BGSprite('stagefront', -657, 620, 0.98, 0.98);
					stageFront.setGraphicSize(Std.int(stageFront.width * 0.6), Std.int(stageFront.height * 0.6));
					stageFront.updateHitbox();
					add(stageFront);

					if(!ClientPrefs.lowQuality) {
						var stageLight:BGSprite = new BGSprite('stage_light', 70, 20, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						add(stageLight);

						var stageLight:BGSprite = new BGSprite('stage_light', 1400, 20, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						stageLight.flipX = true;
						add(stageLight);

						stageCurtains = new BGSprite('stagecurtains', -309, -108, 1.3, 1.3);
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.47));
						stageCurtains.updateHitbox();
					}
				} else {
					bg = new BGSprite('stageback-old', -1500, -1200, 0.9, 0.9);
					bg.setGraphicSize(Std.int(bg.width * 0.5));
					add(bg);

					stageFront = new BGSprite('stagefront-old', -650, 600, 0.98, 0.98);
					stageFront.setGraphicSize(Std.int(stageFront.width * 0.6));
					stageFront.updateHitbox();
					add(stageFront);

					if(!ClientPrefs.lowQuality) {
						var stageLight:BGSprite = new BGSprite('stage_light', 90, -50, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						add(stageLight);

						var stageLight:BGSprite = new BGSprite('stage_light', 1400, -50, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						stageLight.flipX = true;
						add(stageLight);

						stageCurtains = new BGSprite('stagecurtains-old', -309, -108, 1.3, 1.3);
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.47));
						stageCurtains.updateHitbox();
					}
				}

			case 'stage': //Week 1
				if(!ClientPrefs.OldHDbg) {
					bg = new BGSprite('stageback', -626, -437, 0.9, 0.9);
					bg.setGraphicSize(Std.int(bg.width * 0.5));
					bg.updateHitbox();
					add(bg);

					stageFront = new BGSprite('stagefront', -657, 620, 0.98, 0.98);
					stageFront.setGraphicSize(Std.int(stageFront.width * 0.6), Std.int(stageFront.height * 0.6));
					stageFront.updateHitbox();
					add(stageFront);

					if(!ClientPrefs.lowQuality) {
						var stageLight:BGSprite = new BGSprite('stage_light', 70, 20, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						add(stageLight);

						var stageLight:BGSprite = new BGSprite('stage_light', 1400, 20, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						stageLight.flipX = true;
						add(stageLight);

						stageCurtains = new BGSprite('stagecurtains', -309, -108, 1.3, 1.3);
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.47));
						stageCurtains.updateHitbox();
				
						switch (SONG.song.toLowerCase()) {
							case 'bopeebo':
								freshCrowd = new BGSprite('CROWD_FRESH', -191, 730, 1.3, 1.3, ['crowd']);
								freshCrowd.setGraphicSize(Std.int(freshCrowd.width * 1.8));
								freshCrowd.updateHitbox();
								freshCrowd.visible = false;

							case 'fresh':
								freshCrowd = new BGSprite('CROWD_FRESH', -191, 730, 1.3, 1.3, ['crowd']);
								freshCrowd.setGraphicSize(Std.int(freshCrowd.width * 1.8));
								freshCrowd.updateHitbox();

							case 'dad battle':
								freshCrowd = new BGSprite('CROWD_DADBATTLE', -191, 730, 1.3, 1.3, ['crowd 2']);
								freshCrowd.setGraphicSize(Std.int(freshCrowd.width * 1.8));
								freshCrowd.updateHitbox();
						}
					}
					dadbattleSmokes = new FlxSpriteGroup(); //troll'd
				} else {
					bg = new BGSprite('stageback-old', -1500, -1200, 0.9, 0.9);
					bg.setGraphicSize(Std.int(bg.width * 0.5));
					add(bg);

					stageFront = new BGSprite('stagefront-old', -650, 600, 0.98, 0.98);
					stageFront.setGraphicSize(Std.int(stageFront.width * 0.6));
					stageFront.updateHitbox();
					add(stageFront);

					if(!ClientPrefs.lowQuality) {
						var stageLight:BGSprite = new BGSprite('stage_light', 90, -50, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						add(stageLight);

						var stageLight:BGSprite = new BGSprite('stage_light', 1400, -50, 1, 1);
						stageLight.setGraphicSize(Std.int(stageLight.width * 0.6));
						stageLight.updateHitbox();
						stageLight.flipX = true;
						add(stageLight);

						stageCurtains = new BGSprite('stagecurtains-old', -300, -200, 1.3, 1.3);
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.47));
						stageCurtains.updateHitbox();
				
						switch (SONG.song.toLowerCase()) {
							case 'bopeebo':
								freshCrowd = new BGSprite('CROWD_FRESH', -180, 640, 1.3, 1.3, ['crowd']);
								freshCrowd.setGraphicSize(Std.int(freshCrowd.width * 1.8));
								freshCrowd.updateHitbox();
								freshCrowd.visible = false;

							case 'fresh':
								freshCrowd = new BGSprite('CROWD_FRESH', -180, 640, 1.3, 1.3, ['crowd']);
								freshCrowd.setGraphicSize(Std.int(freshCrowd.width * 1.8));
								freshCrowd.updateHitbox();

							case 'dad battle':
								freshCrowd = new BGSprite('CROWD_DADBATTLE', -180, 640, 1.3, 1.3, ['crowd 2']);
								freshCrowd.setGraphicSize(Std.int(freshCrowd.width * 1.8));
								freshCrowd.updateHitbox();
						}
					}
					dadbattleSmokes = new FlxSpriteGroup(); //troll'd
				}

				precacheList.set('Lights_Shut_off', 'sound');

			case 'spooky': //Week 2
				if(!ClientPrefs.OldHDbg) {
					if(!ClientPrefs.lowQuality) {
						railing = new BGSprite('railing', -125, -80, 0.9, 0.9);

						overlaySpook = new BGSprite('overlay', -40, 50);
						overlaySpook.setGraphicSize(Std.int(overlaySpook.width * 1.5));

						halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
					} else {
						halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
					}
					add(halloweenBG);
				} else {
					if(!ClientPrefs.lowQuality) {
						overlaySpook = new BGSprite('overlay', -40, 50);
						overlaySpook.setGraphicSize(Std.int(overlaySpook.width * 1.5));

						halloweenBG = new BGSprite('halloween_bg-old', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
					} else {
						halloweenBG = new BGSprite('halloween_bg_low-old', -200, -100);
					}
					add(halloweenBG);
				}
				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.OldHDbg) {
					if(!ClientPrefs.lowQuality) {
						var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
						add(bg);
					}
				
					var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<BGSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
						phillyWindow = new BGSprite('philly/window' + i, city.x, city.y, 0.3, 0.3);
						phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
						phillyWindow.updateHitbox();
						phillyCityLights.add(phillyWindow);
						phillyWindow.alpha = 0;
					}

					if(!ClientPrefs.lowQuality) {
						var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
						add(streetBehind);
					}
				
					if(SONG.song.toLowerCase() == "blammed") {
						phillyTrain = new BGSprite('philly/trainBlood', 2000, 360);
					} else {
						phillyTrain = new BGSprite('philly/train', 2000, 360);
					}

					add(phillyTrain);

					phillyStreet = new BGSprite('philly/street', -40, 50);
					add(phillyStreet);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					boppers = new Week3Boppers(0, 0);
					boppers.visible = false;
					add(boppers);
				} else {
					if(!ClientPrefs.lowQuality) {
						var bg:BGSprite = new BGSprite('phillyOld/sky', -100, 0, 0.1, 0.1);
						add(bg);
					}

					var city:BGSprite = new BGSprite('phillyOld/city', -10, -15, 0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<BGSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
						phillyWindow = new BGSprite('philly/window' + i, city.x, city.y, 0.3, 0.3);
						phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
						phillyWindow.updateHitbox();
						phillyCityLights.add(phillyWindow);
						phillyWindow.alpha = 0;
					}

					if(!ClientPrefs.lowQuality) {
						var streetBehind:BGSprite = new BGSprite('phillyOld/behindTrain', -40, 0);
						add(streetBehind);
					}
				
					if(SONG.song.toLowerCase() == "blammed") {
						phillyTrain = new BGSprite('philly/trainBlood', 2000, 360);
					}
					else{
						phillyTrain = new BGSprite('philly/train', 2000, 360);
					}

					add(phillyTrain);

					phillyStreet = new BGSprite('phillyOld/street', -40, 0);
					add(phillyStreet);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					boppers = new Week3Boppers(0, 0);
					boppers.visible = false;
					add(boppers);
				}

			case 'philly-picoPlayer': //Week 3 Pico Player
				if(!ClientPrefs.OldHDbg) {
					if(!ClientPrefs.lowQuality) {
						var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
						add(bg);
					}
				
					var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<BGSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
						phillyWindow = new BGSprite('philly/window' + i, city.x, city.y, 0.3, 0.3);
						phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
						phillyWindow.updateHitbox();
						phillyCityLights.add(phillyWindow);
						phillyWindow.alpha = 0;
					}

					if(!ClientPrefs.lowQuality) {
						var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
						add(streetBehind);
					}
				
					if(SONG.song.toLowerCase() == "blammed") {
						phillyTrain = new BGSprite('philly/trainBlood', 2000, 360);
					} else {
						phillyTrain = new BGSprite('philly/train', 2000, 360);
					}

					add(phillyTrain);

					phillyStreet = new BGSprite('philly/street', -40, 50);
					add(phillyStreet);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					boppers = new Week3Boppers(0, 0);
					boppers.visible = false;
					add(boppers);
				} else {
					if(!ClientPrefs.lowQuality) {
						var bg:BGSprite = new BGSprite('phillyOld/sky', -100, 0, 0.1, 0.1);
						add(bg);
					}

					var city:BGSprite = new BGSprite('phillyOld/city', -10, -15, 0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<BGSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
						phillyWindow = new BGSprite('philly/window' + i, city.x, city.y, 0.3, 0.3);
						phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
						phillyWindow.updateHitbox();
						phillyCityLights.add(phillyWindow);
						phillyWindow.alpha = 0;
					}

					if(!ClientPrefs.lowQuality) {
						var streetBehind:BGSprite = new BGSprite('phillyOld/behindTrain', -40, 0);
						add(streetBehind);
					}
				
					if(SONG.song.toLowerCase() == "blammed") {
						phillyTrain = new BGSprite('philly/trainBlood', 2000, 360);
					}
					else{
						phillyTrain = new BGSprite('philly/train', 2000, 360);
					}

					add(phillyTrain);

					phillyStreet = new BGSprite('phillyOld/street', -40, 0);
					add(phillyStreet);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					boppers = new Week3Boppers(0, 0);
					boppers.visible = false;
					add(boppers);
				}

			case 'limo-og': //Week 4 OG and do NOT delete this or week 4 HD won't work
				var skyBG:BGSprite = new BGSprite('limoOG/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					OGlimoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(OGlimoMetalPole);

					OGbgLimo = new BGSprite('limoOG/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(OGbgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, OGlimoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, OGlimoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					OGlimoLight = new BGSprite('gore/coldHeartKiller', OGlimoMetalPole.x - 180, OGlimoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limoOG/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limoOG/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'limo': //Week 4, making this stage functional was a huge pain in the ass
				var kolsan = FlxColor.BLACK;

				ayoLookOut = new BGSprite('limo/Warning', 80, 0);
				ayoLookOut.screenCenter(FlxAxes.Y);
				ayoLookOut.visible = false;
				ayoLookOut.scrollFactor.set();

				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -300, -600, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.OldHDbg) {
					if(!ClientPrefs.lowQuality) {
						billboard = new BGSprite('limo/billboards', -300, -210, 0.2, 0.2, ['billboards']);
						for (i in 0...8){
							billboard.animation.addByIndices('' + i, 'billboards', [i], "", 24, false);
						}
					}
				} else {
					if(!ClientPrefs.lowQuality) {
						billboard = new BGSprite('limo/billboards-old', -300, -210, 0.2, 0.2, ['billboards instance 1']);
						for (i in 0...8){
							billboard.animation.addByIndices('' + i, 'billboards instance 1', [i], "", 24, false);
						}
					}
				}
				billboard.setGraphicSize(Std.int(billboard.width * 0.7));
				billboard.active = true;
				billboard.updateHitbox();
				add(billboard);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite(null, -820, -85, 0.3, 0.3);
					limoMetalPole.loadGraphic(Paths.image('gore/metalPole'));
					limoMetalPole.setGraphicSize(Std.int(limoMetalPole.width * 0.5));
					limoMetalPole.updateHitbox();
					limoMetalPole.flipX = true;
					limoMetalPole.active = true;
					add(limoMetalPole);

					limoLight = new BGSprite(null, -830, -100, 0.3, 0.3);
					limoLight.loadGraphic(Paths.image('gore/coldHeartKiller'));
					limoLight.setGraphicSize(Std.int(limoLight.width * 0.5));
					limoLight.updateHitbox();
					limoLight.flipX = true;
					limoLight.active = true;
				}

				if(!ClientPrefs.OldHDbg) {
					rails = new BGSprite('limo/railing', -2150, 450, 0.3, 0.3, ['railing']);
					rails.animation.addByIndices('rails', 'railing', [0,1,2,3,4,5,6,7,8,9], '', 24, true);
					rails.animation.play('rails');
					add(rails);

					road = new BGSprite('limo/street', -1150, 500, 0.3, 0.3, ['street']);
					road.animation.addByPrefix('woadUwU', 'street', 35, true);
					road.animation.play('woadUwU');
					add(road);

					if(!ClientPrefs.lowQuality) {
						bgLimo = new BGSprite('limo/bgLimo', -200, 280, 0.4, 0.4, ['BG limo instance 1'], true);
						add(bgLimo);
					}
				} else {
					rails = new BGSprite('limo/week4ShitIdk', -2150, 450, 0.3, 0.3, ['railing instance 1']);
					rails.animation.addByPrefix('rails', 'railing instance 1', 20, true);
					rails.animation.play('rails');
					add(rails);

					road = new BGSprite('limo/week4ShitIdk', -1150, 500, 0.3, 0.3, ['street instance 1'], true);
					add(road);

					if(!ClientPrefs.lowQuality) {
						bgLimo = new BGSprite('limo/week4ShitIdk', -202, 280, 0.4, 0.4, ['BG limo instance 1'], true);
						add(bgLimo);
					}
				}

				if(!ClientPrefs.lowQuality) {
					//Dancers sprites

					michael = new HDBackgroundDancer(175, bgLimo.y -385, 'michael'); //Dancer 1
					michael.scrollFactor.set(0.4,0.4);
					add(michael);

					alvin = new HDBackgroundDancer(michael.x + 270, bgLimo.y -362, 'alvin'); //Dancer 2
					alvin.scrollFactor.set(0.4,0.4);
					add(alvin);

					bojangles = new HDBackgroundDancer(alvin.x + 270, bgLimo.y -385, 'bojangles'); //Dancer 3
					bojangles.scrollFactor.set(0.4,0.4);
					add(bojangles);

					bubbles = new HDBackgroundDancer(bojangles.x + 270, bgLimo.y -368, 'bubbles'); //Dancer 4
					bubbles.scrollFactor.set(0.4,0.4);
					add(bubbles);

					//Dead Dancers Sprites

					michaelDead = new HDBackgroundDancerDead(250, bgLimo.y -520, 'michael');
					michaelDead.scrollFactor.set(0.4,0.4);
					add(michaelDead);

					alvinDead = new HDBackgroundDancerDead(520, bgLimo.y -535, 'alvin');
					alvinDead.scrollFactor.set(0.4,0.4);
					add(alvinDead);

					bojanglesDead = new HDBackgroundDancerDead(790, bgLimo.y -525, 'bojangles');
					bojanglesDead.scrollFactor.set(0.4,0.4);
					add(bojanglesDead);

					bubblesDead = new HDBackgroundDancerDead(1070, bgLimo.y -525, 'bubbles');
					bubblesDead.scrollFactor.set(0.4,0.4);
					add(bubblesDead);

					precacheList.set('dancerdeath', 'sound');
				}

				precacheList.set('warning', 'sound');
				precacheList.set('thud', 'sound');

				if(!ClientPrefs.OldHDbg) {
					limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage']);
				} else {
					limo = new BGSprite('limo/limoDrive', -125, 550, 1, 1, ['Limo stage']);
				}

				fastCar = new BGSprite('limo/fastCarLol', -300, 100);
				fastCar.active = true;

				var dumbass:Int = 0;

				switch (SONG.song.toLowerCase())
				{
					case 'satin panties':
						dumbass = 14;
					case 'high':
						dumbass = 60;
					case 'milf':
						skyBG.y += 300;
						dumbass = 73;
				}

				dodgepole = new BGSprite(null, 400, -140);
				dodgepole.loadGraphic(Paths.image('gore/metalPole'));
				dodgepole.active = true;

				dodgelamp = new BGSprite(null, 250, -130);
				dodgelamp.loadGraphic(Paths.image('gore/coldHeartKiller'));
				dodgelamp.width -= 300;
				dodgelamp.height -= 200;
				dodgelamp.active = true;

				hitbox = new BGSprite(null, 250, -130);
				hitbox.makeGraphic(250, 250, kolsan);
				hitbox.active = true;
				hitbox.visible = false;

				if(!ClientPrefs.lowQuality) {
					overlay = new BGSprite(null, 0, 0, 0, 0);
					overlay.makeGraphic(1280, 720, FlxColor.fromRGB(235, 90, 63, dumbass));
					overlay.blend = 'multiply';
					overlay.cameras = [camOverlay];
				}

			case 'mall': //Week 5 - Cocoa, Eggnog
				var suffix:String = '';

				if (SONG.song.toLowerCase() == 'eggnog')
					suffix = '-eggnog'; //suffix that changes the bgEscalator and the upperBoppers sprites in Eggnog

				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -430, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop' + suffix, -480, -220, 0.3, 0.3, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.9));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					bgEscalator = new BGSprite('christmas/bgEscalator' + suffix, -700, -200, 0.3, 0.3, ['esc']);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					for (i in 0...3) {
						bgEscalator.animation.addByPrefix('' + i,'esc' + i, 1, false);
					}
					bgEscalator.updateHitbox();
					bgEscalator.animation.play('1');
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				if(!ClientPrefs.OldHDbg) {
					bottomBoppers = new BGSprite('christmas/bottomBop', 250, 200, 0.9, 0.9, ['Bottom Level Boppers']);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);
				} else {
					bottomBoppers = new BGSprite('christmas/bottomBopOld', -200, 200, 0.9, 0.9, ['Bottom Level Boppers']);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);
				}
				
				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 770);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 220, 1, 1, ['santa idle in fear']);
				add(santa);

				if(!ClientPrefs.lowQuality) {
					overlayChristmas = new BGSprite(null, 0, 0);
					overlayChristmas.loadGraphic(Paths.image('christmas/overlay_christmas'));
					overlayChristmas.setGraphicSize(Std.int(overlayChristmas.width * 3), Std.int(overlayChristmas.height));
					overlayChristmas.updateHitbox();
					overlayChristmas.blend = 'multiply';
					overlayChristmas.scrollFactor.set(0,0);
					overlayChristmas.cameras = [camOverlay];
				}

				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

				if(!ClientPrefs.lowQuality) {
					overlayPoison = new BGSprite(null, 0, 0, 0, 0);
					overlayPoison.loadGraphic(Paths.image('christmas/overlay_poison'));
					overlayPoison.setGraphicSize(Std.int(overlayPoison.width * 3), Std.int(overlayPoison.height));
					overlayPoison.updateHitbox();
					overlayPoison.blend = 'multiply';
					overlayPoison.cameras = [camOverlay];
				}

			case 'school': //Week 6 - Senpai, Roses
				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));

			case 'date': //Date Week - Breaking Point
				if(!ClientPrefs.lowQuality) {
					datebg = new BGSprite('dateweek/date_night', -75,-65, ['MarblePawns instance 1'], true);
					datebg.animation.addByPrefix('stars', 'MarblePawns instance 1', 14, true);
					datebg.setGraphicSize(Std.int(datebg.width * 1.3));
					datebg.animation.play('stars');
				} else {
					datebg = new BGSprite('dateweek/date_night_low', -75,-65);
					datebg.setGraphicSize(Std.int(datebg.width * 1.3));
				}
				add(datebg);

				if(!ClientPrefs.lowQuality) {
					overlayDate = new BGSprite(null, 0, 0);
					overlayDate.makeGraphic(1280, 720,FlxColor.fromRGB(50, 173, 207, 107));
					overlayDate.blend = 'multiply';
					overlayDate.scrollFactor.set(0,0);
					overlayDate.cameras = [camOverlay];
				}

			case 'green-hills': //Week Sonic - Green Hill
				var sky:BGSprite = new BGSprite('sonicshit/greenHillSky', 64, 87);
				add(sky);

				var greenBG:BGSprite = new BGSprite('sonicshit/greenHillBackground', 0, 0, 0.1, 0.1);
				add(greenBG);

				if (!ClientPrefs.lowQuality) {
					platforms = new BGSprite('sonicshit/platforms', 288, 413);
					platforms.screenCenter(Y);
					add(platforms);

					amy = new Amy(462, 120);
					amy.setGraphicSize(Std.int(amy.width * 0.5));
					amy.updateHitbox();
					add(amy);

					leftBoppers = new BGSprite('sonicshit/bopperFrames', 265, 80, ['left bop']);
					leftBoppers.setGraphicSize(Std.int(leftBoppers.width * 1.6));
					leftBoppers.updateHitbox();
					add(leftBoppers);

					rightBoppers = new BGSprite('sonicshit/bopperFrames', 985, 0, ['right bop']);
					rightBoppers.setGraphicSize(Std.int(rightBoppers.width * 1.6));
					rightBoppers.updateHitbox();
					add(rightBoppers);

					platformsTween = FlxTween.tween(platforms, {y:platforms.y + 40}, 1.4,{ease:FlxEase.smoothStepIn,type:FlxTweenType.PINGPONG});
					amyTween = FlxTween.tween(amy, {y:amy.y + 40}, 1.4,{ease:FlxEase.smoothStepIn,type:FlxTweenType.PINGPONG});
					leftBoppersTween = FlxTween.tween(leftBoppers, {y:leftBoppers.y + 40}, 1.4,{ease:FlxEase.smoothStepIn,type:FlxTweenType.PINGPONG});
					rightBoppersTween = FlxTween.tween(rightBoppers, {y:rightBoppers.y + 40}, 1.4,{ease:FlxEase.smoothStepIn,type:FlxTweenType.PINGPONG});
				}

				var grass:BGSprite = new BGSprite('sonicshit/greenHillGrass', 0, -10, 1, 1);
				add(grass);
			
			case 'sonic-stage': //Week Sonic - Racing, Boom
				precacheList.set('sonicSkid', 'sound');
				precacheList.set('ringDrop', 'sound');

				var ringLoad = new FlxSprite();
				ringLoad.frames = Paths.getSparrowAtlas("sonicshit/racing/ringSplash", "shared");
				ringLoad.antialiasing = ClientPrefs.globalAntialiasing;
				ringLoad.animation.addByPrefix("rings", "BF NOTE RIGHT MISS RING", 24, false);
				ringLoad.animation.play("rings", false, false, 0);

				superTransform = new BGSprite('sonicshit/racing/SUPER_SONIC_TRANSFORM', 0, 0, ['SONIC TRANSFORM']);
				superTransform.animation.addByIndices("transformStart", "SONIC TRANSFORM", [0,1], "", 12, false);
				superTransform.animation.addByIndices("transform", "SONIC TRANSFORM", [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25], "", 16, false);
				superTransform.visible = false;

				grass = new BGSprite('sonicshit/racing/greenHillRun', 100, 493, ['greenHillRun']);
				grass.animation.addByPrefix("greenHillRun", "greenHillRun", 36, true);
				grass.animation.play("greenHillRun");

				if (!ClientPrefs.lowQuality) {
					terrain = new BGSprite('sonicshit/racing/terrain', -418, 0, 0.2, 0.2);
				}

				var bg:BGSprite = new BGSprite('sonicshit/racing/sonicBoomSky');

				if (!ClientPrefs.lowQuality) {
					clouds = new BGSprite('sonicshit/racing/greenHillClouds', 0, 0, 0.2, 0.2, ['greenHillClouds']);
					clouds.animation.addByPrefix("greenHillClouds", "greenHillClouds", 24, true);
					clouds.animation.play("greenHillClouds");
				}

				trees = new BGSprite('sonicshit/racing/greenHillTrees', 0, 144, 0.9, 0.9, ['greenHillTrees']);
				trees.animation.addByPrefix("greenHillTrees", "greenHillTrees", 24, true);
				trees.animation.play("greenHillTrees");

				sonicBody = new BGSprite("sonicshit/sonicBody", 343, 440, ['SONIC RUN']);
				sonicBody.animation.addByPrefix("sonicBody", "SONIC RUN", 24, true);
				sonicBody.animation.play("sonicBody");
				sonicBody.visible = false;

				bfBody = new BGSprite('sonicshit/bfRunningBottom', 882, 385, ['BF BOTTOM']);
				bfBody.animation.addByPrefix("bfRunningBottom", "BF BOTTOM", 24, true);
				bfBody.animation.addByPrefix("bfRunningBottomFast", "BF BOTTOM", 48, true);
				bfBody.animation.addByPrefix("bf miss", "BF MISS", 24, false);
				bfBody.animation.play("bfRunningBottom");
				bfBody.visible = false;

				bgDarken = new BGSprite(null, -1280/2, -720/2);
				bgDarken.makeGraphic(1280*2, 720*2, FlxColor.BLACK);
				bgDarken.alpha = 0.75;
				bgDarken.visible = false;

				add(bg);
				add(terrain);
				add(clouds);
				add(trees);
				add(grass);
				add(bgDarken);
				add(sonicBody);
				add(bfBody);

			case 'omochao-stage': //Week Sonic, Happy Time
				wiggleEffect = new WiggleEffect();
				wiggleEffect.effectType = WiggleEffect.WiggleEffectType.WAVY;
				wiggleEffect.waveAmplitude = 0.04;
				wiggleEffect.waveFrequency = 15;
				wiggleEffect.waveSpeed = 0.9;

				var sky:BGSprite = new BGSprite('sonicshit/omochaoStage/chaoRaceSky');
				add(sky);

				var water:BGSprite = new BGSprite('sonicshit/omochaoStage/chaoRaceWater', 0, 280);
				water.shader = wiggleEffect.shader;
				add(water);

				/*if (!ClientPrefs.lowQuality) {
					var railing:BGSprite = new BGSprite('sonicshit/omochaoStage/chaoRaceRails', 0, 250);
					add(railing);
				}*/

				var greenBG:BGSprite = new BGSprite('sonicshit/omochaoStage/chaoRaceMiddle', 0, 0, 1, 1);
				add(greenBG);

				if (!ClientPrefs.lowQuality) {
					foreground = new BGSprite('sonicshit/omochaoStage/chaoRaceForeground', 0, 552, 1, 1);

					placeOmochao(-22, 378);
					placeOmochao(436, 340);
					placeOmochao(1506, 424);
					placeOmochao(986, 346);
				}

			case 'studio': //Week ??? - Blueballed
				bgStudio = new BGSprite('studioShit/studioRemix', -540, -190, ['entire studio']);
				bgStudio.updateHitbox();
				add(bgStudio);

				if(!ClientPrefs.lowQuality) {
					mom = new BGSprite('studioShit/momRemix', 660, -89, ['mom bop']);
					mom.updateHitbox();
					add(mom);
				}

				var chair:BGSprite = new BGSprite('studioShit/chairStudio', 559, 310);
				chair.updateHitbox();
				add(chair);

				if(!ClientPrefs.lowQuality) {
					imp = new BGSprite('studioShit/impRemix', -500, -20, ['imp']);
					imp.scale.set(0.8, 0.8);
					imp.updateHitbox();
				}

			case 'street': //Week C - Carol Roll, Body, Boogie
				var bg:BGSprite = new BGSprite('street_bg', -370, -50, 1, 1);
				bg.setGraphicSize(Std.int(bg.width * 1.29));
				add(bg);
				
				if(SONG.song.toLowerCase() == "boogie") {
					bg = new BGSprite('streetalt', -370, -50, 1, 1);
					bg.setGraphicSize(Std.int(bg.width * 1.29));
				} else {
					bg = new BGSprite('street', -370, -50, 1, 1);
					bg.setGraphicSize(Std.int(bg.width * 1.29));
				}

				add(bg);

				if(!ClientPrefs.lowQuality) {
					car = new BGSprite('Car', 0, 0, 0.7, 0.7, ['BRUMBRUM'], true);
					car.setGraphicSize(Std.int(car.width * 0.7));
					car.screenCenter();
					car.y += 700;
					car.x += -850;
				}

			case 'sky': //Week C - Hellroll
				var bg:BGSprite = new BGSprite('sky', -3000, -1450, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 0.38));
				add(bg);

				if(!ClientPrefs.lowQuality) {
					white = new BGSprite('WhiteVG', 0, 100, 0.9, 0.9);
					white.setGraphicSize(Std.int(white.width * 1.80));
				}
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		if(isDateStage) {
			introSoundsSuffix = '-date';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo-og' || curStage == 'limo') {
			add(limoLight);
			add(limo);
		}

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'stage-tutorial':
				add(stageCurtains);
			case 'stage':
				add(stageCurtains);
				add(freshCrowd);
			case 'spooky':
				add(railing);
				add(overlaySpook);
				add(halloweenWhite);
			case 'limo':
				add(dodgelamp);
				add(dodgepole);
				add(hitbox);
				add(ayoLookOut);
				add(overlay);
				ayoLookOut.cameras = [camHUD];
			case 'mall':
				add(overlayChristmas);
			case 'mallEvil':
				add(overlayPoison);
			case 'tank':
				add(foregroundSprites);
			case 'date':
				add(overlayDate);
			case 'sonic-stage':
				add(superTransform);
			case 'omochao-stage':
				add(foreground);
			case 'studio':
				add(imp);
			case 'street':
				add(car);
			case 'sky':
				add(white);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		if(!ClientPrefs.OldHDbg) {
			#if (MODS_ALLOWED && LUA_ALLOWED)
			var doPush:Bool = false;
			var luaFile:String = null;
			luaFile = 'stages/' + curStage + '.lua';
			if(FileSystem.exists(Paths.modFolders(luaFile))) {
				luaFile = Paths.modFolders(luaFile);
				doPush = true;
			} else {
				luaFile = Paths.getPreloadPath(luaFile);
				if(FileSystem.exists(luaFile)) {
					doPush = true;
				}
			}

			if(doPush)
				luaArray.push(new FunkinLua(luaFile));
			#end
		} else {
			#if (MODS_ALLOWED && LUA_ALLOWED)
			var doPush:Bool = false;
			var luaFile:String = null;
			luaFile = 'stages old/' + curStage + '.lua';
			if(FileSystem.exists(Paths.modFolders(luaFile))) {
				luaFile = Paths.modFolders(luaFile);
				doPush = true;
			} else {
				luaFile = Paths.getPreloadPath(luaFile);
				if(FileSystem.exists(luaFile)) {
					doPush = true;
				}
			}

			if(doPush)
				luaArray.push(new FunkinLua(luaFile));
			#end
		}

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{	
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall':
					gfVersion = 'gf-christmas';
				case 'mallEvil':
					gfVersion = 'gf-christmas-dead';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				case 'date':
					gfVersion = 'gf-date';
				case 'green-hills':
					gfVersion = 'gf-eggman';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);
		
		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		
		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo-og':
				resetFastCar();
				addBehindGF(fastCar);

			case 'limo':
				resetFastCar();
				resetBillBoard();
				resetPole();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("funkin.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("funkin.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 340, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(500, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG AND PEOPLE FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		//PRECACHING CUSTOM NOTES SOUNDS
		precacheList.set('shooters', 'sound');
		precacheList.set('laser', 'sound');
		precacheList.set('bwow', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		callOnLuas('onCreatePost', []);
		
		super.create();

		cacheCountdown();
		cachePopUpScore();
		if(dad.curCharacter == 'mom-car-horny' || dad.curCharacter == 'mom-car' || dad.curCharacter == 'hellchart-carol')
			cacheBeams();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		Paths.clearUnusedMemory();

		CustomFadeTransition.nextCamera = camOther;
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		if(!ClientPrefs.OldHDbg) {
			var doPush:Bool = false;
			var luaFile:String = null;
			luaFile = 'characters/' + name + '.lua';
			if(FileSystem.exists(Paths.modFolders(luaFile))) {
				luaFile = Paths.modFolders(luaFile);
				doPush = true;
			} else {
				luaFile = Paths.getPreloadPath(luaFile);
				if(FileSystem.exists(luaFile)) {
					doPush = true;
				}
			}
		
			if(doPush)
			{
				for (lua in luaArray)
				{
					if(lua.scriptName == luaFile) return;
				}
				luaArray.push(new FunkinLua(luaFile));
			}
		} else {
			var doPush:Bool = false;
			var luaFile:String = null;
			luaFile = 'characters old/' + name + '.lua';
			if(FileSystem.exists(Paths.modFolders(luaFile))) {
				luaFile = Paths.modFolders(luaFile);
				doPush = true;
			} else {
				luaFile = Paths.getPreloadPath(luaFile);
				if(FileSystem.exists(luaFile)) {
					doPush = true;
				}
			}
		
			if(doPush)
			{
				for (lua in luaArray)
				{
					if(lua.scriptName == luaFile) return;
				}
				luaArray.push(new FunkinLua(luaFile));
			}
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartObjects.exists(tag)) return modchartObjects.get(tag);
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	var endDialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			camHUD.visible = false;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					camHUD.visible = true;
					psychDialogue = null;
					endSong();
				}
				psychDialogue.nextDialogueThing = startNextEndDialogue;
				psychDialogue.skipDialogueThing = skipEndDialogue;
			} else {
				psychDialogue.finishThing = function() {
					camHUD.visible = true;
					psychDialogue = null;
					startCountdown();
				}
				psychDialogue.nextDialogueThing = startNextDialogue;
				psychDialogue.skipDialogueThing = skipDialogue;
			}
			psychDialogue.cameras = [camDialogue];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	function startCutscene(dialogueBox:DialogueBox){

		inCutscene = true;
		camHUD.visible = false;
		add(dialogueBox);

	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned && gf.dodgetime == 0 && gf.shootTime == 0)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned && boyfriend.dodgetime == 0 && boyfriend.shootTime == 0)
				{
					boyfriend.dance();
					if (curStage == "sonic-stage" && bfBody.animation.name == "bf miss") {
						bfBody.animation.play('bfRunningBottom');
						bfBody.offset.y = 0;
					}
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned && dad.dodgetime == 0 && dad.shootTime == 0)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				if(curStage == 'stage') {
					if(curSong.toLowerCase() == 'fresh' || curSong.toLowerCase() == 'dad battle' && !ClientPrefs.lowQuality)
						freshCrowd.dance(true);
				}

				if(curStage == 'green-hills') {
					if(!ClientPrefs.lowQuality) {
						amy.dance();
						leftBoppers.dance();
						rightBoppers.dance();
					}
				}

				if (curStage == 'limo') {
					limo.dance(true);
				}

				if(curStage == 'studio') {
					if(!ClientPrefs.lowQuality) {
						mom.dance(true);
						imp.dance(true);
					}
	
					bgStudio.dance(true);
				}

				if(curStage == 'philly') {
					if(!boppers.stopDancing && boppers.stopDancingTime == 0) {
						boppers.dance(true);
					}
				}

				if(curStage == 'philly-picoPlayer') {
					if(!boppers.stopDancing && boppers.stopDancingTime == 0) {
						boppers.dance(true);
					}
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function addInFrontGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup) + 1, obj);
	}
	public function addInFrontBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup) + 1, obj);
	}
	public function addInFrontDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup) + 1, obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'Score: ' + songScore
		+ ' | Misses: ' + songMisses
		+ ' | Rating: ' + ratingName
		+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	function startNextEndDialogue() {
		endDialogueCount++;
		callOnLuas('onNextEndDialogue', [endDialogueCount]);
	}

	function skipEndDialogue() {
		callOnLuas('onSkipEndDialogue', [endDialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1400 + offsetX, 820 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 820 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);

			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window0', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);
	
				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;
	
				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);

			case 'Trigger Sonic Transformation':
				superTransform.setPosition(dad.x + 30, dad.y - 160);
				superTransform.visible = false;
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill OG Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;
			if (bgLimoTween != null)
				bgLimoTween.active = false;
			if (platformsTween != null)
				platformsTween.active = false;
			if (amyTween != null)
				amyTween.active = false;
			if (leftBoppersTween != null)
				leftBoppersTween.active = false;
			if (rightBoppersTween != null)
				rightBoppersTween.active = false;
			if (dancersTween != null)
				dancersTween.active = false;
			if (dancersTween2 != null)
				dancersTween2.active = false;
			if (dancersTween3 != null)
				dancersTween3.active = false;
			if (dancersTween4 != null)
				dancersTween4.active = false;
			if (boomCamTween != null)
				boomCamTween.active = false;
			if (cameraTwn != null)
				cameraTwn.active = false;
			if (dadbattleSmokesTween != null)
				dadbattleSmokesTween.active = false;
			if (timerStop)
				poleTimer.active = false;

			if(carTimer != null) carTimer.active = false;

			if(bgLimoTimer != null) bgLimoTimer.active = false;

			if(bgLimoTimer2 != null) bgLimoTimer2.active = false;

			if(killDancersTimer != null) killDancersTimer.active = false;

			if(billboardTimer != null) billboardTimer.active = false;

			if(gfFallTimer != null) gfFallTimer.active = false;

			if(dadbattleSpotlightEventTimer != null) dadbattleSpotlightEventTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;
			if (bgLimoTween != null)
				bgLimoTween.active = true;
			if (platformsTween != null)
				platformsTween.active = true;
			if (amyTween != null)
				amyTween.active = true;
			if (leftBoppersTween != null)
				leftBoppersTween.active = true;
			if (rightBoppersTween != null)
				rightBoppersTween.active = true;
			if (dancersTween != null)
				dancersTween.active = true;
			if (dancersTween2 != null)
				dancersTween2.active = true;
			if (dancersTween3 != null)
				dancersTween3.active = true;
			if (dancersTween4 != null)
				dancersTween4.active = true;
			if (boomCamTween != null)
				boomCamTween.active = true;
			if (cameraTwn != null)
				cameraTwn.active = true;
			if (dadbattleSmokesTween != null)
				dadbattleSmokesTween.active = true;
			if (timerStop)
				poleTimer.active = true;

			if(carTimer != null) carTimer.active = true;

			if(bgLimoTimer != null) bgLimoTimer.active = true;

			if(bgLimoTimer2 != null) bgLimoTimer2.active = true;

			if(killDancersTimer != null) killDancersTimer.active = true;

			if(billboardTimer != null) billboardTimer.active = true;

			if(gfFallTimer != null) gfFallTimer.active = true;

			if(dadbattleSpotlightEventTimer != null) dadbattleSpotlightEventTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		if (!inCutscene && startDrain)
			health -= 0.0007 * (elapsed / (1/60));

		if (SONG.song.toLowerCase() == 'blammed' && (FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2) == 92.09))
			FlxG.log.add('BSIDES MODE ACTIVATED');

		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		callOnLuas('onUpdate', [elapsed]);

		switch (boyfriend.curCharacter)
		{
			case 'bf-pixel':
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';
			case 'bf-holding-gf':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
			case 'bf-date':
				GameOverSubstate.characterName = 'bf-date-dead';
			case 'bf-run':
				GameOverSubstate.deathSoundName = 'sonicDie';
				GameOverSubstate.characterName = 'bf-sonic-dead';
			case 'bf-run-super':
				GameOverSubstate.deathSoundName = 'sonicDie';
				GameOverSubstate.characterName = 'bf-sonic-super-dead';
			case 'sonic-player':
				GameOverSubstate.deathSoundName = 'sonicDie';
				GameOverSubstate.characterName = 'sonic-player';
			case 'bf-remix':
				GameOverSubstate.characterName = 'bf-remix-dead';
		}

		switch (curStage)
		{
			case 'sonic-stage':
				if(boyfriend.curCharacter == 'bf-run' && boyfriend.animation.curAnim.name.contains('idle')) {
					boyfriend.animation.curAnim.curFrame = bfBody.animation.curAnim.curFrame % bfBody.animation.curAnim.numFrames;
				}
				if(boyfriend.curCharacter == 'bf-run-super' && boyfriend.animation.curAnim.name.contains('idle')) {
					boyfriend.animation.curAnim.curFrame = bfBody.animation.curAnim.curFrame % bfBody.animation.curAnim.numFrames;
				}
				if(dad.curCharacter == 'sonic-run' && dad.animation.curAnim.name.contains('idle')) {
					dad.animation.curAnim.curFrame = sonicBody.animation.curAnim.curFrame % sonicBody.animation.curAnim.numFrames;
				}

				if(boyfriend.curCharacter == 'bf-run' || boyfriend.curCharacter == 'bf-run-super') {
					bfBody.visible = true;
				}
				if(dad.curCharacter == 'sonic-run') {
					sonicBody.visible = true;
				}

			case 'limo':
				isStressed = '';
				if(boyfriend.hasStressedAnimations) {
					if(fuckCval) isStressed = '-stressed';
				}

				if(!cpuControlled)
				{
					if (controls.DODGE && boyfriend.dodgetime == 0 && dodgeEvent && !endingSong) {
						boyfriend.playAnim('dodge' + isStressed);
						boyfriend.dodgetime = FlxG.updateFramerate;
					}
				}

				if (curSong == 'High' || curSong == 'Milf') {
					dodgeEvent = true;
				}

				if (curSong == 'Milf') {
					if(!ClientPrefs.OldHDbg) {
						rails.animation.curAnim.frameRate = 30;
						road.animation.curAnim.frameRate = 41;
					}
				}

				hitbox.x = dodgelamp.x + 60;
				hitbox.y = dodgelamp.y + 320;

				if(!cpuControlled)
				{
					if (hitbox.overlapsPoint(boyfriend.getGraphicMidpoint()) && boyfriend.dodgetime < 12 && !endingSong)
					{
						if(boyfriend.curCharacter.startsWith('bf')) {
							GameOverSubstate.characterName = 'bf-pole-dead';
						}
						gofuckingdecked = true;
						boyfriend.stunned = true;
						deathCounter++;
						poleDeathCounter++;

						paused = true;

						vocals.stop();
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.sound('thud', 'week4'));

						persistentUpdate = false;
						persistentDraw = false;
						for (tween in modchartTweens) {
							tween.active = true;
						}
						for (timer in modchartTimers) {
							timer.active = true;
						}
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

						#if desktop
						DiscordClient.changePresence("Got Hit By The Pole - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
						#end
						isDead = true;
					}
				} else if (hitbox.overlapsPoint(boyfriend.getGraphicMidpoint()) && boyfriend.dodgetime == 0)
				{
					boyfriend.playAnim('dodge' + isStressed);
					boyfriend.dodgetime = FlxG.updateFramerate;
				}

				if(!ClientPrefs.lowQuality)
				{
					if (limoLight.x >= 170) {
						michael.visible = false;
						michaelDead.animation.play("michaelDEAD");
						michaelDead.animation.finishCallback = removeDancers;
					}
					if (limoLight.x >= 440) {
						alvin.visible = false;
						alvinDead.animation.play("alvinDEAD");
						alvinDead.animation.finishCallback = removeDancers;
					}
					if (limoLight.x >= 710) {
						bojangles.visible = false;
						bojanglesDead.animation.play("bojanglesDEAD");
						bojanglesDead.animation.finishCallback = removeDancers;
					}
					if (limoLight.x >= 1010) {
						bubbles.visible = false;
						bubblesDead.animation.play("bubblesDEAD");
						bubblesDead.animation.finishCallback = removeDancers;
					}
				}
		
				if (!endingSong) {
					if (dodgelamp.x <= -2400){
						ayoLookOut.visible = false;
					}
					if (dodgelamp.x >= -2400){
						ayoLookOut.visible = true;

						if(dodgelamp.x <= -2000 && !ClientPrefs.disableDodgeSound)
							FlxG.sound.play(Paths.sound('warning', 'week4'),0.65);
					}
					if (dodgelamp.x >= 80){
						ayoLookOut.visible = false;
					}
				}

			case 'spooky':
				if (curSong.toLowerCase() == 'monster')
					gf.visible = false;

			case 'tank':
				moveTank(elapsed);

			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}

			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}

				if(gf.curCharacter.startsWith('gf')) {
					boppers.visible = true;
				}

			case 'philly-picoPlayer':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}

				if(gf.curCharacter.startsWith('gf')) {
					boppers.visible = true;
				}

			case 'limo-og':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							OGlimoMetalPole.x += 5000 * elapsed;
							OGlimoLight.x = OGlimoMetalPole.x - 180;
							limoCorpse.x = OGlimoLight.x - 50;
							limoCorpseTwo.x = OGlimoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && OGlimoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(OGlimoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							OGbgLimo.x -= limoSpeed * elapsed;
							if(OGbgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							OGbgLimo.x -= limoSpeed * elapsed;
							if(OGbgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							OGbgLimo.x = FlxMath.lerp(OGbgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(OGbgLimo.x) == -150) {
								OGbgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + OGbgLimo.x + 280;
						}
					}
				}

			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(endingSong && poleTimer != null) poleTimer.active = false;

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(wiggleEffect != null)
			wiggleEffect.update(elapsed);

		if (bfBody != null){
			if(!boyfriend.animation.curAnim.name.contains("miss") && bfBody.animation.name == "bf miss"){
				bfBody.animation.play('bfRunningBottom');
				bfBody.offset.y = 0;
			}
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (ClientPrefs.HDIcons != 'New Version' && ClientPrefs.HDIcons != 'Old Version' && ClientPrefs.HDIcons != 'Older Version') {
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;

			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
		} else {
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else if (healthBar.percent > 80)
				iconP1.animation.curAnim.curFrame = 2;
			else
				iconP1.animation.curAnim.curFrame = 0;

			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else if (healthBar.percent < 20)
				iconP2.animation.curAnim.curFrame = 2;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}

		if (healthBar.percent < 40)
			fuckCval = true;
		else
			fuckCval = false;

		if(curSong.toLowerCase() == 'Milf' && ClientPrefs.disablesDialogues == 'Story Mode' || ClientPrefs.disablesDialogues == 'Everywhere')
		{
			if(deathCounter >= 2)
				badEnding = true;
			else
				badEnding = false;
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(daNote.mustPress && cpuControlled) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();
		
		//#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		//#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
							FlxG.sound.play(Paths.sound('Lights_Shut_off', 'week5'), 0.3);
						}

						var who:Character = dad;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						dadbattleSpotlightEventTimer = new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						if(val > 2) {
							who = boyfriend;
							dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 30);
						} else {
							who = dad;
							dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 170);
						}

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						dadbattleSmokesTween = FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				isStressed = '';
				if(Math.isNaN(time) || time <= 0) time = 0.6;
				if(boyfriend.hasStressedAnimations) {
					if(fuckCval) isStressed = '-stressed';
				}

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					if(!ClientPrefs.PicoPlayer) {
						boyfriend.playAnim('hey' + isStressed, true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					} else {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}
						
							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;
						
							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
							boppers.color = FlxColor.WHITE;
						}
					
					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];
					
						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}
						
							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}
					
						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;
					
						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;
					
						color.brightness *= 0.5;
						phillyStreet.color = color;
						boppers.color = charColor;
					
					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill OG Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				if(ClientPrefs.screenShake) {
					var valuesArray:Array<String> = [value1, value2];
					var targetsArray:Array<FlxCamera> = [camGame, camHUD];
					for (i in 0...targetsArray.length) {
						var split:Array<String> = valuesArray[i].split(',');
						var duration:Float = 0;
						var intensity:Float = 0;
						if(split[0] != null) duration = Std.parseFloat(split[0].trim());
						if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
						if(Math.isNaN(duration)) duration = 0;
						if(Math.isNaN(intensity)) intensity = 0;

						if(duration > 0 && intensity != 0) {
							targetsArray[i].shake(intensity, duration);
						}
					}
				}

			case 'Kill HD Henchmen':
				if(ClientPrefs.impEvent == 'In Every Song' && !killdancers)
					killDancers();

			case 'Start Pole':
				if(!ClientPrefs.poleSpawn && lightpolecanDoShit)
					startPole();

			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Start Draining Health':
				var drainId:Int = Std.parseInt(value1);
				if(Math.isNaN(drainId)) drainId = 0;

				switch(drainId)
				{
					case 0: //turn off
						startDrain = false;
					case 1: //turn on
						startDrain = true;
				}

			case 'Make GF Fall':
				if(gf.curCharacter == 'gf-christmas-dead')
				{
					var fallShit:Int = Std.parseInt(value1);
					precacheList.set('fellOver', 'sound');
					precacheList.set('fellOverReverse', 'sound');
					if(Math.isNaN(fallShit)) fallShit = 0;

					switch(fallShit)
					{
						case 0:
							if(gf != null && gf.stunned) {
								gf.stunned = false;
							}

						case 1:
							gfFallTimer = new FlxTimer().start(0.2, function(tmr:FlxTimer)
							{
								if(gf != null && gf.animOffsets.exists('fall')) {
									gf.stunned = true;
									gf.playAnim('fall', true);
									gfFallTimer = new FlxTimer().start(0.165, function(tmr:FlxTimer)
									{
										FlxG.sound.play(Paths.sound('fellOver'), 1);
										if(ClientPrefs.screenShake) {
											FlxG.camera.shake(0.02, 0.1);
										}
									});
								}
							});
					}
				}

			case 'HUD Fade':
				var shit:Int = Std.parseInt(value1);
				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(shit)) shit = 0;

				switch(shit)
				{
					case 0: //turn off
						boomCamTween = FlxTween.tween(camHUD, {alpha: 1}, time, {ease: FlxEase.quadIn});
					case 1: //turn on
						boomCamTween = FlxTween.tween(camHUD, {alpha: 0}, time, {ease: FlxEase.quadOut});
				}

			case 'Camera Flash':
				if(ClientPrefs.flashing) {
					var galax:Int = Std.parseInt(value1);
					var time:Float = Std.parseFloat(value2);
					if(Math.isNaN(galax)) galax = 0;
					switch(value1) {
						case 'black':
							galax = 0;
						case 'white':
							galax = 1;
						case 'yellow':
							galax = 3;
						case 'blue':
							galax = 4;
						case 'red':
							galax = 5;
						default:
							galax = Std.parseInt(value1);
							if(Math.isNaN(galax)) galax = 0;
					}

					switch(galax)
					{
						case 0:
							FlxG.camera.flash(FlxColor.BLACK, time, null, true);
						case 1:
							FlxG.camera.flash(FlxColor.WHITE, time, null, true);
						case 2:
							FlxG.camera.flash(FlxColor.YELLOW, time, null, true);
						case 4:
							FlxG.camera.flash(FlxColor.BLUE, time, null, true);
						case 5:
							FlxG.camera.flash(FlxColor.RED, time, null, true);
					}
				}

			case 'Trigger Sonic Transformation':
				if(curStage == 'sonic-stage' && dad.curCharacter == 'sonic-run') {
					var nuno:Int = 0;
					switch(value1) {
						case 'reset':
							nuno = 0;
						case 'start':
							nuno = 1;
						case 'transform':
							nuno = 2;
						case 'finish':
							nuno = 3;
						default:
							nuno = Std.parseInt(value1);
							if(Math.isNaN(nuno)) nuno = 0;
					}

					switch(nuno)
					{
						case 0:
							if(sonicBody == null) {
								addBehindDad(sonicBody);
							}
							dad.visible = true;
							superTransform.visible = false;
							sonicBody.visible = true;
						case 1:
							if(sonicBody != null) {
								remove(sonicBody);
							}
							dad.visible = false;
							superTransform.visible = true;
							superTransform.animation.play("transformStart");
						case 2:
							superTransform.animation.play("transform");
						case 3:
							superTransform.visible = false;
							dad.visible = true;
					}
				}

			case 'Spawn Aura':
				if(curStage == 'sonic-stage') {
					var charType:Int = 0;
					switch(value1) {
						case 'dad' | 'opponent':
							charType = 1;
						case 'bf' | 'boyfriend':
							charType = 2;
						default:
							charType = Std.parseInt(value1);
							if(Math.isNaN(charType)) charType = 1;
					}

					switch(charType)
					{
						case 0:
							if(aura != null) {
								remove(aura);
							}
						case 1:
							if(dad.curCharacter == 'super-sonic') {
								aura = new BGSprite('sonicshit/racing/aura', dad.x - 50, dad.y - 30, ['aura'], true);
								aura.blend = 'add';
								addInFrontDad(aura);
							}
						case 2:
							if(boyfriend.curCharacter == 'bf-run-super') {
								aura = new BGSprite('sonicshit/racing/aura', boyfriend.x - 140, boyfriend.y - 40, ['aura'], true);
								aura.blend = 'add';
								addInFrontBF(aura);
							}
					}
				}

			case 'Switch BF Run Body':
				if(curStage == 'sonic-stage') {
					var lol:Int = 0;
					switch(value1) {
						case 'normal':
							lol = 0;
						case 'super':
							lol = 1;
						default:
							lol = Std.parseInt(value1);
							if(Math.isNaN(lol)) lol = 0;
					}

					switch(lol)
					{
						case 0:
							remove(bfBody);

							bfBody = new BGSprite('sonicshit/bfRunningBottom', 882, 385, ['BF BOTTOM']);
							bfBody.animation.addByPrefix("bfRunningBottom", "BF BOTTOM", 24, true);
							bfBody.animation.addByPrefix("bfRunningBottomFast", "BF BOTTOM", 48, true);
							bfBody.animation.addByPrefix("bf miss", "BF MISS", 24, false);
							bfBody.animation.play("bfRunningBottom");
							bfBody.visible = false;
							addBehindBF(bfBody);
						case 1:
							remove(bfBody);

							bfBody = new BGSprite('sonicshit/bfRunningBottomSuper', 882, 385, ['BF BOTTOM']);
							bfBody.animation.addByPrefix("bfRunningBottom", "BF BOTTOM", 24, true);
							bfBody.animation.addByPrefix("bfRunningBottomFast", "BF BOTTOM", 48, true);
							bfBody.animation.addByPrefix("bf miss", "BF MISS", 24, false);
							bfBody.animation.play("bfRunningBottom");
							bfBody.visible = false;
							addBehindBF(bfBody);
					}
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		poleDeathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		if(curSong.toLowerCase() == 'tutorial' && songMisses < 1 && ratingPercent >= 1 && !usedPractice && isStoryMode /*&& FlxG.random.bool(20)*/) {
			gfTiddies();
		}

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning && !gftiddies) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext && ClientPrefs.disablesDialogues != 'Story Mode' && ClientPrefs.disablesDialogues != 'Everywhere')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext && ClientPrefs.disablesDialogues != 'Story Mode' && ClientPrefs.disablesDialogues != 'Everywhere') {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);
		var ratingNum:Int = 0;

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);

		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.6));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo && combo >= 10)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	function cacheBeams() {
		var momBeam = new FlxSprite(dad.x + 545, dad.y + 225);
		momBeam.frames = Paths.getSparrowAtlas('limo/mom_beam', 'week4');
		momBeam.scrollFactor.set(1, 1);
		momBeam.antialiasing = ClientPrefs.globalAntialiasing;
		momBeam.animation.addByIndices('beamThatMF', 'MOM BEAM 2', [0,1,2,3,4,5,6,7,8,9,10,11,12], '', 24, false); //Idk what is a beamThatMF but who cares
		momBeam.animation.play('beamThatMF', false, false, 0);
		momBeam.animation.finishCallback = function(anim:String){momBeam.destroy();}
		add(momBeam);

		var carolBeam = new FlxSprite(dad.x + 553, dad.y + 285);
		carolBeam.frames = Paths.getSparrowAtlas('carol_beam');
		carolBeam.scrollFactor.set(1, 1);
		carolBeam.antialiasing = ClientPrefs.globalAntialiasing;
		carolBeam.animation.addByIndices('beamThatMF', 'carol beam', [0,1,2,3,4,5,6,7,8,9,10,11,12], '', 29, false); //Idk what is a beamThatMF but who cares
		carolBeam.animation.play('beamThatMF', false, false, 0);
		carolBeam.animation.finishCallback = function(anim:String){carolBeam.destroy();}
		add(carolBeam);

		momBeam.visible = false;
		carolBeam.visible = false;
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else
				{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (parsedHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		if(boyfriend.curCharacter.startsWith('bf'))
		{
			if (combo >= 10 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
			if (combo >= 10 && dad.curCharacter.startsWith('gf') && dad.animOffsets.exists('sad')) // if gf is the opponent
			{
				dad.playAnim('sad');
				dad.specialAnim = true;
			}
		}
		combo = 0;
		health -= daNote.missHealth * healthLoss;

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;
		
		totalPlayed++;
		RecalculateRating();

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(daNote.noteType == 'Warning Note') {
			if(dad.animOffsets.exists('shoot')) {
				dad.playAnim('shoot' + blammedAnim, true);
				dad.specialAnim = true;
				/*if(dad.curCharacter.startsWith('pico')) {
					dad.shootTime = 0.46;
				}*/
			}
			FlxG.sound.play(Paths.sound('shooters', 'week3'), 1);
			if(ClientPrefs.screenShake) {
				FlxG.camera.shake(0.01, 0.2);
			}
		}

		if(daNote.noteType == 'Laser Note') {
			FlxG.sound.play(Paths.sound('bwow', 'week4'), 1);
			if(dad.animOffsets.exists('shootThatMF')) {
				dad.playAnim('shootThatMF', true);
				dad.specialAnim = true;
				if(dad.curCharacter == 'mom-car-horny') {
					dad.shootTime = 0.58;
				}
			}
			StartBeam();
			if(ClientPrefs.screenShake) {
				FlxG.camera.shake(0.01, 0.2);
			}
			if (!isDead && boyfriend.curCharacter.startsWith('bf')) {
				GameOverSubstate.characterName = 'bf-laser-dead';
			}
		}

		if(daNote.noteType == 'Alert Note') {
			FlxG.sound.play(Paths.sound('bwow', 'week4'), 1);
			if(dad.animOffsets.exists('laser')) {
				dad.playAnim('laser', true);
				dad.specialAnim = true;
				if(dad.curCharacter == 'hellchart-carol') {
					dad.shootTime = 0.50;
				}
			}
			StartCarolBeam();
			if(ClientPrefs.screenShake) {
				FlxG.camera.shake(0.01, 0.2);
			}
			if (!isDead && boyfriend.curCharacter.startsWith('bf')) {
				GameOverSubstate.characterName = 'bf-laser-dead';
			}
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var daAlt = '';
			isStressed = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';
			if(boyfriend.hasStressedAnimations) {
				if(fuckCval) isStressed = '-stressed';
			}

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))]+ 'miss' + isStressed + daNote.animSuffix;
			if(boyfriend.dodgetime == 0 && boyfriend.shootTime == 0) {
				char.playAnim(animToPlay, true);
			}
		}

		if (curStage == "sonic-stage") {
			bfBody.animation.play('bf miss', false);
			bfBody.offset.y = 100;
			FlxG.sound.play(Paths.sound('sonicSkid', 'shared'), 0.35);
			dropRings();
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(boyfriend.curCharacter.startsWith('bf'))
			{
				if (combo >= 10 && gf != null && gf.animOffsets.exists('sad'))
				{
					gf.playAnim('sad');
					gf.specialAnim = true;
				}
				if (combo >= 10 && dad.curCharacter.startsWith('gf') && dad.animOffsets.exists('sad')) // if gf is the opponent
				{
					dad.playAnim('sad');
					dad.specialAnim = true;
				}
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				isStressed = '';
				if(boyfriend.hasStressedAnimations) {
					if(fuckCval) isStressed = '-stressed';
				}

				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss' + isStressed, true);
			}
			vocals.volume = 0;

			if (curStage == "sonic-stage"){
				bfBody.animation.play('bf miss', false);
				bfBody.offset.y = 100;
				FlxG.sound.play(Paths.sound('sonicSkid', 'shared'), 0.35);
				dropRings();
			}
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		switch(note.noteType) {
			case 'Warning Note':
				if(boyfriend.curCharacter.startsWith('pico')) {
					if(boyfriend.animOffsets.exists('shoot')) {
						boyfriend.playAnim('shoot' + blammedAnimPicoPlayer, true);
						boyfriend.specialAnim = true;
					}
				} else {
					if(boyfriend.animOffsets.exists('dodge')) {
						boyfriend.playAnim('dodge', true);
						boyfriend.specialAnim = true;
						boyfriend.dodgetime = FlxG.updateFramerate/2;
					}
				}
				FlxG.sound.play(Paths.sound('shooters', 'week3'), 1);
				if(ClientPrefs.screenShake) {
					FlxG.camera.shake(0.01, 0.2);
				}

			case 'Laser Note':
				if(boyfriend.animOffsets.exists('dodge')) {
					boyfriend.playAnim('dodge', true);
					boyfriend.specialAnim = true;
					boyfriend.dodgetime = FlxG.updateFramerate/2;
				}
				FlxG.sound.play(Paths.sound('laser', 'week4'), 1);
				StartBeam();
				if(ClientPrefs.screenShake) {
					FlxG.camera.shake(0.01, 0.2);
				}

			case 'Alert Note':
				if(boyfriend.animOffsets.exists('dodge')) {
					boyfriend.playAnim('dodge', true);
					boyfriend.specialAnim = true;
					boyfriend.dodgetime = FlxG.updateFramerate/2;
				}
				FlxG.sound.play(Paths.sound('laser', 'week4'), 1);
				StartCarolBeam();
				if(ClientPrefs.screenShake) {
					FlxG.camera.shake(0.01, 0.2);
				}
		}

		if(note.noteType == 'Warning Note') {
			if(boyfriend.curCharacter.startsWith('pico')) {
				if(dad.animOffsets.exists('dodge')) {
					dad.playAnim('dodge', true);
					dad.specialAnim = true;
					dad.dodgetime = FlxG.updateFramerate/2;
				}
			} else {
				if(dad.animOffsets.exists('shoot')) {
					dad.playAnim('shoot' + blammedAnim, true);
					dad.specialAnim = true;
					/*if(dad.curCharacter.startsWith('pico')) {
						dad.shootTime = 0.46;
					}*/
				}
			}
		}

		if(note.noteType == 'Laser Note') {
			if(dad.animOffsets.exists('shootThatMF')) {
				dad.playAnim('shootThatMF', true);
				dad.specialAnim = true;
				if(dad.curCharacter == 'mom-car-horny') {
					dad.shootTime = 0.58;
				}
			}
		}

		if(note.noteType == 'Alert Note') {
			if(dad.animOffsets.exists('laser')) {
				dad.playAnim('laser', true);
				dad.specialAnim = true;
				if(dad.curCharacter == 'hellchart-carol') {
					dad.shootTime = 0.50;
				}
			}
		}

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + blammedAnim + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				if(char.dodgetime == 0 && char.shootTime == 0) {
					char.playAnim(animToPlay, true);
					char.holdTimer = 0;
				}
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			switch(note.noteType) {
				case 'Warning Note':
					FlxG.sound.play(Paths.sound('shooters', 'week3'), 1);
					if(dad.animOffsets.exists('shoot')) {
						dad.playAnim('shoot' + blammedAnim, true);
						dad.specialAnim = true;
						/*if(dad.curCharacter.startsWith('pico')) {
							dad.shootTime = 0.46;
						}*/
					}
					if(ClientPrefs.screenShake) {
						FlxG.camera.shake(0.01, 0.2);
					}

				case 'Laser Note':
					FlxG.sound.play(Paths.sound('laser', 'week4'), 1);
					if(dad.animOffsets.exists('shootThatMF')) {
						dad.playAnim('shootThatMF', true);
						dad.specialAnim = true;
						if(dad.curCharacter == 'mom-car-horny') {
							dad.shootTime = 0.58;
						}
					}
					StartBeam();
					if(ClientPrefs.screenShake) {
						FlxG.camera.shake(0.01, 0.2);
					}

				case 'Alert Note':
					FlxG.sound.play(Paths.sound('laser', 'week4'), 1);
					if(dad.animOffsets.exists('laser')) {
						dad.playAnim('laser', true);
						dad.specialAnim = true;
						if(dad.curCharacter == 'hellchart-carol') {
							dad.shootTime = 0.50;
						}
					}
					StartCarolBeam();
					if(ClientPrefs.screenShake) {
						FlxG.camera.shake(0.01, 0.2);
					}
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				isStressed = '';
				if(boyfriend.hasStressedAnimations) {
					if(fuckCval) isStressed = '-stressed';
				}
	
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null && gf.dodgetime == 0 && gf.shootTime == 0)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					if(boyfriend.dodgetime == 0 && boyfriend.shootTime == 0) {
						boyfriend.playAnim(animToPlay + blammedAnimPicoPlayer + isStressed + note.animSuffix, true);
						boyfriend.holdTimer = 0;
					}
				}

				if(note.noteType == 'Warning Note') {
					if(boyfriend.animOffsets.exists('dodge')) {
						boyfriend.playAnim('dodge' + isStressed, true);
						boyfriend.specialAnim = true;
						boyfriend.dodgetime = FlxG.updateFramerate/2;
					}
				}

				if(note.noteType == 'Laser Note') {
					if(boyfriend.animOffsets.exists('dodge')) {
						boyfriend.playAnim('dodge' + isStressed, true);
						boyfriend.specialAnim = true;
						boyfriend.dodgetime = FlxG.updateFramerate/2;
					}
				}

				if(note.noteType == 'Alert Note') {
					if(boyfriend.animOffsets.exists('dodge')) {
						boyfriend.playAnim('dodge' + isStressed, true);
						boyfriend.specialAnim = true;
						boyfriend.dodgetime = FlxG.updateFramerate/2;
					}
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey' + isStressed, true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;
	var billboardShit:Bool = true;
	var lightpolecanDoShit:Bool = true;
	var killdancers:Bool = false;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo-og') {
			if(limoKillingState < 1) {
				OGlimoMetalPole.x = -400;
				OGlimoMetalPole.visible = true;
				OGlimoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo-og') {
			OGlimoMetalPole.x = -500;
			OGlimoMetalPole.visible = false;
			OGlimoLight.x = -500;
			OGlimoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}
	
	var billboardTimer:FlxTimer;
	function startBillBoard() {
		if(!ClientPrefs.lowQuality && curStage == 'limo') {
			var dumbass:Int = FlxG.random.int(0,7);
			billboard.animation.play('' + dumbass);
			billboard.velocity.x = 10 * SONG.bpm;
			//trace('BILLBOARD' + billboard.animation.curAnim.name);
			billboardShit = false;
			billboardTimer = new FlxTimer().start(6, function(tmr:FlxTimer){
				resetBillBoard();
				billboardTimer = null;
			});
		}
	}

	function startPole() {
		if(curStage == 'limo') {
			dodgepole.velocity.x = 20 * SONG.bpm;
			dodgelamp.velocity.x = 20 * SONG.bpm;
			hitbox.velocity.x = 20*SONG.bpm;
			dodgeEvent = true;
			timerStop = true;
			lightpolecanDoShit = false;
			poleTimer = new FlxTimer().start(3, function(tmr:FlxTimer){
				resetPole();
			});
		}
	}

	function resetBillBoard()
	{
		if(!ClientPrefs.lowQuality && curStage == 'limo') {
			billboard.x = -2000;
			billboard.velocity.x = 0;
			billboardShit = true;
		}
	}

	function resetPole()
	{
		if(curStage == 'limo') {
			dodgepole.x = -2440;
			dodgelamp.x = -2585;
			dodgepole.velocity.x = 0;
			dodgelamp.velocity.x = 0;
			hitbox.velocity.x = 0;
			lightpolecanDoShit = true;
			//trace("Resetting dodgelamp");
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
			boppers.playAnim('blowing');
			boppers.stopDancing = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		boppers.playAnim('Landing');
		phillyTrain.x = FlxG.width + 400;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		boppers.stopDancingTime = 0.24;
		boppers.stopDancing = false;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	public function gfTiddies() {
		//tiddy code
		gftiddies = true;
		camHUD.visible = false;
		defaultCamZoom = 1;

		FlxG.sound.play(Paths.sound('ignorethis'));

		tiddies = new BGSprite(null, 0, 0, 0, 0);
		tiddies.loadGraphic(Paths.image('gf_tiddies'));
		add(tiddies);

		new FlxTimer().start(1.8, function(tmr:FlxTimer)
		{
			trace("AYO FC'D TUTORIAL? DAMN");
			System.exit(0);
		});
	}

	function placeOmochao(x:Int,y:Int) {
		var frames = AtlasFrameMaker.construct('OMOCHAO_BG');
		var omochao = new FlxSprite (x,y);
		omochao.antialiasing = ClientPrefs.globalAntialiasing;
		omochao.frames = frames;
		omochao.scrollFactor.set(1,1);
		omochao.animation.addByPrefix('bop', 'Dance',24);
		omochao.animation.play('bop');
		add(omochao);
	}

	var bgLimoTimer:FlxTimer;
	var bgLimoTimer2:FlxTimer;
	var killDancersTimer:FlxTimer;
	var bgLimoTween:FlxTween;
	var dancersTween:FlxTween;
	var dancersTween2:FlxTween;
	var dancersTween3:FlxTween;
	var dancersTween4:FlxTween;
	function killDancers() {
		if(curStage == 'limo' && !ClientPrefs.lowQuality) {
			killdancers = true;
			limoLight.velocity.x = 4800;
			limoMetalPole.velocity.x = 4800;
			killDancersTimer = new FlxTimer().start(0.218, function(e:FlxTimer) {
				if(ClientPrefs.screenShake) {
					FlxG.camera.shake(0.01, 0.2);
				}
				FlxG.sound.play(Paths.sound('dancerdeath'), 0.9);
				if(gf != null && gf.animOffsets.exists('duck')) {
					gf.playAnim('duck');
					gf.dodgetime = FlxG.updateFramerate;
				}

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end

				bgLimoTimer = new FlxTimer().start(1.1, function(e:FlxTimer) {
					bgLimoTween = FlxTween.tween(bgLimo, {x: 1800}, 2, {ease:FlxEase.sineIn});
					michael.x += 2012;
					alvin.x += 2012;
					bojangles.x += 2012;
					bubbles.x += 2012;

					if(ClientPrefs.impEvent == 'In Every Song') {
						resetHDlimoKill();
						bgLimoTimer2 = new FlxTimer().start(2.7, function(e:FlxTimer) {
							bgLimoTween = FlxTween.tween(bgLimo, {x: -200}, 2, {ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){killdancers = false;}});
							dancersTween = FlxTween.tween(michael, {x: 175}, 2, {ease:FlxEase.sineOut});
							dancersTween2 = FlxTween.tween(alvin, {x: 445}, 2, {ease:FlxEase.sineOut});
							dancersTween3 = FlxTween.tween(bojangles, {x: 715}, 2, {ease:FlxEase.sineOut});
							dancersTween4 = FlxTween.tween(bubbles, {x: 985}, 2, {ease:FlxEase.sineOut});
						});
					}
				});
			});
		}
	}

	function resetHDlimoKill() {
		limoLight.x = -830;
		limoMetalPole.x = -820;

		limoLight.velocity.x = 0;
		limoMetalPole.velocity.x = 0;

		michaelDead.animation.play("eh", true);
		alvinDead.animation.play("eh", true);
		bojanglesDead.animation.play("eh", true);
		bubblesDead.animation.play("eh", true);

		michael.visible = true;
		alvin.visible = true;
		bojangles.visible = true;
		bubbles.visible = true;
		michaelDead.visible = true;
		alvinDead.visible = true;
		bojanglesDead.visible = true;
		bubblesDead.visible = true;
	}

	function removeDancers(anim:String)
	{
		switch (anim)
		{
			case 'michaelDEAD':
				michaelDead.visible = false;
			case 'alvinDEAD':
				alvinDead.visible = false;
			case 'bojanglesDEAD':
				bojanglesDead.visible = false;
			case 'bubblesDEAD':
				bubblesDead.visible = false;
		}
	}

	public function StartBeam() {
		if(dad.curCharacter == 'mom-car-horny' || dad.curCharacter == 'mom-car') {
			var momBeam = new FlxSprite(dad.x + 545, dad.y + 225);
			momBeam.frames = Paths.getSparrowAtlas('limo/mom_beam', 'week4');
			momBeam.scrollFactor.set(1, 1);
			momBeam.antialiasing = ClientPrefs.globalAntialiasing;
			momBeam.animation.addByIndices('beamThatMF', 'MOM BEAM 2', [0,1,2,3,4,5,6,7,8,9,10,11,12], '', 24, false); //Idk what is a beamThatMF but who cares
			momBeam.animation.play('beamThatMF', false, false, 0);
			momBeam.animation.finishCallback = function(anim:String){momBeam.destroy();}
			add(momBeam);
		}
	}

	public function StartCarolBeam() {
		if(dad.curCharacter == 'hellchart-carol') {
			var carolBeam = new FlxSprite(dad.x + 553, dad.y + 285);
			carolBeam.frames = Paths.getSparrowAtlas('carol_beam');
			carolBeam.scrollFactor.set(1, 1);
			carolBeam.antialiasing = ClientPrefs.globalAntialiasing;
			carolBeam.animation.addByIndices('beamThatMF', 'carol beam', [0,1,2,3,4,5,6,7,8,9,10,11,12], '', 29, false); //Idk what is a beamThatMF but who cares
			carolBeam.animation.play('beamThatMF', false, false, 0);
			carolBeam.animation.finishCallback = function(anim:String){carolBeam.destroy();}
			add(carolBeam);
		}
	}

	function dropRings(){

		FlxG.sound.play(Paths.sound('ringDrop', 'shared'), 0.2);

		var rings = new FlxSprite(boyfriend.x - 200, boyfriend.y);
		rings.frames = Paths.getSparrowAtlas("sonicshit/racing/ringSplash", "shared");
		rings.antialiasing = ClientPrefs.globalAntialiasing;
		rings.animation.addByPrefix("rings", "BF NOTE RIGHT MISS RING", 24, false);
		rings.animation.play("rings", false, false, 0);
		rings.animation.finishCallback = function(anim:String){rings.destroy();}
		add(rings);

	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		if(curSong == "Green Hill") {
			if (curStep == 590) {
				dad.playAnim('WOO!', true);
				dad.specialAnim = true;
			}
		}

		if(curSong == "Carol Roll") {
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			if (curStep == 124) {
				countdownReady = new FlxSprite().loadGraphic(Paths.image('ready'));
				countdownReady.scrollFactor.set();
				countdownReady.updateHitbox();

				countdownReady.screenCenter();
				countdownReady.antialiasing = antialias;
				add(countdownReady);
				FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownReady);
						countdownReady.destroy();
					}
				});
			}
			if (curStep == 126) {
				countdownSet = new FlxSprite().loadGraphic(Paths.image('set'));
				countdownSet.scrollFactor.set();

				countdownSet.screenCenter();
				countdownSet.antialiasing = antialias;
				add(countdownSet);
				FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownSet);
						countdownSet.destroy();
					}
				});
			}
			if (curStep == 128) {
				countdownGo = new FlxSprite().loadGraphic(Paths.image('go'));
				countdownGo.scrollFactor.set();

				countdownGo.updateHitbox();

				countdownGo.screenCenter();
				countdownGo.antialiasing = antialias;
				add(countdownGo);
				FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownGo);
						countdownGo.destroy();
					}
				});
			}
		}

		if(curSong == "Body") {
			if (curStep == 189) {
				dad.playAnim('hey', true);
				dad.specialAnim = true;
			}
			if (curStep == 701) {
				dad.playAnim('hey', true);
				dad.specialAnim = true;
			}
			if (curStep == 897) {
				dad.playAnim('hey', true);
				dad.specialAnim = true;
			}
		}

		if(curSong == "Milf") {
			if(ClientPrefs.impEvent != 'In Every Song') {
				if (curStep == 317 && !endingSong && !killdancers) {
					killDancers();
				}
			}
		}

		if(curSong == "Happy Time") {
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			if (curStep == 48){
				FlxG.sound.play(Paths.sound('intro3'), 0.6);
			}
			if (curStep == 52){
				countdownReady = new FlxSprite().loadGraphic(Paths.image('ready'));
				countdownReady.scrollFactor.set();
				countdownReady.updateHitbox();

				countdownReady.screenCenter();
				countdownReady.antialiasing = antialias;
				add(countdownReady);
				FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownReady);
						countdownReady.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro2'), 0.6);
			}
			if (curStep == 56){
				countdownSet = new FlxSprite().loadGraphic(Paths.image('set'));
				countdownSet.scrollFactor.set();

				countdownSet.screenCenter();
				countdownSet.antialiasing = antialias;
				add(countdownSet);
				FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownSet);
						countdownSet.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro1'), 0.6);
			}
			if (curStep == 60){
				countdownGo = new FlxSprite().loadGraphic(Paths.image('go'));
				countdownGo.scrollFactor.set();

				countdownGo.updateHitbox();

				countdownGo.screenCenter();
				countdownGo.antialiasing = antialias;
				add(countdownGo);
				FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownGo);
						countdownGo.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('introGo'), 0.6);
			}
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(!ClientPrefs.OldHDbg) {
			if(dad.curCharacter.startsWith('pico')) {
				if (curSong == 'Blammed' && curBeat == 128)
					blammedAnim = '-cracked';
			}
			else if(boyfriend.curCharacter.startsWith('pico')) {
				if (curSong == 'Blammed' && curBeat == 128)
					blammedAnimPicoPlayer = '-cracked';
			}
		}

		if (curStage == 'limo' && curBeat % 2 == 1)
			limo.dance(true);
			pubCurBeat = curBeat;

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned && gf.dodgetime == 0 && gf.shootTime == 0)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned && boyfriend.dodgetime == 0 && boyfriend.shootTime == 0)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned && dad.dodgetime == 0 && dad.shootTime == 0)
		{
			dad.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.dodgetime == 0 && boyfriend.shootTime == 0)
		{
			if (curStage == "sonic-stage" && bfBody.animation.name == "bf miss"){
				bfBody.animation.play('bfRunningBottom');
				bfBody.offset.y = 0;
			}
		}

		if (curSong.toLowerCase() == 'blammed')
		{
			if (curBeat == 154)
				defaultCamZoom += 0.24;

			if (curBeat == 160)
				defaultCamZoom -= 0.24;

			if (curBeat == 282)
				defaultCamZoom += 0.24;

			if (curBeat == 288)
				defaultCamZoom -= 0.24;
		}

		if (curSong.toLowerCase() == 'boom')
		{
			if (curBeat == 234)
				boomCamTween = FlxTween.tween(camHUD, {alpha: 0}, 0.3, {ease: FlxEase.quadOut});

			if (curBeat == 248)
				boomCamTween = FlxTween.tween(camHUD, {alpha: 1}, 0.3, {ease: FlxEase.quadIn});
		}

		if (curBeat >= 100 && curSong.toLowerCase() == 'racing' && !supershit)
		{
			supershit = true;

			grass.animation.curAnim.frameRate = 50;
			clouds.animation.curAnim.frameRate = 32;
			trees.animation.curAnim.frameRate = 32;
			bfBody.animation.curAnim.frameRate = 32;

			bgDarken.visible = true;

			notes.forEachExists(function(x:Note){ x.recalcSusLength(); });
		}

		switch (curStage)
		{
			case 'studio':
				if(!ClientPrefs.lowQuality) {
					mom.dance(true);
					imp.dance(true);
				}

				bgStudio.dance(true);

			case 'stage':
				if(curSong.toLowerCase() == 'fresh' || curSong.toLowerCase() == 'dad battle' && !ClientPrefs.lowQuality) {
					freshCrowd.dance(true);
				}

			case 'green-hills':
				if(!ClientPrefs.lowQuality) {
					amy.dance();
					leftBoppers.dance();
					rightBoppers.dance();
				}

			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);

					if (curBeat % 4 == 0)
						bgEscalator.animation.play('' + FlxG.random.int(0,2), true);
				}
				
				if(heyTimer <= 0) bottomBoppers.dance(true);

				santa.dance(true);

			case 'limo-og':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					michael.dance();
					alvin.dance();
					bojangles.dance();
					bubbles.dance();

					if (FlxG.random.bool(10) && billboardShit)
						startBillBoard();
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
				
				if(ClientPrefs.poleSpawn)
				{
					if (curSong == 'High' || curSong == 'Milf') {
						if (FlxG.random.bool(10) && lightpolecanDoShit)
							startPole();
					}
				}

			case "philly":
				if(!boppers.stopDancing && boppers.stopDancingTime == 0) {
					boppers.dance(true);
				}

				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(phillyWindow:BGSprite)
					{
						phillyWindow.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);

					phillyCityLights.members[curLight].color = phillyLightsColors[curLight];
					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case "philly-picoPlayer":
				if(!boppers.stopDancing && boppers.stopDancingTime == 0) {
					boppers.dance(true);
				}

				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(phillyWindow:BGSprite)
					{
						phillyWindow.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);

					phillyCityLights.members[curLight].color = phillyLightsColors[curLight];
					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		if (badHit)
			updateScore(true); // miss notes shouldn't make the scoretxt bounce -Ghost
		else
			updateScore(false);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ !ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
