package com.drivecasino.files
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.utils.ByteArray;

	public class ByteLoader extends EventDispatcher
	{
		private var loader:Loader;
		private var data:ByteArray, subfolder:String, folder:String, name:String;

		public function ByteLoader(data:ByteArray, subfolder:String, folder:String, name:String)
		{
			this.subfolder = subfolder;
			this.folder = folder;
			this.name = name;
			this.data = data;
		}
		
		public function DoWork():void
		{
			switch(subfolder)
			{
				case "langs":
					var content:String = data.toString();
					ReadyEvent(content);
					break;
				
				case "images":
				case "swf":
					RenderTroughLoader(data);
					break;
				
				case "sounds":
					var s:Sound = new Sound();
					s.loadCompressedDataFromByteArray(data,data.length);
					ReadyEvent(s);
					break;
			}
		}
		
		
		private function RenderTroughLoader(data:ByteArray):void
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, readyContent);
			function readyContent(e:Event=null):void
			{
				ReadyEvent(loader.content);	
			}
			loader.loadBytes(data);
		}
		
		private function ReadyEvent(content:*):void
		{
			this.dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.READY, content, subfolder, folder, name));
		}
	}
}