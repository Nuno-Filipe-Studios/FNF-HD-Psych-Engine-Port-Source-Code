package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			["FNF' HD PE Port Team"],
			['Nuno Filipe Studios',	'nuno',				'Main porter, coder, animator, Android Port help',			'https://www.youtube.com/channel/UCq7G3p4msVN5SX2CpJ86tTw',	'878787'],
			['Remy And Ava',		'ava',				'Mobile optimizer, gamejolt link',							'https://www.youtube.com/channel/UCxBKG1LFQM2Kte_BQ0isDww',	'F7F7F7'],
			['DANIZIN',				'dan',				'Old Android Port',											'https://www.youtube.com/channel/UCvTYcAn6ciOojpfcHtUxJBQ',	'FFD166'],
			['FNF BR',				'br',				'Android Port',												'https://www.youtube.com/channel/UCtEMWRthfza-LaNz7H2Z3oQ',	'FCBF49'],
			['MaysLastPlay',		'mays',				'Android Port',												'https://www.youtube.com/channel/UCx0LxtFR8ROd9sFAq-UxDfw',	'5DE7FF'],
			['DMMaster 636',		'dm',				'Artist, coder, animator',									'https://www.youtube.com/channel/UC65EwKYTjayqmXATNz2auzQ', '7E39EE'],
			['mariodevintoons',		'devin',			'New HD Mall Darnell Artist',								'https://twitter.com/mariodevintoon2',	'C1121F'],
			['Galax',				'galax',			'Dev Build Tester',											'https://twitter.com/Galax40841813',	'3F37C9'],
			['JorgeX_YT',			'jorge',			'Dev Build Tester',											'https://www.youtube.com/channel/UCl-GHl189q4erRjnnVmqNUA',	'70E000'],
			[''],
			['Used some codes from'],
			["Wednesday's Infidelity Team",			'mouse',			'Dodge keybinds text code',					'https://gamebanana.com/mods/343688',	'444444'],
			['Arrow Funk Team',		'bidu',				'Used text font',											'https://gamebanana.com/mods/370234',	'F72585'],
			['Trevent booh!',		null,				'Used icon flip lua code',									'https://www.youtube.com/channel/UCMzim382hWHmR1un4nzEOLw',	'00FFBB'],
			[''],
			['Special Thanks'],
			['JorgeX_YT',			'jorge',			'For replacing our current beta tester of the port and testing the port',	'https://www.youtube.com/channel/UCl-GHl189q4erRjnnVmqNUA',	'70E000'],
			['mariodevintoons',		'devin',			'For making the new HD mall darnell',						'https://twitter.com/mariodevintoon2',	'C1121F'],
			['Remy And Ava',		'ava',				'For supporting me',										'https://www.youtube.com/channel/UCxBKG1LFQM2Kte_BQ0isDww',	'F7F7F7'],
			['Galax',				'galax',			'For almost testing the port and being my best friend',		'https://twitter.com/Galax40841813',	'3F37C9'],
			['FNF BR',				'br',				'For making the Android Port',								'https://www.youtube.com/channel/UCtEMWRthfza-LaNz7H2Z3oQ',	'FCBF49'],
			['DANIZIN',				'dan',				'For making the Android Port',								'https://www.youtube.com/channel/UCvTYcAn6ciOojpfcHtUxJBQ',	'FFD166'],
			['MaysLastPlay',		'mays',				'For helping out with the Android Port',					'https://www.youtube.com/channel/UCx0LxtFR8ROd9sFAq-UxDfw',	'5DE7FF'],
			['DMMaster 636',		'dm',				'For making good HD art and cool stuff for the port',		'https://www.youtube.com/channel/UC65EwKYTjayqmXATNz2auzQ', '7E39EE'],
			[''],
			['FNF HD Team'],
			['Kolsan',				null,				'Artist, dialogue, Main writer, Billboard artist',			'https://gamebanana.com/members/1859052','444444'],
			['Rozebud',				null,				'Coder, Racing',											'https://twitter.com/helpme_thebigt',	'444444'],
			['Smokey',				'smokey',			'Coder',													'https://twitter.com/Smokey_5_',		'4D5DBD'],
			['bb-panzu',			'bb',				'Coder',													'https://twitter.com/bbsub3',			'389A58'],
			['GenoX',				null,				'Coder',													'https://twitter.com/GenoXACT2',		'444444'],
			['KadeDev',				'kade',				'Coder',													'https://twitter.com/kade0912',			'64A250'],
			['Flippy',				null,				'Charter',													'https://www.youtube.com/channel/UCMIGpjyL6H__IFp7emWErlw',	'444444'],
			['Chromatical',			null,				'Charter',													'https://twitter.com/Chromaatical',		'444444'],
			['Cval',				null,				'Charter',													'https://twitter.com/cval_brown',		'444444'],
			['Saicronise',			null,				'South rechart',											'https://twitter.com/Saicronise2',		'444444'],
			['JellyFish',			null,				'All remixes minus Monster',								'https://twitter.com/JellyComics',		'444444'],
			['RetroSpecter',		null,				'Helped with MILF remix',									'https://twitter.com/RetroSpecter_',	'444444'],
			['Saster',				null,				'Helped with Dadbattle remix',								'https://twitter.com/sub0ru',			'444444'],
			['JADS',				null,				'Week 3 bg music, Green Hill',								'https://twitter.com/Aw3somejds',		'444444'],
			['Leukuh',				null,				'Gallery, Boom',											'https://twitter.com/Leukuh',			'444444'],
			['MarblePawns',			null,				'Breaking Point, Happy Time, Breaking Point Composer',		'https://twitter.com/marblepawns',		'444444'],
			['Kazuya',				null,				'Helped with Winter Horrorland',							'https://www.youtube.com/c/KazuyaJcore','444444'],
			['shinseinaken',		null,				'Additional dialogue help',									'https://twitter.com/shinseinakenxrd',	'444444'],
			['lattebuns',			null,				'(Current) Icon redesigner and help with billboards, Week 5 display screen artist',	'https://twitter.com/LatteBunss','444444'],
			['DOJIMADOG',			null,				'(Old) Icon redesigner',									'https://twitter.com/DojimaDog',		'444444'],
			['Akairosu_',			null,				'Billboard artist',											'https://twitter.com/akairosu_',		'444444'],
			['peep_face',			null,				'Billboard artist',											'https://twitter.com/peep_face',		'444444'],
			['aka_goshhhh',			null,				'Week 5 display screen artist',								'https://twitter.com/aka_goshhhh',		'444444'],
			['POSTBOY',				null,				'Week 5 display screen artist',								'https://twitter.com/P0STBOY',			'444444'],
			['sushiisiu',			null,				'Loading screen artist',									'https://twitter.com/sushiisiu',		'444444'],
			['TentaRJ',				null,				'Mac Build',												'https://twitter.com/TentaRJ',			'444444'],
			['cinnacider',			null,				'Mimmicking Balloon Boy in Spookeez',						'https://twitter.com/cinnacider',		'444444'],
			['beansreal1',			null,				'being beans',												'https://twitter.com/BeansReal1',		'444444'],
			[''],
			['Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',								'https://twitter.com/Shadow_Mario_',	'444444'],
			['RiverOaken',			'river',			'Main Artist/Animator of Psych Engine',							'https://twitter.com/RiverOaken',		'B42F71'],
			['shubs',				'shubs',			'Additional Programmer of Psych Engine',						'https://twitter.com/yoshubs',			'5E99DF'],
			[''],
			['Former Engine Members'],
			['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',								'https://twitter.com/bbsub3',			'3E813A'],
			[''],
			['Engine Contributors'],
			['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',		'https://twitter.com/flicky_i',			'9E29CF'],
			['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform',	'https://twitter.com/gedehari',			'E1843A'],
			['EliteMasterEric',		'mastereric',		'Runtime Shaders support',										'https://twitter.com/EliteMasterEric',	'FFBD40'],
			['PolybiusProxy',		'proxy',			'.MP4 Video Loader Library (hxCodec)',							'https://twitter.com/polybiusproxy',	'DCD294'],
			['KadeDev',				'kade',				'Fixed some cool stuff on Chart Editor\nand other PRs',			'https://twitter.com/kade0912',			'64A250'],
			['Keoiki',				'keoiki',			'Note Splash Animations',										'https://twitter.com/Keoiki_',			'D2D2D2'],
			['Nebula the Zorua',	'nebula',			'LUA JIT Fork and some Lua reworks',							'https://twitter.com/Nebula_Zorua',		'7D40B2'],
			['Smokey',				'smokey',			'Sprite Atlas Support',											'https://twitter.com/Smokey_5_',		'483D92'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",						'https://twitter.com/ninja_muffin99',	'F73838'],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",							'https://twitter.com/PhantomArcade3K',	'FFBB1B'],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",							'https://twitter.com/evilsk8r',			'53E52C'],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",							'https://twitter.com/kawaisprite',		'6475F3']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if(FlxG.mouse.wheel != 0)
				{
					changeSelection(1 * shiftMult * -FlxG.mouse.wheel);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}