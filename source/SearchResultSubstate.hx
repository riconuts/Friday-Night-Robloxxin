package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import openfl.utils.Assets as OpenFlAssets;

import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class SearchResultSubstate extends MusicBeatSubstate
{
	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	////
	var songs:Array<SongMetadata> = [];

	var backButton:FlxUIButton;
	var leftArrow:FlxUIButton;
	var rightArrow:FlxUIButton;

	var searchBar:FlxInputText;

	var grpMenuItems:FlxTypedGroup<MenuItem>;
	var vignette:FlxSprite;

	var innapropiate:Array<String> = [ // IM SORRY MOM ILL NEVER SAY BAD WORDS AGAIN 
		"fuck",
		"sex",
		"bitch",
		"nig",
		"shit",
		"gay",
		"fag"
	];

	var back2back:Bool = false;
	var scroll:Int = 0;


	public function new(sowy:String)
	{
		super();
		
		persistentUpdate = true;
		
		WeekData.reloadWeekFiles(false);

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			/*
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}
			*/
			
			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				addSong(song[0], i, song[1]);
			}
		}
		
		WeekData.setDirectoryFromWeek();
		
		//// search begin

		//// do stupid censor
		var isValidSearch:Bool = true;
		for (i in 0...innapropiate.length){
			var word:String =  innapropiate[i];

			if (StringTools.contains(sowy, word)){
				isValidSearch = false;
			}
		}

		//// do stupid search
		var resultList:Array<SongMetadata> = [];

		if (isValidSearch){
			for (i in 0...songs.length){
				var song:SongMetadata = songs[i];
				var songName:String = song.songName.toLowerCase();

				if (StringTools.contains(songName, sowy.toLowerCase())){
					//trace("found: " + songName + " with " + sowy);
					resultList.push(song);
				}
			}
		}
		//trace("Found: " + resultList.length, " results.");

		//// create result items
		grpMenuItems = new FlxTypedGroup<MenuItem>();
		var itemTexts = new FlxTypedGroup<FlxText>();

		for (i in 0...resultList.length){
			var song:SongMetadata =  resultList[i];

			var newItem:MenuItem = new MenuItem(0, 0, "week"+song.week);
			newItem.targetX = 75;
			newItem.targetY = i*200 + 65 + 75;
			newItem.y = newItem.targetY;

			newItem.setGraphicSize(150, 150);
			newItem.updateHitbox();

			////
			var textTitle = new FlxText(0, 0, 1000, song.songName);
			textTitle.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.BLACK);

			newItem.textTitle = textTitle;
			newItem.tOffsetX = 225;
			newItem.tOffsetY = 75 - 24/2;

			itemTexts.add(textTitle);
			grpMenuItems.add(newItem);

			newItem.onOver.callback = function(){
				if (!back2back) newItem.isOver = true;
			};
			newItem.onOut.callback = function(){
				newItem.isOver = false;
			};
			newItem.onUp.callback = function(){
				if (!back2back) selectSong(song);
			};
		}
		
		//// do menu ui
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(242, 244, 245));
		add(bg);

		add(grpMenuItems);
		add(itemTexts);

		var topbar = new FlxSprite().loadGraphic(Paths.image('robloxMenu/menu_topbar'));
		add(topbar);

		if (resultList.length == 0){
			var none:FlxText = new FlxText(0, 65, FlxG.width, "No Results Found");
			none.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.BLACK);

			add(none);
		}

		backButton = new FlxUIButton();
		backButton.loadGraphic(Paths.image('robloxMenu/menu_back_button'));
		backButton.loadGraphic(Paths.image('robloxMenu/menu_back_button'), true, Math.floor(backButton.width / 2), Math.floor(backButton.height));
		backButton.animation.add("backButton", [0, 1], 0, false, false);
		backButton.animation.play("backButton");
		add(backButton);

		backButton.onOver.callback = function(){
			backButton.animation.curAnim.curFrame = 1;
			back2back = true;
		};
		backButton.onOut.callback = function(){
			backButton.animation.curAnim.curFrame = 0;
			back2back = false;
		};
		backButton.onUp.callback = function(){
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		};


		searchBar = new FlxInputText(430, 16, 420, sowy, 24);
		searchBar.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.BLACK);

		var searchGhost = new FlxText(430, 16, 420, "Search");
		searchGhost.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.fromRGB(200, 200, 200));
		searchGhost.visible = (sowy == "");

		StoryMenuState.searchBar.hasFocus = false;

		searchBar.callback = function(sowy:String, input:String){
			searchGhost.visible = (sowy == "");

			if (sowy != "" && input == "enter"){
				// do search
				persistentUpdate = false;
				
				openSubState(new SearchResultSubstate(sowy));
			}
		};

		searchBar.callback = function(sowy:String, input:String){ // is also on StoryMenuSubstate
			searchGhost.visible = (sowy == "");
	
			if (sowy != "" && input == "enter"){
				switch(sowy.toLowerCase()){
	
					// load a secret song
					case "obby for succ":
						StoryMenuState.loadSong("INAPPROPRIATE");
					
					case "tacos":
						StoryMenuState.loadSong("annoying");
					
					case "foreseen":
						StoryMenuState.loadSong("Cyberphobia");
					
					case "da hood":
						StoryMenuState.loadSong("hank in da hood");
					
					case "studio":
						StoryMenuState.loadSong("W.I.P");
					
					
					default: // search in "freeplay"
						persistentUpdate = false;
						StoryMenuState.searchBar.text = sowy;
						openSubState(new SearchResultSubstate(sowy));
				}
			}
		};

		add(searchBar);
		add(searchGhost);

		//trace("menu asseted");


		if(curSelected >= songs.length) 
			curSelected = 0;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();


		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, FlxColor.WHITE));
	}

	function selectSong(song:SongMetadata)
	{
		PlayState.isStoryMode = false;

		Paths.currentModDirectory = song.folder;

		PlayState.storyWeek = song.week;
		PlayState.storyPlaylist = [song.songName];

		PlayState.storyDifficulty = curDifficulty;

		var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
		if(diffic == null || diffic == "-null")
			diffic = '';
		
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());

		LoadingState.loadAndSwitchState(new PlayState());
		FreeplayState.destroyFreeplayVocals();
		
		FlxG.sound.music.fadeOut(0.7, 0);
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		if (!searchBar.hasFocus)
		{

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		/*
		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		*/

		if (controls.BACK){
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}

		if(ctrl){
			openSubState(new GameplayChangersSubstate());
		}

		else if (accepted)
		{

		}
		else if(controls.RESET)
		{
			/*
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
			*/
		}
		}
		super.update(elapsed);
	}



	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		PlayState.storyDifficulty = curDifficulty;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		curSelected += change;

		var changed:Bool = true;

		if (curSelected < 0){
			curSelected = 0;
			changed = false;
		}
		else if (curSelected >= grpMenuItems.length){
			curSelected = grpMenuItems.length - 1;
			changed = false;
		}

		if(playSound && changed) 
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		////

		var bullShit:Int = 0;
		for (item in grpMenuItems.members)
		{
			item.targetY = (bullShit - curSelected)*200 + 65 + 75;
			bullShit++;
		}

		////

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		////trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}
}

// idk why i moved here
class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}