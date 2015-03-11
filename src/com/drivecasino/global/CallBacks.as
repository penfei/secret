package com.drivecasino.global
{
	import flash.utils.Dictionary;
	public class CallBacks
	{
		private static var FunctionsArr:Dictionary=new Dictionary();
		
		//List of Keys

		//------------
		public static function dispatch(str:String, target:*=null):void
		{
			if(FunctionsArr[str])
				target?FunctionsArr[str](target):FunctionsArr[str]();
		}
		public static function addListener(str:String,f:Function):void
		{
			FunctionsArr[str]=f;
		}
	}
}