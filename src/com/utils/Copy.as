package com.utils
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	public class Copy 
	{
		//клонирует swf
		public static function copy(copy:*, width:int = 0, height:int = 0, realWidth:int = 0, realHeight:int = 0):DisplayObject
		{
			if (copy is MovieClip) swf(copy, width, height, realWidth, realHeight);
			if (copy is Bitmap) bitmap(copy, width, height);
			return null;
		}
		
		public static function swf(copy:*, width:int = 0, height:int = 0, realWidth:int = 0, realHeight:int = 0):MovieClip
		{
			var obj:* = null;
			if(copy) {
				obj = (new ((copy as Object).constructor)()) as MovieClip;
				obj.stop();
			} else return null;
			if (realWidth == 0) realWidth = obj.width;
			if (realHeight == 0) realHeight = obj.height;
			if(width > 0) obj.scaleX = width / realWidth;
			if(height > 0) obj.scaleY = height / realHeight;
			return obj;
		}
		
		public static function bitmap(copy:Bitmap, width:int = 0, height:int = 0):Bitmap
		{
			var bmp:Bitmap = new Bitmap(copy.bitmapData.clone());
			bmp.smoothing = copy.smoothing;
			if(width > 0) bmp.width = width;
			if(height > 0) bmp.height = height;
			return bmp;
		}
	}
}