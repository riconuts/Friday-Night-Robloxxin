originalZoom = 1
function onCreate()
	originalZoom = getProperty("defaultCamZoom")
	
	precacheImage("inapFALLsky")
	
	precacheImage("characters/FallBF")
	precacheImage("characters/FALLING")
	
	addCharacterToList("fallbf", "bf")
	addCharacterToList("falling", "dad")

	makeAnimatedLuaSprite("inapFALLsky", "inapFALLsky", -520, -230)
	addAnimationByPrefix("inapFALLsky", "loop", "sky", 30, true)
	addLuaSprite("inapFALLsky", false)
	setProperty("inapFALLsky.visible", false)
end

function onCreatePost()
	
end

function changeStage()
	removeLuaSprite("stagesky", true)
	removeLuaSprite("stagetruss", true)
	
	setProperty("inapFALLsky.visible", true)
	
	triggerEvent("Change Character", "bf", "fallbf")
	triggerEvent("Change Character", "dad", "falling")
	setProperty("boyfriend.alpha", 1)
	
	-- bf joins in
	setProperty("boyfriend.y", getProperty("boyfriend.y") - 1000)
	doTweenY("bfOn", "boyfriend", getProperty("boyfriend.y") + 900, 2, "sineInOut")
	
	cameraUnfreeze()
	onUpdate = nil
	onUpdatePost = nil
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == "changeStage" then
		changeStage()
	elseif tag == "michaelFucksUp" then
		doTweenY("michaelAwayY", "dad", getProperty("dad.y") + 75, 0.375, "sineInOut")
	end
end

-- useful funcs
function leTweenZoom(zoom, duration, ease)
	doTweenZoom("leTweenZoom", "camGame", 1.45, 1.1, (ease ~= nil and ease or "linear"))
	setProperty("defaultCamZoom", zoom)
end
function cameraFreeze()
	triggerEvent("Camera Follow Pos", getProperty("camFollowPos.x"), getProperty("camFollowPos.y"))
end
function cameraUnfreeze()
	triggerEvent("Camera Follow Pos", "", "")
end
--

function michaelNotesFallsOffScreen()
	local sowyY = {
		defaultOpponentStrumY0,
		defaultOpponentStrumY1,
		defaultOpponentStrumY2,
		defaultOpponentStrumY3
	}
	local sowyR = {-90,0,90,90}

	for i = 0,3 do 
		local si = tostring(i)
		
		noteTweenY(
			("NoteY"..si), 
			i, 
			((sowyY[i+1]) + 720*2.5), 
			1.625, 
			"sineIn"
		)
		noteTweenAlpha(
			("NoteAlpha"..si), 
			i, 
			0, 
			0.75, 
			"sineIn"
		)
		noteTweenAngle(
			("NoteAngle"..si), 
			i, 
			(sowyR[i+1]), 
			0.75, 
			"sineIn"
		)
	end
end

function onEvent(name, value1, value2)
	if name == "Song Animation" then
		if value1 == "1" then -- michael talks
			leTweenZoom(1.45, 1.1, "circIn")
			
			-- since they are way too close and bf doesnt have a falling animation i have to do this
			doTweenX("bfAway", "boyfriend", getProperty("boyfriend.x") + 1000, 3, "sineOut")
			doTweenX("gfAway", "gf", getProperty("gf.x") + 1000, 3, "sineOut")
		
			doTweenAlpha("bfDis", "boyfriend", 0, 1.25, "sineIn")
			doTweenAlpha("gfDis", "gf", 0, 1.25, "sineIn")
		elseif value1 == "2" then -- michael is going to fall
		
			local sowy = function() 
				cameraFlash("game", "FFFFFF", 0.4, true)
			end
			
			onUpdate = sowy
			onUpdatePost = sowy
		end

	elseif name == "Play Animation" then
		if value1 == "trip" and value2 == "dad" then -- michael is going to fall
			doTweenX("michaelAwayX", "dad", getProperty("dad.x") - 40, 1.1, "circIn")
			
			leTweenZoom(originalZoom, 0.75, "circIn")
			
			runTimer("michaelFucksUp", 0.375)
			runTimer("changeStage", 0.75)
			
			cameraFreeze()
			
		elseif value1 == "scream" and value2 == "dad" then
			cameraFreeze()
		
			doTweenY("michaelAway", "dad", getProperty("dad.y") + 1250, 1.625, "sineInOut")
			
			michaelNotesFallsOffScreen()
		end
	end
end