package com.drivecasino.files
{
	import flash.events.Event;
	
	public class ByteLoaderEvent extends Event
	{
		private var _content:*, _subfolder:String, _folder:String, _name:String; 
		
		public static const READY:String = "ready content loader from byte array";
		
		public function ByteLoaderEvent(type:String, content:*, subfolder:String, folder:String, name:String)
		{
			_content = content;
			_subfolder = subfolder;
			_folder = folder;
			_name = name;
			super(type, false, false);
		}

		public function get content():*
		{
			return _content;
		}

		public function get subfolder():String
		{
			return _subfolder;
		}

		public function get folder():String
		{
			return _folder;
		}

		public function get name():String
		{
			return _name;
		}


	}
}