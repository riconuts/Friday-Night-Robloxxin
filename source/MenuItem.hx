package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class MenuItem extends FlxUIButton
{
	public var targetX:Float = 0;
	public var targetY:Float = 0;

	public var isOver:Bool = false;

	var darked:Bool = false;
	var colorTween:FlxTween;

	public var textTitle:FlxText;
	public var textBase:String = ""; 
	public var tOffsetX:Float = 0;
	public var tOffsetY:Float = 0;

	public var attachments:Array<Dynamic> = [];

	public function new(x:Float, y:Float, imageName:String = '')
	{
		super(x, y);

		var imagePath:String = 'storymenu/' + imageName;
		if(!Paths.fileExists('images/' + imagePath + '.png', IMAGE)) imagePath = 'storymenu/placeholder';
		loadGraphic(Paths.image(imagePath));

		antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		x = Std.int(FlxMath.lerp(x, targetX, CoolUtil.boundTo(elapsed * 10.2, 0, 1)));
		y = Std.int(FlxMath.lerp(y, targetY, CoolUtil.boundTo(elapsed * 10.2, 0, 1)));
		
		// what is this garbage xdddd
		if (textTitle != null){
			textTitle.x = x + tOffsetX;
			textTitle.y = y + tOffsetY;
		}

		if (attachments.length != 0){
			for (i in 0...attachments.length){
				var sowy:Array<Dynamic> = attachments[i]; // 0: Object, 1: X Offset, 2: Y Offset

				if (sowy[0] != null)
					sowy[0].setPosition(x + sowy[1], y + sowy[2]);
			}
		}

		if (isOver && !darked){
			if(colorTween != null) {
				colorTween.cancel();
			}

			colorTween = FlxTween.color(this, 0.125, this.color, FlxColor.fromRGB(220, 220, 220),{
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
			darked = true;
		}
		else if (darked && !isOver){
			if(colorTween != null) {
				colorTween.cancel();
			}

			colorTween = FlxTween.color(this, 0.125, this.color, FlxColor.WHITE, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
			darked = false;			
		}
	}
}
