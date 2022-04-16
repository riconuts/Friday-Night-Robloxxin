function onCreate()


	makeAnimatedLuaSprite('theSky','inapFALLsky', -520, -130);
	addAnimationByPrefix('theSky','clouds','sky',20,true);
	setLuaSpriteScrollFactor('theSky', 0.8, 0.8);
	addLuaSprite('theSky',false);
	objectPlayAnimation('theSky','clouds',false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end