package ru.gui.popups 
{
	import com.drivecasino.global.CONTENT;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import ru.gui.View;
	/**
	 * ...
	 * @author Sah
	 */
	public class ExitPopup extends View
	{
		private var _ui:*;
		
		public function ExitPopup(title:String, left:String, right:String) 
		{
			_ui = CONTENT.swf.mc.CloseWindows;
			_ui.y = 26;
			addChild(_ui);
			_ui.Set(title, left, right);
			_ui.Open();
			visible = false;
		}
		
		public function activate():void {
			visible = !visible;
		}
		
		public function setLeft(callback:Function):void {
			_ui.SetLeft(callback);
		}
		
		public function setRight(callback:Function):void {
			_ui.SetRight(callback);
		}
		
	}

}