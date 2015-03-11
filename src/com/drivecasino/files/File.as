package com.drivecasino.files
{
	import flash.utils.ByteArray;

	public class File
	{
		public var path:String;
		public var bytes:ByteArray;
		
		public function File(path:String, bytes:ByteArray)
		{
			this.path = path;
			this.bytes = bytes;
		}
	}
}