package rolls 
{
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Sah
	 */
	public class TestIcon extends MovieClip
	{
		private var _id:uint;
		
		public function TestIcon(id:uint) 
		{
			_id = id;
			graphics.beginFill(Math.random() * 0x1000000);
			graphics.drawRect(0, 0, 222, 222);
		}
		
		static public function copy(icon:TestIcon):TestIcon {
			return new TestIcon(icon.id);
		}
		
		public function get id():uint 
		{
			return _id;
		}
		
	}

}