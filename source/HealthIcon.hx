package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;

			if(ClientPrefs.HDIcons == 'New Version') name = 'icons HD/' + char;
			else if(ClientPrefs.HDIcons == 'Old Version') name = 'icons HD old/' + char;
			else if(ClientPrefs.HDIcons == 'Older Version') name = 'icons HD older/' + char;
			else name = 'icons/' + char;

			// Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE) && ClientPrefs.HDIcons == 'New Version') name = 'icons HD/icon-' + char;
			else if(!Paths.fileExists('images/' + name + '.png', IMAGE) && ClientPrefs.HDIcons == 'Old Version') name = 'icons HD old/icon-' + char;
			else if(!Paths.fileExists('images/' + name + '.png', IMAGE) && ClientPrefs.HDIcons == 'Older Version') name = 'icons HD older/icon-' + char;
			else if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char;
			// Prevents crash from missing icon
			if(!Paths.fileExists('images/' + name + '.png', IMAGE) && ClientPrefs.HDIcons == 'New Version') name = 'icons HD/icon-face';
			else if(!Paths.fileExists('images/' + name + '.png', IMAGE) && ClientPrefs.HDIcons == 'Old Version') name = 'icons HD old/icon-face';
			else if(!Paths.fileExists('images/' + name + '.png', IMAGE) && ClientPrefs.HDIcons == 'Older Version') name = 'icons HD older/icon-face';
			else if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face';

			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			if(ClientPrefs.HDIcons != 'New Version' && ClientPrefs.HDIcons != 'Old Version' && ClientPrefs.HDIcons != 'Older Version') {
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
			} else {
				loadGraphic(file, true, Math.floor(width / 3), Math.floor(height)); //Then load it fr
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				iconOffsets[2] = (width - 150) / 2;
			}

			updateHitbox();

			if(ClientPrefs.HDIcons != 'New Version' && ClientPrefs.HDIcons != 'Old Version' && ClientPrefs.HDIcons != 'Older Version')
				animation.add(char, [0, 1], 0, false, isPlayer);
			else
				animation.add(char, [0, 1, 2], 0, false, isPlayer);

			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}