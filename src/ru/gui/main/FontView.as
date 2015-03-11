package ru.gui.main 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import ru.gui.View;
	/**
	 * ...
	 * @author Sah
	 */
	public class FontView extends View
	{		
		protected var source:Class;
		
		private var _text:String;
		private var _centerAlign:Boolean;
		private var _chars:Array;
		private var _container:Sprite;
		private var _realWidth:Number;
		
		public function FontView(sourceObject:Class, text:String, centerAlign:Boolean = true, maxChars:uint = 20 ) 
		{
			_centerAlign = centerAlign;
			_text = text;
			_realWidth = 0;
			
			_container = new Sprite();
			addChild(_container);
			
			_chars = new Array()
			for (var i:uint = 0; i < maxChars; i++) {
				var char:MovieClip = new sourceObject();
				char.x = -i * char.width;
				_chars.push(char);
				_container.addChild(char);
			}
			
			updateText();
		}
		
		private function updateText():void 
		{
			_realWidth = 0;
			for (var i:uint = 0; i < _chars.length; i++) {
				_chars[i].visible = i < _text.length;
				if (_chars[i].visible) {
					_chars[i].gotoAndStop(uint(_text.charAt(_text.length - i - 1)) + 1);
					_realWidth += _chars[i].width;
				}
			}
			if (_centerAlign) _container.x = _realWidth / 2;
			else _container.x = 0;
		}
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			_text = value;
			
			updateText();
		}
		
	}

}