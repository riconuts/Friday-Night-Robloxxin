function onCreate()


	makeLuaSprite('stageback', 'SFOTHsky', -520, -130);
	setLuaSpriteScrollFactor('stageback', 0.8, 0.8);

	makeLuaSprite('stagemid', 'SFOTHtowers', -520, -130);
	setLuaSpriteScrollFactor('stagemid', 0.9, 0.9);

	makeLuaSprite('stageground', 'SFOTHground', -520, -130);
	setLuaSpriteScrollFactor('stageground', 1.0, 1.0);


	addLuaSprite('stageback', false);
	addLuaSprite('stagemid', false);
	addLuaSprite('stageground', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end