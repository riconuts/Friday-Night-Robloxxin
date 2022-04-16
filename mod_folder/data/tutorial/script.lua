function michaelNotesFallsOffScreen()
	for i = 0,3 do -- 
		
		local sowyY = {
			defaultOpponentStrumY0,
			defaultOpponentStrumY1,
			defaultOpponentStrumY2,
			defaultOpponentStrumY3
		}
		local sowyR = {
			-90,
			0,
			90,
			90
		}
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