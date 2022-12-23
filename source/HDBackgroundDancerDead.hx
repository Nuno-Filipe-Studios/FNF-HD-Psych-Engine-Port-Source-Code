package;

import flixel.math.FlxRandom;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

class HDBackgroundDancerDead extends FlxSprite
{
	public function new(x:Float, y:Float, who:String)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas("gore/noooooo");
		animation.addByPrefix(who + 'DEAD', who + 'DEAD0', 24, false);
		animation.addByPrefix(who + 'DEAD 2', who + 'DEAD 2', 24, false);
		animation.addByIndices('eh', 'michaelDEAD', [21, 21], '', 24, true);
		animation.play('eh');
		antialiasing = ClientPrefs.globalAntialiasing;
	}
}