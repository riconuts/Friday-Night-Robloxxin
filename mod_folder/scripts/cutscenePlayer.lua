local songsWithCutscenes = {
	["Noobed"] = true,
	["Tryhard"] = true,
}
local allowCountdown = false

function onStartCountdown()
	if songsWithCutscenes[songName] and not allowCountdown and isStoryMode and not seenCutscene then
		startVideo(songName);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end