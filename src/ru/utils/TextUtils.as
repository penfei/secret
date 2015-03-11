package ru.utils 
{
	/**
	 * ...
	 * @author Sah
	 */
	public class TextUtils 
	{
		
		public function TextUtils() 
		{
			
		}
		
		static public function maskToString(mask:Number, length:uint = 5):String {
			var str:String = mask.toString(2);
			for (var i:uint = str.length; i < length; i++) {
				str = "0" + str;
			}
			return str;
		}
		
		static public function paymentToString(credits:Number):String {
			credits = formatNumber(credits);
			//var s:String = credits.toFixed(2);
			var s:String = credits.toString();
			s = formatString(s);
			s = deleteSymbols(s);
			return s;
		}
		
		static public function formatNumber(number:Number):Number {
			number *= 100;
			number = Math.round(number);
			number /= 100;
			return number;
		}
		
		static public function formatString(s:String):String {
			for (var i:uint = 0; i < s.length; i++) 
			{
				if (s.charAt(i) == "." && s.length - i < 3 ) {
					s += "0";
					return s;
				}
			}
			return s;
		}
		
		static public function creditsToString(credits:Number, delimiter:uint, isDeleteSymbols:Boolean = true, isDeleteRest:Boolean = true ):String {
			credits = formatNumber(credits);
			var s:String = (credits / delimiter).toFixed(2);
			s = formatString(s);
			if (isDeleteSymbols) s = deleteSymbols(s);
			if (isDeleteRest) s = deleteRest(s);
			return s;
		}
		
		static private function deleteSymbols(str:String):String {
			if (str.slice(str.length - 3, str.length) == ".00") 
				return str.slice(0, str.length - 3);
			return str;
		}
		
		static private function deleteRest(str:String):String {
			if (str.charAt(str.length - 3) == ".") return str.slice(0, str.length - 3);
			return str;
		}
		
	}

}