package lines 
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sah
	 */
	public class Icon extends Sprite
	{
		private var _main:Lines;
		private var _id:uint;
		
		public function Icon(main:Lines, id:uint) 
		{
			_id = id;
			_main = main;
			
			drawRect();
			drawLine(8, 0x989898, 0.7);
			drawLine(6, 0x999999);
			drawLine(4, 0xCCCCCC);
			drawLine(2, 0xFFFFFF);
		}
		
		private function drawLine(tickness:Number, color:Number, alpha:Number = 1):void {
			graphics.lineStyle(tickness, color, alpha , true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
			graphics.moveTo(0, 0);
			graphics.lineTo(_main.iconWidth, 0);
			graphics.lineTo(_main.iconWidth, _main.iconHeight);
			graphics.lineTo(0, _main.iconHeight);
			graphics.lineTo(0, 0);
		}
		
		private function drawRect():void {
			
		}
		
		public function get id():uint {return _id;}
		
	}

}