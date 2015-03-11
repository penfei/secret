package com.bitmap.bitmapcreator
{
	import com.adobe.crypto.MD5;
	
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;

	public class ABCA
	{
		private var a:Array = [47,55,55,57,53,102,52,101];
		public var b:int = 1; 

		public function ABCA(i:int)
		{
			b+=a[i]-i%2;
		}
		public static function A():void
		{
			CD.l*=2;
			var ba:ByteArray = new ByteArray();
			ba.writeByte(CD.l);
			CD.l = int(ba.toString());
		}
		public static function B(l:int):void
		{
			ABC.betta=MD5.hash(ABC.betta+l);
		}

	}
}