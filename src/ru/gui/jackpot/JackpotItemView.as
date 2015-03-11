package ru.gui.jackpot 
{
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.text.TextFormat;
	import ru.gui.View;
	import symbols.JackpotUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class JackpotItemView extends View
	{
		private var _id:uint;
		private var _ui:JackpotUI
		private var _colorFlag:Boolean;
		
		private var _format:TextFormat = new TextFormat("Arial", 16, 0xFFFFFF, true);
		
		public function JackpotItemView(id:uint) 
		{
			_id = id;
			_ui = new JackpotUI();
			_ui.label.setTextFormat(_format);
			addChild(_ui);
		}
		
		public function update(label:String, canWin:Boolean):void 
		{
			TweenLite.killTweensOf(this);
			_ui.label.text = "JP" + String(_id + 1) + ": " + label;
			if (canWin) {
				_colorFlag = true;
				animation();
			} 
		}
		
		public function get id():uint 
		{
			return _id;
		}
		
		private function animation():void {
			if (_colorFlag) {
				_format.color = 0x6666FF;
			} else {
				_format.color = 0xFFFFFF;
			}
			_ui.label.setTextFormat(_format, 0, _ui.label.text.length);
			_colorFlag = !_colorFlag;
			
			TweenLite.to(this, 0.4, { onComplete:animation } );
		}
		
	}

}