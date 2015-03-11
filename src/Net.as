package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Sah
	 */
	public class Net extends MovieClip
	{		
		public var sessionId:String;
		public var gameId:uint;
		public var terminalId:uint;
		public var version:String;
		public var unval:String = "";
		public var isOnline:Boolean;
		public var url:String = "";
		public var blockUrl:String = "";
		
		private var _uniq:uint;
		
		private var _timer:Timer;
		private var _errorCallback:Function;
		private var _stack:Vector.<NetRequest>
		
		public function Net() 
		{
			if (stage) {
				var params:Object = { };
				params.PHPSESSID = '37d671926946b25d31710617215a44b8';
				params.isOnline = false;
				params.url = "http://dc.kbelektron.ru/get_comb_v3.php";
				params.blockUrl = "https://://dc.kbelektron.ru/parts/flash_function_slots.php";
				params.gameId = 5067;
				params.terminalId = 1234;
				params.version = "'1.99F'";
				
				//init(params);
				//_uniq = 2;
				//unval = "b288afd3dda8f3ce815cc6abda9483d5";
				//bonusRequest(null);
			}
		}
		
		public function init(params:Object):void {
			sessionId = params.PHPSESSID;
			isOnline = params.isOnline;
			url = params.url;
			blockUrl = params.blockUrl;
			gameId = params.gameId;
			terminalId = params.terminalId;
			version = params.version;
			_uniq = 0;
			_stack = new Vector.<NetRequest>();
		}
		
		public function setErrorCallback(callback:Function):void {
			_errorCallback = callback;
		}
		
		public function startTimerSaveRequest(value:uint, saveCallBack:Function = null, blockCallBack:Function = null):void {
			_timer = new Timer(value);
			_timer.addEventListener(TimerEvent.TIMER, function tickHandler(e:TimerEvent):void 
			{
				saveRequest(saveCallBack);
				blockRequest(blockCallBack);
			});
			_timer.start();
		}
		
		public function stopTimerSaveRequest():void {
			if(_timer != null){
				_timer.stop();
				_timer = null;
			}			
		}
		
		public function initRequest(callBack:Function = null):void {
			var vars:URLVariables = new URLVariables();
			vars.id = 100;
			sendRequest(URLRequestMethod.GET, vars, function initComplete(answer:Object):void {
				unval = answer.unval;
				callBack(answer);
			});
		}
		
		public function blockRequest(callBack:Function = null):void {
			var vars:URLVariables = new URLVariables();
			vars.id = 102;
			vars.checkBlock = gameId - 5000;
			
			var request:URLRequest = new URLRequest();
			request.url = blockUrl;
			request.method = URLRequestMethod.POST;
			request.data = vars;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function requestCompleteHandler(e:Event):void {
				loader.removeEventListener(Event.COMPLETE, requestCompleteHandler);
				if (callBack != null) callBack(e.target.data != "OK");
			});
			loader.load(request);
		}
		
		public function startRequest(callBack:Function = null):void {
			var vars:URLVariables = new URLVariables();
			vars.id = 0;
			sendRequest(URLRequestMethod.GET, vars, callBack);
		}
		
		public function newRequest(params:Object, callBack:Function = null):void {
			var vars:URLVariables = new URLVariables();
			vars.id = 1;
			paramsToVariables(params, vars);
			sendRequest(URLRequestMethod.GET, vars, callBack);
		}
		
		public function stopRequest(callBack:Function = null):void
		{
			var vars:URLVariables = new URLVariables();
			vars.id = 101;
			sendRequest(URLRequestMethod.GET, vars, callBack);
		}
		
		public function saveWinRequest(callBack:Function = null):void
		{
			var vars:URLVariables = new URLVariables();
			vars.id = 4;
			sendRequest(URLRequestMethod.GET, vars, callBack);
		}
		
		public function saveRequest(callBack:Function = null):void
		{
			var vars:URLVariables = new URLVariables();
			vars.id = 5;
			sendRequest(URLRequestMethod.GET, vars, callBack);
		}
		
		public function bonusRequest(callBack:Function = null):void
		{
			var vars:URLVariables = new URLVariables();
			vars.id = 6;
			sendRequest(URLRequestMethod.GET, vars, callBack);
		}
		
		public function gambleRequest(callBack:Function = null):void
		{
			var vars:URLVariables = new URLVariables();
			vars.id = 10;
			sendRequest(URLRequestMethod.GET, vars, callBack);
		}
		
		public function sendRequest(method:String, vars:URLVariables, callBack:Function = null):void {
			vars.PHPSESSID = sessionId;
			vars.gameid = gameId;
			vars.terminalID = terminalId;
			vars.ver = version;
			vars.unval = unval;
			vars.uniq = _uniq;
			_uniq++;
			
			var request:URLRequest = new URLRequest();
			request.url = url;
			request.method = method;
			request.data = vars;
			
			_stack.push(new NetRequest(request, callBack));
			
			if(_stack.length == 1) loadRequest();
		}
		
		private function loadRequest():void {
			var req:NetRequest = _stack[0];
			trace ("Запрос: " + req.request.data);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, function requestErrorHandler(e:Event):void {
				trace("IO_ERROR");
				if (_errorCallback != null) _errorCallback(req.request.data.id);
			});
			loader.addEventListener(Event.COMPLETE, function requestCompleteHandler(e:Event):void {
				loader.removeEventListener(Event.COMPLETE, requestCompleteHandler);
				var answer:Object = getAnswer(e.target.data);
				trace("Ответ: ", JSON.stringify(answer));
				var keyCount:uint = 0;
				for (var key:String in answer) {
					keyCount++;
				}
				if (answer.hasOwnProperty("error") || keyCount == 0) {
					if(_errorCallback != null) {
						_errorCallback(req.request.data.id, answer);
					}
					return;
				}
				if (answer.hasOwnProperty("linesvalue") && answer.hasOwnProperty("lines")) {
					for (var i:uint = 0; i < answer.lines.length; i++) {
						if (answer.linesvalue[i + 1] == 0) answer.lines[i] = 0;
					}
				}
				if (req.callBack != null) req.callBack(answer);
				_stack.splice(0, 1);
				if (_stack.length != 0) loadRequest();
			});
			loader.load(req.request);
		}
		
		private function paramsToVariables(params:Object, vars:URLVariables):void {
			for (var key:String in params) {
				vars[key] = params[key];
			}
		}
		
		private function getAnswer(answer:String):Object 
		{
			var obj:Object = { };
			var arr:Array = answer.split(/[\n\r]/);
			for each(var par:String in arr) {
				var arr2:Array = par.split("=");
				if (arr2.length == 2) {
					var arr3:Array = arr2[1].split(";");
					if (arr3.length > 1) obj[arr2[0].toLowerCase()] = arr3;
					else obj[arr2[0].toLowerCase()] = arr2[1];
				}
			}
			return obj;
		}
		
	}

}
import flash.net.URLRequest;

class NetRequest
{
	private var _request:URLRequest;
	private var _callBack:Function;
	
	public function NetRequest(request:URLRequest, callBack:Function = null):void
	{
		_callBack = callBack;
		_request = request;
	}
	
	public function get callBack():Function {return _callBack;}
	public function get request():URLRequest {return _request;}
}