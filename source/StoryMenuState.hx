package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxInputText;
import WeekData;
import flixel.addons.ui.FlxInputText;

using StringTools;

// roblox developer tier code

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var backButton:FlxUIButton;
	var leftArrow:FlxUIButton;
	var rightArrow:FlxUIButton;
	
	public static var searchBar:FlxInputText;

	var grpMenuItems:FlxTypedGroup<MenuItem>;
	var vignette:FlxSprite;

	static var curSelected:Int = 0;
	static var curDifficulty:Int = 2;
	private static var lastDifficultyName:String = 'Hard';

	public static var doingTransition:Bool = false;
	public static var overAnArrow:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

		FlxG.mouse.visible = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(curSelected >= WeekData.weeksList.length) 
			curSelected = 0;

		//// index shit

		grpMenuItems = new FlxTypedGroup<MenuItem>();

		var songArray:Array<String> = [];

		// dumb shit
		var decorationGroup = new FlxTypedGroup<FlxSprite>();
		var textGroup = new FlxTypedGroup<FlxText>();

		for (i in 0...WeekData.weeksList.length)
		{
			var daWeek = WeekData.weeksLoaded.get(WeekData.weeksList[i]);

			if (!weekIsLocked(i)){
				var newItem:MenuItem = new MenuItem(0, 0, WeekData.weeksList[i]);
				newItem.screenCenter(Y);
				newItem.targetX = 490 + (FlxG.width * i);
				newItem.targetY = newItem.y;
				newItem.x = newItem.targetX;
				newItem.textBase = daWeek.weekName;

				var textTitle = new FlxText(0, 0, 1280, newItem.textBase);
				textTitle.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.BLACK, LEFT);

				newItem.textTitle = textTitle;
				newItem.tOffsetY = 300;
				
				textGroup.add(textTitle);
				grpMenuItems.add(newItem);

				var likeImage = new FlxSprite();
				likeImage.loadGraphic(Paths.image('robloxMenu/decoration_likes'));
				var peopleImage = new FlxSprite();
				peopleImage.loadGraphic(Paths.image('robloxMenu/decoration_players'));

				var likeNumber = new FlxText(0, 0, 1000, FlxG.random.int(80, 100) + "%");
				likeNumber.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.BLACK, LEFT);	

				var peopleNumber = new FlxText(0, 0, 1000, FlxG.random.int(900, 999) + "K");
				peopleNumber.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.BLACK, LEFT);

				newItem.attachments.push([likeImage, 8, 370]);
				newItem.attachments.push([likeNumber, 50, 380]);
				newItem.attachments.push([peopleImage, 178, 370]);
				newItem.attachments.push([peopleNumber, 220, 380]);

				decorationGroup.add(likeImage);
				decorationGroup.add(likeNumber);
				decorationGroup.add(peopleImage);
				decorationGroup.add(peopleNumber);

				newItem.onOver.callback = function(){
					if (i == curSelected && persistentUpdate)
						newItem.isOver = true;
				};
				newItem.onOut.callback = function(){
					newItem.isOver = false;
				};
				newItem.onUp.callback = function(){
					if (i == curSelected && persistentUpdate && !overAnArrow)
						selectWeek(i);
				};

				
				var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[i]).songs;
				for (i in 0...leWeek.length) {
					songArray.push(leWeek[i][0]);
				}
			}
		}
		

		////
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(242, 244, 245));
		add(bg);

		var topbar = new FlxSprite().loadGraphic(Paths.image('robloxMenu/menu_topbar'));
		add(topbar);

		backButton = new FlxUIButton();
		backButton.loadGraphic(Paths.image('robloxMenu/menu_back_button'));
		backButton.loadGraphic(Paths.image('robloxMenu/menu_back_button'), true, Math.floor(backButton.width / 2), Math.floor(backButton.height));
		backButton.animation.add("backButton", [0, 1], 0, false, false);
		backButton.animation.play("backButton");
		add(backButton);

		add(decorationGroup);
		add(grpMenuItems);
		add(textGroup);

		vignette = new FlxSprite().loadGraphic(Paths.image('storymenu/vignette'));
		vignette.alpha = 0;
		add(vignette);

		leftArrow = new FlxUIButton(430, 213, "", function(){ trace("yeaaa"); }, false, true);
		leftArrow.loadGraphic(Paths.image('robloxMenu/menu_arrow_button'));

		rightArrow = new FlxUIButton(820, 213, "", function(){ trace("yeaaa"); }, false);
		rightArrow.loadGraphic(Paths.image('robloxMenu/menu_arrow_button'));
		rightArrow.flipX = true;

		add(leftArrow);
		add(rightArrow);

		////

		searchBar = new FlxInputText(430, 16, 420, "", 24);
		searchBar.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.BLACK);

		var searchGhost = new FlxText(430, 16, 420, "Search");
		searchGhost.setFormat(Paths.font("gothamss.ttf"), 24, FlxColor.fromRGB(200, 200, 200));

		searchBar.callback = function(sowy:String, input:String){ // is also on SearchResultSubstate
			searchGhost.visible = (sowy == "");
	
			if (sowy != "" && input == "enter"){
				switch(sowy.toLowerCase()){
	
					// load a secret song
					case "obby for succ":
						loadSong("INAPPROPRIATE");
					
					case "tacos":
						loadSong("annoying");
					
					case "foreseen":
						loadSong("Cyberphobia");
					
					case "da hood":
						loadSong("hank in da hood");
					
					case "studio":
						loadSong("W.I.P");
					
					
					default: // search in "freeplay"
						persistentUpdate = false;
						doingTransition = true;
						StoryMenuState.searchBar.text = sowy;
						openSubState(new SearchResultSubstate(sowy));
				}
			}
		};

		add(searchBar);
		add(searchGhost);

		////

		backButton.onOver.callback = function(){
			backButton.animation.curAnim.curFrame = 1;
		};
		backButton.onOut.callback = function(){
			backButton.animation.curAnim.curFrame = 0;
		};
		backButton.onUp.callback = function(){
			exitState();
		};


		leftArrow.onUp.callback = function(){
			changeSelection(-1);
		};
		rightArrow.onUp.callback = function(){
			changeSelection(1);
		};


		var overFunc = function(){overAnArrow = true;};
		var outFunc = function(){overAnArrow = false;};

		leftArrow.onOver.callback = overFunc;
		leftArrow.onOut.callback = outFunc;
		rightArrow.onOver.callback = overFunc;
		rightArrow.onOut.callback = outFunc;
		
		changeSelection();
		changeDifficulty();

		super.create();
	}

	function changeSelection(sowy:Int = 0)
	{
		curSelected += sowy;

		if (sowy != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	
		if (curSelected < 0)
			curSelected = grpMenuItems.length - 1;
		else if (curSelected > grpMenuItems.length - 1)
			curSelected = 0;
	
		////

		PlayState.storyWeek = curSelected;

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
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		////

		var bullShit:Int = 0;
		for (item in grpMenuItems.members)
		{
			item.targetX = 490 + (FlxG.width * (bullShit - curSelected));
	
			if (bullShit == curSelected){
				var mom = grpMenuItems.members[bullShit];
				mom.textTitle.text = mom.textBase + "\n" + lastDifficultyName;
			}
	
			bullShit++;
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;
	
		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];
		changeSelection();
	}

	function selectWeek(weekNumber:Int = null) // For the normal fucking weeks
	{
		if (weekNumber == null)
			weekNumber = curSelected;			

		if (!weekIsLocked(weekNumber) && !doingTransition && persistentUpdate)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			doingTransition = true;
	
			//
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[weekNumber]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}
	
			//
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
				
			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';
	
			PlayState.storyDifficulty = curDifficulty;
	
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;

			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.fadeOut(0.7, 0);
		}
		else if (!doingTransition && persistentUpdate)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	public static function loadSong(daSong:String, weekNumber:Int = 912389) // For secret songs
	{
		PlayState.isStoryMode = false;

		PlayState.storyWeek = weekNumber;
		PlayState.storyPlaylist = [daSong];

		var leDifficulty = 1; // "Normal" Difficulty // curDifficulty

		PlayState.storyDifficulty = leDifficulty;

		var diffic = CoolUtil.getDifficultyFilePath(leDifficulty);
		diffic = (diffic == null || diffic == "-null") ? '' : diffic;
		
		PlayState.SONG = Song.loadFromJson(daSong.toLowerCase() + diffic, daSong.toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;

		LoadingState.loadAndSwitchState(new PlayState());
		
		FlxG.sound.music.fadeOut(0.7, 0);
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function exitState()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));

		doingTransition = true;
		FlxG.mouse.visible = false;

		MusicBeatState.switchState(new MainMenuState());
	}

	override function closeSubState() {
		persistentUpdate = true;
		doingTransition = false;
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if (!doingTransition && persistentUpdate && !searchBar.hasFocus)
		{
			var leftP = controls.UI_LEFT_P;
			var rightP = controls.UI_RIGHT_P;
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;

			if (leftP)
				changeSelection(-1);
			else if (rightP)
				changeSelection(1);


			if (upP)
				changeDifficulty(1);
			else if (downP)
				changeDifficulty(-1);


			if (FlxG.keys.justPressed.E){
				curDifficulty = 0;
				changeDifficulty();
			}
			else if (FlxG.keys.justPressed.N){
				curDifficulty = 1;
				changeDifficulty();
			}
			else if (FlxG.keys.justPressed.H){
				curDifficulty = 2;
				changeDifficulty();				
			}


			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curSelected));
			}



			if (controls.ACCEPT)
				selectWeek();
			if (controls.BACK)
				exitState();
		}

		super.update(elapsed);
	}
}