package lines 
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sah
	 */
	public class WinBox extends Sprite
	{
		private var _ui:Sprite;
		private var _colored:Sprite;
		private var _container:Sprite;
		private var _main:Lines;
		
		private var _winAmountText:TextField;
		private var _winAmountTextFormat:TextFormat;
		
		public function WinBox(main:Lines) 
		{
			_main = main;
			
			_ui = new Sprite;
			_container = new Sprite;
			_colored = new Sprite;
			addChild(_ui);
			_ui.addChild(_container);
			_ui.addChild(_colored);
			
			_container.graphics.beginFill(0);
			_container.graphics.drawRect(0, 0, _main.winBoxWidth, _main.winBoxHeight);
			drawLine(8, 0x989898, 0.7);
			drawLine(6, 0x999999);
			drawLine(4, 0xCCCCCC);
			drawLine(2, 0xFFFFFF);
			
			_winAmountTextFormat = new TextFormat("Arial", 28, 0xffffff, true);
			_winAmountText = new TextField();
			_winAmountText.selectable = false;
			_winAmountText.mouseEnabled = false;
			_winAmountText.x = 5;
			_winAmountText.y = 2;
			_winAmountText.setTextFormat(_winAmountTextFormat);
			_winAmountText.autoSize = "left";
			_ui.addChild(_winAmountText);
			
			_colored.scale9Grid = new Rectangle(10, 10, _container.width - 20, _container.height - 20);
			
			//_ui.y = -_ui.height * 0.3;
			_ui.x = _main.iconWidth * 0.1;
		}
		
		public function setText(win:String, color:ColorTransform):void {
			_winAmountText.text = win;
			//_winAmountTextFormat.color = color;
			_winAmountText.setTextFormat(_winAmountTextFormat);
			_main.setColor(_winAmountText, color);
			_main.setColor(_colored, color);
			_colored.width = winText.length * 16.5 + 16;
			_container.width = _colored.width * 0.95;
		}
		
		private function drawLine(tickness:Number, color:Number, alpha:Number = 1):void {
			_colored.graphics.lineStyle(tickness, color, alpha , true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
			_colored.graphics.moveTo(0, 0);
			_colored.graphics.lineTo(_main.winBoxWidth, 0);
			_colored.graphics.lineTo(_main.winBoxWidth, _main.winBoxHeight);
			_colored.graphics.lineTo(0, _main.winBoxHeight);
			_colored.graphics.lineTo(0, 0);
		}
		
		public function get winText():String 
		{
			return _winAmountText.text;
		}
		
	}

}