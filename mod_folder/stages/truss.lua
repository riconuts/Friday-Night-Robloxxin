function onCreate()


	makeLuaSprite('stagesky', 'inapSKY', -520, -130);
	setLuaSpriteScrollFactor('stagesky', 0.8, 0.8);

	makeLuaSprite('stagetruss', 'inapTRUSS', -520, -130);
	setLuaSpriteScrollFactor('stagetruss', 1.0, 1.0);


	addLuaSprite('stagesky', false);
	addLuaSprite('stagetruss', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end