package;

class FreeplayState extends MusicBeatState
{
	override function create()
	{
		MusicBeatState.switchState(new StoryMenuState());
		super.create();
	}

	public static function destroyFreeplayVocals() {
		
	}
}