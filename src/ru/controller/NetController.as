package ru.controller {
	import flash.display.MovieClip;

	public class NetController {
		private var _net:MovieClip;
		private var _complete:Function;

		public function NetController(params:Object) {
			_net = params.net;
			_complete = params.complete;
			_net.setErrorCallback(errorCallbak);
			_net.init(params);
		}
		
		private function errorCallbak(requestId:uint, answer:Object = null):void {
			trace(JSON.stringify(answer));
			error();
		}
		
		public function error():void {
			if(!Core.data.isClosed){
				Core.ui.showErrorPopup();
				_complete();
			}
		}
		
		public function init():void {
			_net.startTimerSaveRequest(30000, saveRequestCallBack, blockComplete);
			_net.blockRequest(blockComplete);
		}
		
		private function blockComplete(isBlocked:Boolean):void 
		{
			Core.data.isBlocked = isBlocked;
			if (Core.data.isBlocked && Core.data.winCredits == 0) {
				Core.ui.showErrorPopup();
			}
		}
		
		private function saveRequestCallBack(answer:Object):void 
		{
			trace("Timer: ", JSON.stringify(answer));
			Core.data.update(answer);
			if (!Core.data.isJackpotWin && !Core.data.isWin) Core.terminal.update();
		}
		
		public function initRequest(callBack:Function = null):void {
			_net.initRequest(callBack);
		}
		
		public function startRequest(callBack:Function = null):void {
			_net.startRequest(callBack);
		}
		
		public function newRequest(params:Object, callBack:Function = null):void {
			_net.newRequest(params, callBack);
		}
		
		public function stopRequest(callBack:Function = null):void
		{
			_net.stopRequest(callBack);
		}
		
		public function saveRequest(callBack:Function = null):void
		{
			_net.saveRequest(callBack);
		}
		
		public function saveWinRequest(callBack:Function = null):void
		{
			_net.saveWinRequest(callBack);
		}
		
		public function bonusRequest(callBack:Function = null):void
		{
			_net.bonusRequest(callBack);
		}
		
		public function gambleRequest(callBack:Function = null):void
		{
			_net.gambleRequest(callBack);
		}
		
		public function get isOnline():Boolean {return _net.isOnline;}

	}
}
