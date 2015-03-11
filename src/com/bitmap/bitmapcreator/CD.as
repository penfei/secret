package com.bitmap.bitmapcreator
{
	import com.bitmap.bitmapdestructor.C;
	
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	public class CD
	{
		public static var l:int = 28;
		private static var f:Function;
		public static var init:Boolean=false;
		public function CD(_f:Function) 
		{
			ABCA.A();
			ABC.createAlpha();
			f=_f;
			init=true;
		}
		public static function set G(_g:Function):void{
			f=_g;
		}
		public static function Decode(ba:ByteArray):void
		{
			ABC.createBetta();
			
			var x:int = ba[ba.length-1];
			var bb:ByteArray = new ByteArray();
			ba.readBytes(bb,0,ba.length-1);
			ABCA.B(bb.length);
			for (var i:int = 0; i < bb.length; i++) bb[i]-=(ABC.alpha.indexOf(ABC.betta.charAt(i%(l*4))) + x + l - i);
			C.c = bb;
			f();
		}
	}
}