package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

// yes, i mostly copied stuff from WeekData -DM
typedef GalleryFile =
{
	// JSON variables
	var images:Array<Dynamic>;
	var weekImage:String;
	var weekBefore:String;
	var bgColor:Array<Int>;
}

class GalleryData
{
	public static var imagesLoaded:Map<String, GalleryData> = new Map<String, GalleryData>();
	public static var imagesList:Array<String> = [];
	public var folder:String = '';

	public var images:Array<Dynamic>; 
	public var weekImage:String;
	public var weekBefore:String;
	public var bgColor:Array<Int>;

	public var fileName:String;

	public static function createGalleryFile():GalleryFile {
		var galleryFile:GalleryFile = {
			images: [["bf", [79, 88, 151]], ["gf", [184, 90, 186]], ["dad", [228, 188, 74]]],
			weekImage: 'week1',
			weekBefore: 'tutorial',
			bgColor: [69, 108, 207]
		};
		return galleryFile;
	}

	public function new(galleryFile:GalleryFile, fileName:String) {
		images = galleryFile.images;
		weekImage = galleryFile.weekImage;
		weekBefore = galleryFile.weekBefore;
		bgColor = galleryFile.bgColor;

		this.fileName = fileName;
	}

	public static function reloadGalleryFiles()
	{
		imagesList = [];
		imagesLoaded.clear();
		#if MODS_ALLOWED
		var disabledMods:Array<String> = [];
		var modsListPath:String = 'modsList.txt';
		var directories:Array<String> = [Paths.mods(), Paths.getPreloadPath()];
		var originalLength:Int = directories.length;
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					disabledMods.push(splitName[0]);
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.contains(splitName[0]) && !disabledMods.contains(splitName[0]) && !directories.contains(path + '/'))
					{
						directories.push(path + '/');
						//trace('pushed Directory: ' + splitName[0]);
					}
				}
			}
		}

		var modsDirectories:Array<String> = Paths.getModDirectories();
		for (folder in modsDirectories)
		{
			var pathThing:String = haxe.io.Path.join([Paths.mods(), folder]) + '/';
			if (!disabledMods.contains(folder) && !directories.contains(pathThing))
			{
				directories.push(pathThing);
				//trace('pushed Directory: ' + folder);
			}
		}
		#else
		var directories:Array<String> = [Paths.getPreloadPath()];
		var originalLength:Int = directories.length;
		#end

		var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('gallery/galleryList.txt'));
		for (i in 0...sexList.length) {
			for (j in 0...directories.length) {
				var fileToCheck:String = directories[j] + 'gallery/' + sexList[i] + '.json';
				if(!imagesLoaded.exists(sexList[i])) {
					var stuff:GalleryFile = getGalleryFile(fileToCheck);
					if(stuff != null) {
						var galleryFile:GalleryData = new GalleryData(stuff, sexList[i]);

						#if MODS_ALLOWED
						if(j >= originalLength) {
							galleryFile.folder = directories[j].substring(Paths.mods().length, directories[j].length-1);
						}
						#end
					}
				}
			}
		}

		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i] + 'gallery/';
			if(FileSystem.exists(directory)) {
				var listOfStuff:Array<String> = CoolUtil.coolTextFile(directory + 'galleryList.txt');
				for (daStuff in listOfStuff)
				{
					var path:String = directory + daStuff + '.json';
					if(sys.FileSystem.exists(path))
					{
						addStuff(daStuff, path, directories[i], i, originalLength);
					}
				}

				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						addStuff(file.substr(0, file.length - 5), path, directories[i], i, originalLength);
					}
				}
			}
		}
		#end
	}

	private static function addStuff(fileToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
	{
		if(!imagesLoaded.exists(fileToCheck))
		{
			var stuff:GalleryFile = getGalleryFile(path);
			if(stuff != null)
			{
				var galleryFile:GalleryData = new GalleryData(stuff, fileToCheck);
				if(i >= originalLength)
				{
					#if MODS_ALLOWED
					galleryFile.folder = directory.substring(Paths.mods().length, directory.length-1);
					#end
				}

				imagesLoaded.set(fileToCheck, galleryFile);
				imagesList.push(fileToCheck);
			}
		}
	}

	private static function getGalleryFile(path:String):GalleryFile {
		var rawJson:String = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end

		if(rawJson != null && rawJson.length > 0) {
			return cast Json.parse(rawJson);
		}
		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE

	//To use on PlayState.hx or Highscore stuff
	public static function getGalleryFileName():String {
		return imagesList[PlayState.storyWeek];
	}

	//Used on LoadingState, nothing really too relevant
	public static function getCurrentStuff():GalleryData {
		return imagesLoaded.get(imagesList[PlayState.storyWeek]);
	}

	public static function setDirectoryFromGallery(?data:GalleryData = null) {
		Paths.currentModDirectory = '';
		if(data != null && data.folder != null && data.folder.length > 0) {
			Paths.currentModDirectory = data.folder;
		}
	}

	public static function loadTheFirstEnabledMod()
	{
		Paths.currentModDirectory = '';
		
		#if MODS_ALLOWED
		if (FileSystem.exists("modsList.txt"))
		{
			var list:Array<String> = CoolUtil.listFromString(File.getContent("modsList.txt"));
			var foundTheTop = false;
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1" && !foundTheTop)
				{
					foundTheTop = true;
					Paths.currentModDirectory = dat[0];
				}
			}
		}
		#end
	}
}