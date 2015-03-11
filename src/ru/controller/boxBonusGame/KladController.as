package ru.controller.boxBonusGame 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import fonts.KladFont;
	import ru.controller.Core;
	import ru.controller.SoundController;
	import ru.gui.main.FontView;
	import ru.gui.View;
	import ru.utils.TextUtils;
	import sounds.boxfull1;
	import sounds.boxfull2;
	import sounds.creditincrease;
	import symbols.KladBoxUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class KladController extends View
	{
		private var _winView:FontView;
		private var _boxes:Vector.<KladBoxUI>;
		private var _boxCount:uint = 0;
		private var _id:uint;
		private var _win:Number;
		private var _bet:Number;
		private var _callBack:Function;
		
		public function KladController(id:uint) 
		{
			_id = id;
			_winView = new FontView(KladFont, "0", false, 15);
			_winView.x = 41;
			addChild(_winView);
			
			_boxes = new Vector.<KladBoxUI>;
			for (var i:uint = 0; i < 5; i++) {
				var box:KladBoxUI = new KladBoxUI;
				if (i == 0) box.gotoAndStop(id + 2);
				box.y = 124 - 24 * i;
				addChild(box);
				_boxes.push(box);
			}
		}
		
		public function init(boxCount:uint, win:Number, bet:Number):void 
		{
			_bet = bet;
			_win = win;
			
			_winView.text = TextUtils.creditsToString(_win, Core.data.currentDenomination, true);
			
			_boxCount = boxCount;
			
			updateBoxes();
		}
		
		public function next():void 
		{
			if (_boxCount <= 5) {
				_win += _bet * (_id + 2);
				_winView.text = TextUtils.creditsToString(_win, Core.data.currentDenomination, true);
				
				_boxCount++;
				
				updateBoxes();
			}			
		}
		
		public function doComplete(callBack:Function):void 
		{
			_callBack = callBack;
			SoundController.playSound(boxfull1, full1Complete);
		}
		
		private function full1Complete():void 
		{
			SoundController.playSound(boxfull2, full2Complete);
		}
		
		private function full2Complete():void 
		{
			var timer:Timer = new Timer(100);
			var step:Number = 1;
			var modificator:int = int(_winView.text);
			SoundController.playBacksound(creditincrease);
			timer.addEventListener(TimerEvent.TIMER, function timerCompleteHandler(e:TimerEvent):void {
				_winView.text = String(int(_winView.text) - int(step));
				if (timer.delay > 20) timer.delay -= 5;
				if (timer.delay <= 20) step *= 1.05;
				if (int(_winView.text) <= 0) {
					SoundController.stopBacksound();
					timer.removeEventListener(TimerEvent.TIMER, timerCompleteHandler);
					_win = 0;
					_winView.text = "0";
					_boxCount = 0;
					updateBoxes();
					Core.data.visibleWinCredits += modificator;
					Core.game.bonus.updateWin(Core.data.visibleWinCredits);
					_callBack();
				} else Core.game.bonus.updateWin(Core.data.visibleWinCredits + modificator - int(_winView.text));
			});
			timer.start();
		}
		
		public function get isComplete():Boolean 
		{
			return _boxCount >= _boxes.length;
		}
		
		private function updateBoxes():void 
		{
			for (var i:uint = 0; i < _boxes.length; i++) {
				_boxes[i].visible = i < _boxCount;
			}
		}
		
	}

}