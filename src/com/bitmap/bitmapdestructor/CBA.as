package com.bitmap.bitmapdestructor
{
	import com.bitmap.bitmapcreator.CD;
	import ru.preloader.LoadingItem;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	

	public class CBA extends Sprite
	{
		public static const END_LOAD_PROMPT:String="end_load_prompt";
		public static const END_LOAD_GAME:String="end_load_game";
		public static const PROGRESS_LOAD:String = "progress_load";
		
		private var _items:Vector.<LoadingItem>
		private var _loader:URLLoader = new URLLoader();
		private var _contentGame:*;
		private var _url:String;
		private var _isStartLoad:Boolean;
		
		public function CBA(url:String)
		{
			_url = url;
			_isStartLoad = false;
		}
		
		private function onLoaded(e:Event):void
		{
			CD.Decode(_loader.data);
		}
		
		public function startLoadContent(parts:Array):void
		{
			_isStartLoad = true;
			_items = new Vector.<LoadingItem>;
			for each(var part:String in parts) {
				var item:LoadingItem = new LoadingItem();
				item.loadUrl(_url + part, loadComplete, URLLoaderDataFormat.BINARY);
				_items.push(item);
			}
		}
		
		private function loadComplete(e:Event):void {
			if (CD.init) CD.G = onDecodedContent;
			else new CD(onDecodedContent);
			CD.Decode(e.target.data);
		}
		
		private function onDecodedContent():void{
			_contentGame = C.c;
			_loader.removeEventListener(Event.COMPLETE,onLoaded);
			_loader.removeEventListener(ProgressEvent.PROGRESS, onProgres);
			dispatchEvent(new Event(END_LOAD_GAME));
		}
		
		private function onProgres(e:ProgressEvent):void{
			dispatchEvent(new Event(PROGRESS_LOAD));
		}
		
		public function getContentGame():*{
			return _contentGame;
		}
		
		public function get bytesLoaded():Number {
			var loaded:Number = 0;
			for each(var item:LoadingItem in _items) {
				loaded += item.bytesLoaded;
			}
			return loaded;
		}
		public function get bytesTotal():Number {
			var total:Number = 0;
			for each(var item:LoadingItem in _items) {
				total += item.bytesTotal;
			}
			return total;
		}
		
		public function get isLoad():Boolean 
		{
			if (_items == null) return false;
			for each(var item:LoadingItem in _items) {
				if (item.bytesTotal == 0) return false;
			}
			return true;
		}
		
		public function get items():Vector.<LoadingItem> {return _items;}
		
		public function get isStartLoad():Boolean 
		{
			return _isStartLoad;
		}
	}
}