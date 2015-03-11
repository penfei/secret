package ru.preloader 
{
	import com.bitmap.bitmapdestructor.CBA;
	import com.drivecasino.files.Decomposer;
	import com.drivecasino.files.Merchandiser;
	import com.drivecasino.global.CONTENT;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sah
	 */
	public class ContentDownloader 
	{
		private var _params:Object;
		private var _callBack:Function;
		private var _language:String;
		private var _fullScreen:Boolean;
		private var _isOnline:Boolean;
		private var _currentDownload:uint = 0;
		private var _currentMerchendise:uint = 0;
		private var _screenFolder:String;
		private var _items:Vector.<LoadingItem>;
		
		private var _mainFolder:String;
		private var _netFolder:String;
		
		private var _cba:CBA;
		private var _languageImage:String;
		
		public function ContentDownloader(params:Object, callBack:Function, mainFolder:String, netFolder:String, linesFolder:String, linesView:String) 
		{
			_mainFolder = mainFolder;
			_netFolder = netFolder;
			_items = new Vector.<LoadingItem>();
			
			_isOnline = params.isOnline;
			_callBack = callBack;
			_params = params;
			_language = params.lang;
			if (params.full) _fullScreen = true;
			else _fullScreen = false;
			
			if (_fullScreen) _screenFolder = "full";
			else _screenFolder = "window";
			
			_languageImage = _language == "ru" ? "ru":"en";
			
			_cba = new CBA(slash + _mainFolder);
			_cba.addEventListener(CBA.END_LOAD_GAME, partLoadComplete);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function partsComplete(e:Event):void
			{				
				_cba.startLoadContent(JSON.parse(loader.data).files);
			});
			loader.load(new URLRequest(slash + _mainFolder + "res.json?" + Math.random().toString()));
			
			load(slash + _netFolder + "net.swf", function requestCompleteHandler(e:Event):void {
				_params.net = e.target.content as MovieClip;
			});
			load(slash + linesFolder + "lines2.swf", function requestCompleteHandler(e:Event):void {
				_params.lines = e.target.content as MovieClip;
			});
			load(slash + linesFolder + linesView, function requestCompleteHandler(e:Event):void {
				_params.linesView = e.target.content as MovieClip;
			});
			
			languageRequest();
		}
		
		private function partLoadComplete(e:Event):void 
		{
			var content:ByteArray = _cba.getContentGame();
			var filesArr:Array = Decomposer.DecomposeFile(content);
			
			var m:Merchandiser = new Merchandiser();
			m.addEventListener("READY", onMerchendised);
			m.DoWork(filesArr);
			
			function onMerchendised(e:Event):void
			{
				_params.mainSWF = CONTENT.swf.mc.main;
				_currentMerchendise++;
				checkCompleteDownload();
			}			
		}
		
		private function checkCompleteDownload():void 
		{
			if (_currentDownload >= _items.length && _cba.isStartLoad && _currentMerchendise >= _cba.items.length) {
				Merchandiser.ApplyLang(CONTENT.options.lang);
				Merchandiser.ApplySmoothing();
				_callBack(_params);
			}
		}
		
		private function languageRequest():void 
		{
			var item:LoadingItem = new LoadingItem();
			item.loadUrl(slash + _mainFolder + "locale/" + _language + ".html", function requestCompleteHandler(e:Event):void {
				var reg:RegExp = /\r\n/g;
				var data:String = e.target.data.replace(reg, "&");
				_params.words = new URLVariables(data);
				_currentDownload++;
				checkCompleteDownload();
			});
			_items.push(item);
		}
		
		private function load(url:String, callBack:Function):void 
		{
			var item:LoadingItem = new LoadingItem();
			item.load(url, function requestCompleteHandler(e:Event):void {
				callBack(e);
				_currentDownload++;
				checkCompleteDownload();
			});
			_items.push(item);
		}
		
		public function get slash():String { return _isOnline ? "/" : ""; }
		public function get downloadCount():uint {return _items.length;}
		public function get currentDownload():uint { return _currentDownload; }
		public function get isStartLoad():Boolean {
			//for each(var item:LoadingItem in _items) {
				//if (item.bytesTotal == 0) return false;
			//}
			//if (_cba.bytesTotal == 0) return false;
			//if (!_cba.isLoad) return false;
			if (!_cba.isStartLoad) return false;
			return true;
		}
		
		public function get bytesLoaded():Number {
			var loaded:Number = 0;
			//for each(var item:LoadingItem in _items) {
				//loaded += item.bytesLoaded;
			//}
			loaded += _cba.bytesLoaded;
			return loaded;
		}
		
		public function get bytesTotal():Number {
			var total:Number = 0;
			//for each(var item:LoadingItem in _items) {
				//total += item.bytesTotal;
			//}
			total += _cba.bytesTotal;
			return total;
		}
		
	}

}