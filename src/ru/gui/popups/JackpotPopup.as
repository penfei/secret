package ru.gui.popups 
{
	import com.drivecasino.global.CONTENT;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import ru.controller.Core;
	import ru.controller.SoundController;
	import ru.gui.View;
	import ru.utils.TextUtils;
	import sounds.winjp;
	/**
	 * ...
	 * @author Sah
	 */
	public class JackpotPopup extends View
	{
		private var _ui:MovieClip;
		
		public function JackpotPopup() 
		{
			mouseEnabled = false;
			
			_ui = CONTENT.swf.mc.JP;
			_ui.x = 62;
			_ui.y = 160;
			addChild(_ui);
			
			hide();
		}
		
		public function show():void {
			SoundController.playSound(winjp);
			trace(Core.data.jackpotWin, Core.data.currentDenomination);
			_ui.Open((Core.data.jackpotWin / Core.data.currentDenomination) * 100, Core.data.valute);
		}
		
		public function hide():void {
			_ui.Close();
		}
		
		public function get isShow():Boolean {
			return _ui.visible;
		}
		
	}

}