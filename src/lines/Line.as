package lines 
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author Sah
	 */
	public class Line extends Sprite
	{
		private var _main:Lines;
		private var _points:Array;
		private var _additionalPoints:Array;
		private var _color:Number;
		private var _lineContainer:Sprite;
		private var _cutContainer:Sprite;
		
		public function Line(main:Lines, points:Array, color:Number, additionalPoints:Array = null) 
		{
			_color = color;
			_points = points;
			_main = main;
			
			_lineContainer = new Sprite();
			addChild(_lineContainer);
			
			_cutContainer = new Sprite();
			addChild(_cutContainer);
			
			drawLine(_lineContainer, 4, 0, points);
			drawLine(_lineContainer, 2, _color, points);
			
			if(additionalPoints != null){
				drawCutLine(_cutContainer, 4, 0, additionalPoints);
				drawCutLine(_cutContainer, 2, _color, additionalPoints);
			}
		}
		
		public function setVisible(value:Boolean):void 
		{
			_lineContainer.visible = value;
		}
		
		public function setCutVisible(value:Boolean):void 
		{
			_cutContainer.visible = value;
		}
		
		private function drawLine(container:Sprite, tickness:Number, color:Number, points:Array, alpha:Number = 1):void {
			container.graphics.lineStyle(tickness, color, alpha , true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
			container.graphics.moveTo(points[0].x, points[0].y);
			for (var i:uint = 1; i < points.length; i++) {
				container.graphics.lineTo(points[i].x, points[i].y);
			}
		}
		
		private function drawCutLine(container:Sprite, tickness:Number, color:Number, points:Array, alpha:Number = 1):void {
			container.graphics.lineStyle(tickness, color, alpha , true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
			container.graphics.moveTo(points[0].x, points[0].y);
			for (var i:uint = 1; i < points.length; i++) {
				if( i % 2 == 0) container.graphics.moveTo(points[i].x, points[i].y);
				else container.graphics.lineTo(points[i].x, points[i].y);
			}
		}
		
		public function get color():Number 
		{
			return _color;
		}		
	}

}