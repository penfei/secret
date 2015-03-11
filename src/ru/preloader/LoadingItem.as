package ru.preloader 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author ...
	 */
	public class LoadingItem 
	{
		public var bytesLoaded:Number = 0;
		public var bytesTotal:Number = 0;
		public var isLoad:Boolean = false;
		
		public function LoadingItem() 
		{
			
		}
		
		public function loadUrl(url:String, callBack:Function, dataFormat:String = null ):void {
			var loader:URLLoader = new URLLoader();
			if (dataFormat != null) loader.dataFormat = dataFormat;
			loader.addEventListener(ProgressEvent.PROGRESS,  progressHandler);
			loader.addEventListener(Event.COMPLETE,  function requestCompleteHandler(e:Event):void {
				isLoad = true;
				loader.removeEventListener(ProgressEvent.PROGRESS,  progressHandler);
				loader.removeEventListener(Event.COMPLETE,  requestCompleteHandler);
				callBack(e);
			});
			loader.load(new URLRequest(url));
		}
		
		public function load(url:String, callBack:Function):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,  progressHandler);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function requestCompleteHandler(e:Event):void {
				isLoad = true;
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,  progressHandler);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,  requestCompleteHandler);
				callBack(e);
			});
			loader.load(new URLRequest(url));
		}
		
		private function progressHandler(e:ProgressEvent):void 
		{
			bytesLoaded = e.bytesLoaded;
			bytesTotal = e.bytesTotal;
		}
		
	}

}