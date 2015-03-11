package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	import ru.preloader.ContentDownloader;
	import symbols.PreloaderUI;
	/**
	 * ...
	 * @author Sah
	 */
	[SWF(width='640', height='600', backgroundColor="0x000000", frameRate="24")]
	public class Preloader extends Sprite
	{
		private var _isOnline:Boolean = false;
		private var _downloader:ContentDownloader;
		private var _main:*;
		private var _lines:PreloaderLines;
		private var _ui:PreloaderUI;
		
		public function Preloader() 
		{
			var params:Object = this.loaderInfo.parameters;
			if (params.PHPSESSID) {
				params.isOnline = true;
				params.url = "/get_comb_v3.php";
				params.systemUrl = "";
				params.blockUrl = "/parts/flash_function_slots.php";
			} else {
				params.PHPSESSID = ProxyData.SESSION_ID;
				params.lang = "en";
				params.full = 1;
				params.isOnline = false;
				params.valute = 'JP';
				params.url = ProxyData.URL + "/get_comb_v3.php";
				params.systemUrl = ProxyData.URL;
				params.blockUrl = ProxyData.BLOCK_URL;
				params.volume = 50;
				params.rolls_smoothing = 1;
				params.speed = 2;
			}
			
			_lines = new PreloaderLines();
			addChild(_lines);
			
			_ui = new PreloaderUI();
			addChild(_ui);
			_ui.panel.gotoAndStop(0);
			if(params.isOnline) _downloader = new ContentDownloader(params, init, "create/garage/", "create/_net/", "create/_lines/", "view1.swf");
			else _downloader = new ContentDownloader(params, init, "create/garage/", "create/net/", "create/_lines/", "view1.swf");
			addEventListener(Event.ENTER_FRAME, loadHandler);
		}
		
		private function loadHandler(e:Event):void 
		{
			if (_downloader.isStartLoad) {
				var percent:uint = (_downloader.bytesLoaded / _downloader.bytesTotal) * 100;
				_ui.panel.gotoAndStop(percent);
				//trace(percent);
				//_preloader.label.text = percent.toString() + "%";
			}
		}
		
		public function init(params:Object, isOnline:Boolean = true):void {
			removeEventListener(Event.ENTER_FRAME, loadHandler);
			
			_main = params.mainSWF;
			params.stage = stage;
			_main.addEventListener(Event.COMPLETE, initCompleteHandler);
			_main.init(params);
		}
		
		private function initCompleteHandler(e:Event):void 
		{
			_lines.destroy();
			removeChildren();
			addChild(_main);
		}
		
	}

}