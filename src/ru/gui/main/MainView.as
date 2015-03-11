package ru.gui.main 
{
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import fonts.CreditsFont;
	import fonts.PrizesFont;
	import ru.controller.Core;
	import ru.gui.View;
	import ru.utils.TextUtils;
	import symbols.MainViewUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class MainView extends View
	{
		private var _ui:MainViewUI;
		private var _credits:FontView;
		private var _bet:FontView;
		private var _line:FontView;
		private var _win:FontView;
		private var _winInfo:FontView;
		
		private var _keyCallBack:Function;
		private var _keyTimer:Timer;
		
		public function MainView() 
		{
			_ui = new MainViewUI;
			addChild(_ui);
			_ui.y = 26;
			
			_credits = new FontView(CreditsFont, "0", false, 10);
			_ui.addChild(_credits);
			_credits.x = 595;
			_credits.y = 7;
			
			_bet = new FontView(CreditsFont, "0", false, 15);
			_ui.addChild(_bet);
			_bet.x = 177;
			_bet.y = 7;
			
			_line = new FontView(CreditsFont, "0", false, 1);
			_ui.addChild(_line);
			_line.x = 347;
			_line.y = 7;
			
			_win = new FontView(CreditsFont, "0", false, 10);
			_ui.addChild(_win);
			_win.x = 385;
			_win.y = 7;
			
			_winInfo = new FontView(PrizesFont, "0", true, 10);
			_ui.states.state6.addChild(_winInfo);
			_winInfo.x = 60;
			_winInfo.y = 20;
			
			stopRollAnimation();
			
			_keyTimer = new Timer(200, 5);
			_keyTimer.addEventListener(TimerEvent.TIMER, keyTimerTickHandler);
			_keyTimer.addEventListener(TimerEvent.TIMER_COMPLETE, keyTimerCompleteHandler);
			
			_ui.den.buttonMode = true;
			_ui.den.mouseChildren = false;
			_ui.den.y += 26;
			_ui.den.addEventListener(MouseEvent.CLICK, denClickHandler);
			
			_ui.creditClick.y += 26;
			_ui.creditClick.addEventListener(MouseEvent.MOUSE_OVER, creditOverHandler);
			_ui.creditClick.addEventListener(MouseEvent.MOUSE_OUT, creditOutHandler);
			
			winVisible = false;
			_ui.credits.visible = false;
		}
		
		private function creditOutHandler(e:MouseEvent):void 
		{
			_ui.credits.visible = false;
		}
		
		private function creditOverHandler(e:MouseEvent):void 
		{
			_ui.credits.visible = true;
		}
		
		public function get den():MovieClip {
			return _ui.den;
		}
		
		public function get creditClick():MovieClip {
			return _ui.creditClick;
		}
		
		private function keyTimerCompleteHandler(e:TimerEvent):void 
		{
			_ui.states.state7.stop();
			//_keyCallBack();
		}
		
		private function keyTimerTickHandler(e:TimerEvent):void 
		{
			if (!Core.data.hasSuperKey) {
				if (_ui.states.state7.currentFrame == Core.data.keyCount * 2) _ui.states.state7.gotoAndStop(Core.data.keyCount * 2 - 1);
				else _ui.states.state7.gotoAndStop(Core.data.keyCount * 2);
			}
		}
		
		public function playRollAnimation():void {
			for (var i:uint = 0; i < _ui.bars.numChildren; i++) {
				(_ui.bars.getChildAt(i) as MovieClip).gotoAndPlay(1);
			}
		}
		
		public function stopRollAnimation():void {
			for (var i:uint = 0; i < _ui.bars.numChildren; i++) {
				(_ui.bars.getChildAt(i) as MovieClip).gotoAndStop(1);
			}
		}
		
		public function updateBetsLine(label:String):void {
			_ui.betLine1.text = label;
			_ui.betLine2.text = label;
		}
		
		public function updateCredits(credits:uint):void {
			_credits.text = TextUtils.creditsToString(credits, Core.data.currentDenomination, true);
			_ui.credits.label.text = TextUtils.creditsToString(credits, 100, false, false) + " " + Core.data.valute;
		}
		
		public function updateBets(label:String):void {
			_bet.text = label;
		}
		
		public function updateWinCredits(label:String):void {
			winVisible = true;
			_win.text = label;
		}
		
		public function updateLines(label:String):void {
			winVisible = false;
			_line.text = label;
		}
		
		public function set visibleDen(value:Boolean):void {
			_ui.den.visible = value;
		}
		
		public function enableDen():void {
			_ui.den.mouseEnabled = true;
			
			updateDen();
		}
		
		public function set winVisible(value:Boolean):void {
			_ui.win.visible = value;
			_win.visible = value;
			_line.visible = !value;
		}
		
		public function disableDen():void {
			_ui.den.mouseEnabled = false;
			
			updateDen();
		}
		
		public function updateDen():void 
		{
			_ui.den.label.text = "1 CREDIT = " + String(Core.data.currentDenomination / 100) + " " + Core.data.valute;
		}
		
		private function denClickHandler(e:MouseEvent):void 
		{
			Core.data.currentDeniminationIndex++;
			if (Core.data.currentDeniminationIndex >= Core.data.denominations.length) Core.data.currentDeniminationIndex = 0;
			
			trace(Core.data.isNotCorrectBet);
			if (Core.data.isNotCorrectBet) Core.terminal.searchMaxBet();
			else {	
				Core.terminal.update();
				updateDen();
			}
		}
		
		public function updateInfo(state:uint):void 
		{
			for (var i:uint = 0; i < _ui.states.numChildren; i++) {
				_ui.states.getChildAt(i).visible = false;
			}
			_ui.states["state" + state.toString()].visible = true;
		}
		
		public function showLine(lineIndex:uint, win:uint):void 
		{
			updateInfo(6);
			_ui.states.state6.line.gotoAndStop(lineIndex + 1);
			_winInfo.text = TextUtils.creditsToString(win, Core.data.currentDenomination, true);
		}
		
		public function showKey(callBack:Function = null):void 
		{
			//_keyCallBack = callBack;
			updateInfo(7);
			_ui.states.state7.gotoAndStop(1);
			if (Core.data.hasSuperKey) _ui.states.state7.gotoAndPlay(1);
			_keyTimer.reset();
			_keyTimer.start();
		}
		
		public function showKeyGame(callBack:Function = null):void 
		{
			updateInfo(3);
		}
		
		public function showBoxGame(callBack:Function = null):void 
		{
			//_keyCallBack = callBack;
			updateInfo(2);
			//_keyTimer.reset();
			//_keyTimer.start();
		}
		
	}

}