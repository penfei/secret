package ru.gui.main 
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import ru.controller.DataController;
	/**
	 * ...
	 * @author Sah
	 */
	public class GameIcon extends Icon
	{
		private var _position:int;
		public var scetterAnimation:MovieClip;
		
		public function GameIcon(iconID:int, position:int, image:Bitmap, animate:MovieClip) 
		{
			_position = position;
			
			super(iconID, image, animate);			
		}
		
		override public function showImage():void {
			animate.visible = false;
			animate.stop();
			if(scetterAnimation != null){
				scetterAnimation.visible = false;
				scetterAnimation.stop();
			}
			
		}
		
		override public function playAnimation():void {
			animate.visible = true;
			animate.gotoAndPlay(0);
		}
		
		public function playScetterAnimation():void 
		{
			scetterAnimation.visible = true;
			scetterAnimation.gotoAndPlay(0);
		}
		
		public function setScetterAnimation(scetterAnimation:MovieClip):void 
		{
			this.scetterAnimation = scetterAnimation;
			addChild(this.scetterAnimation);
			this.scetterAnimation.stop();
			
			showImage();
		}
		
		public function get isScetter():Boolean 
		{
			return id == DataController.SCETTER;
		}
		
		public function get position():int 
		{
			return _position;
		}
		
	}

}