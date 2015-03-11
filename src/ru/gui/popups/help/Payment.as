package ru.gui.popups.help 
{
	import flash.text.TextField;
	/**
	 * ...
	 * @author Sah
	 */
	public class Payment 
	{
		private var _text:TextField;
		private var _basic:Number;
		private var _callBack:Function;
		
		public function Payment(text:TextField, basic:Number, callBack:Function) 
		{
			_callBack = callBack;
			_basic = basic;
			_text = text;
		}
		
		public function change():void {
			_callBack(_text, _basic);
		}
		
	}

}