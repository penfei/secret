package ru.gui.main 
{
	import com.utils.Copy;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import ru.gui.View;
	/**
	 * ...
	 * @author Sah
	 */
	public class Icon extends MovieClip
	{
		private var _id:uint;
		
		public var image:Bitmap;
		public var animate:MovieClip;
		
		public function Icon(iconID:uint, image:Bitmap, animate:MovieClip) 
		{
			_id = iconID;
			this.image = image;
			this.animate = animate;
			if (this.animate == null) this.animate = new MovieClip;
			addChild(this.image);
			addChild(this.animate);
			this.animate.stop();
			
			showImage();
		}
		
		public function showImage():void {
			animate.visible = false;
			animate.stop();
		}
		
		public function playAnimation():void {
			animate.visible = true;
			animate.gotoAndPlay(0);
		}
		
		public function get id():uint 
		{
			return _id;
		}
		
	}

}