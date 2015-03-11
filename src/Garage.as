package 
{
	import com.drivecasino.global.CONTENT;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import ru.controller.Core;
	import ru.controller.DataController;
	import ru.controller.GameController;
	import ru.controller.NetController;
	import ru.controller.SoundController;
	import ru.controller.TerminalController;
	import ru.controller.UIController;
	import ru.gui.View;
	import ru.preloader.ContentDownloader;
	
	/**
	 * ...
	 * @author Sah
	 */
	[SWF(width='640', height='600', backgroundColor="0x000000", frameRate="24")]
	public class Garage extends Sprite 
	{
		private var _canvas:View;
		
		public function Garage():void 
		{
			if (stage) {
				var params:Object = { };
				params.PHPSESSID = ProxyData.SESSION_ID;
				params.lang = "ru";
				params.full = 1;
				params.isOnline = false;
				params.valute = 'DCC';
				params.url = ProxyData.URL + "/get_comb_v3.php";
				params.systemUrl = ProxyData.URL;
				params.blockUrl = ProxyData.BLOCK_URL;
				params.stage = stage;
				params.volume = 0;
				params.rolls_smoothing = 0;
				params.speed = 0;
				params.game_logo = "DC";
				
				var downloader:ContentDownloader = new ContentDownloader(params, init, "../../", "../../../net/", "../../../_lines/", "view1.swf");
			}
		}
		
		public function init(params:Object):void {
			params.gameId = 5067;
			params.terminalId = 1234;
			params.version = "'1.99F'";
			params.complete = compeleteRequests;
			
			_canvas = new View;
			addChild(_canvas);
			
			Core.game = new GameController(params);
			Core.terminal = new TerminalController();
			Core.net = new NetController(params);
			Core.data = new DataController(params);
			Core.ui = new UIController(_canvas, params);
			SoundController.init(params);
			
			Core.net.initRequest(initCompleteHandler);
		}
		
		private function initCompleteHandler(answer:Object):void {
			trace("Init: ", JSON.stringify(answer));
			if (answer.gameid == "-1" || answer.gameid == Core.data.gameId) {
				Core.data.init(answer);
				Core.net.startRequest(startCompleteHandler);
			} else Core.net.error();
		}
		
		private function startCompleteHandler(answer:Object):void {
			trace("Start: ", JSON.stringify(answer));
			answer.jpwins = [0, 0, 0, 0];
			Core.data.update(answer);
			Core.terminal.init();
			Core.game.init();
			Core.ui.init();
			Core.net.init();
			
			Core.terminal.update();
			
			compeleteRequests();
		}
		
		private function compeleteRequests():void {
			if(!Core.data.isStart){
				dispatchEvent(new Event(Event.COMPLETE));
				Core.data.isStart = true;
			}
		}
		
	}
	
}