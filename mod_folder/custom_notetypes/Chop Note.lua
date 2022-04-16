function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Chop Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'SwordNote'); --Change texture

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
			
			end
		end
	end
end

-- Function called when you hit a note (after note hit calculations)
-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
-- noteType: The note type string/tag
-- isSustainNote: If it's a hold note, can be either true or false

function noteMiss(id, direction, noteType, isSustainNote)
	if noteType == "Chop Note" then
		playSound('swing',1,'shootsnd')
		setProperty('health', -500);
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if noteType == "Chop Note" then
		characterPlayAnim('Dad','Sword',false)
		setProperty("dad.specialAnim", true)
		
		characterPlayAnim('BF','dodge',false)
		setProperty("boyfriend.specialAnim", true)
		
		cameraShake('game',0.01,0.1)
		playSound('swing',1,'shootsnd')
	end
end