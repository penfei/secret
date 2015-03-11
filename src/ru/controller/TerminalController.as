package ru.controller 
{
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import ru.gui.terminal.TerminalView;
	import ru.utils.TextUtils;
	import sounds.button;
	import sounds.creditincrease;
	import sounds.creditincreasefast;
	import sounds.line1;
	import sounds.line3;
	import sounds.line5;
	import sounds.line7;
	import sounds.line9;
	import sounds.maxbet;
	/**
	 * ...
	 * @author Sah
	 */
	public class TerminalController 
	{
		private var _view:TerminalView;
		
		private var _saveTimer:Timer;
		private var _saveCallBack:Function;
		private var _saveCredits:Number;
		private var _visibleCredits:Number;
		private var _win:Number;
		private var _part:Number;
		
		public function TerminalController() 
		{
			_view = new TerminalView();
		}
		
		public function get view():TerminalView { return _view; }
		
		public function init():void {
			_view.betCallBack = maxBetClickHandler;
			_view.betOneCallBack = betClickHandler;
			_view.updateSpeed(Core.data.rollSpeed + 1);
			_view.updateSmooth(Core.data.isBlur ? 2 : 1);
			_view.updateSound(SoundController.volume == 0 ? 2 : 1);
			Core.ui.stage.addEventListener(KeyboardEvent.KEY_UP, keybordHandler);
			_view.lineCallBack = lineClickHandler;
			
			updateLines();
			updateBets();
			Core.ui.main.updateDen();
		}
		
		private function keybordHandler(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE && _view.startActivity) _view.startCallBack();
			if (e.keyCode == Keyboard.TAB && _view.helpActivity) {
				_view.helpCallBack();
			}
		}
		
		public function gameBlocked():void {
			_view.blockAll();
			Core.ui.main.disableDen();
		}
		
		public function blockAll():void {
			_view.blockAll();
			Core.ui.main.disableDen();
			if (Core.data.isAuto) {
				_view.unBlockStartAndAuto();
			}
		}
		
		public function normalMode():void {
			Core.data.isNormalState = !Core.data.isNotCorrectBet;
			_view.normalMode();
			_view.updateLinesButton(Core.data.activeLinesCount);
			
			Core.ui.main.winVisible = false;
			Core.ui.main.enableDen();
			Core.ui.main.updateInfo(1);
		}
		
		public function helpMode():void 
		{
			Core.ui.main.winVisible = false;
			Core.data.isNormalState = false;
			_view.helpMode();
		}
		
		public function winMode():void {
			Core.ui.main.disableDen();
			Core.data.isNormalState = false;
			_view.winMode();
			if (Core.data.isAuto) {
				_view.unBlockStartAndAuto();
				_view.blockHelp();
			}
			Core.ui.main.updateInfo(4);
			updateWinCredits(Core.data.visibleWinCredits);
		}
		
		public function gambleMode():void {
			Core.ui.main.winVisible = false;
			Core.data.isNormalState = false;
			_view.gambleMode();
		}
		
		public function winGambleMode():void {
			_view.winGambleMode();
		}
		
		public function jackpotMode():void {
			Core.ui.main.disableDen();
			_view.jackpotMode();
			//Core.ui.main.updateInfo("Jackpot!");
		}
		
		public function updateBoxBonusGameMode(boxes:Array):void 
		{
			_view.updateBoxBonusGameMode(boxes);
		}
		
		public function updateKeyBonusGameMode():void 
		{
			_view.updateKeyBonusGameMode(Core.data.hasSuperKey);
		}
		
		public function update():void {
			updateCredits(Core.data.credits);
		}
		
		public function updateWinCredits(credits:uint):void 
		{
			Core.ui.main.updateWinCredits(TextUtils.creditsToString(credits, Core.data.currentDenomination, true));
			Core.game.gamble.updateWinCredits(TextUtils.creditsToString(credits, Core.data.currentDenomination, true));
		}
		
		public function updateCredits(credits:uint):void {
			_visibleCredits = credits;
			Core.ui.main.updateCredits(credits);
			Core.game.gamble.updateCredits(TextUtils.creditsToString(credits, Core.data.currentDenomination, true));
			Core.game.bonus.updateCredits(TextUtils.creditsToString(credits, Core.data.currentDenomination, true));
		}
		
		public function updateLines():void {
			Core.game.lines.setLine(Core.data.activeLinesCount);
			Core.ui.main.updateLines(Core.data.activeLinesCount.toString());
			Core.ui.main.updateBets(TextUtils.paymentToString(Core.data.currentBet));
			Core.game.bonus.updateBets(TextUtils.paymentToString(Core.data.currentBet));
		}
		
		public function updateBets():void {
			Core.ui.main.updateBetsLine(TextUtils.formatString(Core.data.currentBetInLines.toString()));
			Core.ui.main.updateBets(TextUtils.paymentToString(Core.data.currentBet));
			Core.game.bonus.updateBets(TextUtils.paymentToString(Core.data.currentBet));
		}
		
		public function save(saveCallBack:Function):void 
		{
			Core.data.isSaveWin = true;
			SoundController.playBacksound(creditincrease);
			_saveCallBack = saveCallBack;
			_saveCredits = _visibleCredits;
			_win = Core.data.winCredits;
			if (Core.data.isJackpotWin) _win = Core.data.jackpotWin;
			_view.saveMode();
			Core.ui.main.disableDen();
			Core.ui.main.updateInfo(5);
			if (Core.data.isAuto) _view.unBlockStartAndAuto();
			updateWinCredits(_win);
			_part = Core.data.currentDenomination;
			if (_win < 1000) _part = _win / 10;
			
			_saveTimer = new Timer(50);
			_saveTimer.addEventListener(TimerEvent.TIMER, tickHandler);
			_saveTimer.start();
		}
		
		public function fastSave():void 
		{
			_view.blockAll();
			SoundController.playBacksound(creditincreasefast);
			if (Core.data.isAuto) _view.unBlockStartAndAuto();
			if (_win > 1000) _part = _win / 10;
		}
		
		public function newCombination():void 
		{
			Core.ui.main.updateInfo(Core.data.bonusGameBoxType ? 2 : 3);
			_view.rollMode();
		}
		
		private function tickHandler(e:TimerEvent):void 
		{
			var isEnd:Boolean = false;
			if(_part >= _win) {
				_saveTimer.stop();
				_part = _win;
				isEnd = true;
			}
			_win -= _part;
			_saveCredits += _part;
			updateWinCredits(_win);
			updateCredits(_saveCredits);
			
			if (isEnd) {
				SoundController.stopBacksound();
				Core.data.isSaveWin = false;
				_saveCallBack();
			}
		}
		
		public function lineClickHandler(lineNum:uint):void 
		{
			if (Core.ui.helpPopup.isShow) {
				if (lineNum == 1) Core.ui.helpPopup.previous();
				if (lineNum == 9) Core.ui.helpPopup.next();
				SoundController.playSound(button);
				return;
			}
			if (Core.data.bonusGameType != 0) {
				Core.game.bonus.lineClick(lineNum);
				return;
			}
			if (Core.data.isGamble) {
				Core.game.gamble.choiceCard(lineNum);
				SoundController.playSound(button);
				return;
			}
			if (lineNum == 1) SoundController.playSound(line1);
			if (lineNum == 3) SoundController.playSound(line3);
			if (lineNum == 5) SoundController.playSound(line5);
			if (lineNum == 7) SoundController.playSound(line7);
			if (lineNum == 9) SoundController.playSound(line9);
			Core.data.activeLinesCount = lineNum;
			if (Core.data.isNotCorrectBet) searchMaxBet();
			else updateLines();
			normalMode();
			Core.ui.jackpot.update();
		}
		
		private function betClickHandler():void 
		{
			if (Core.data.isWin) {
				Core.game.gamble.start();
				return;
			}
			SoundController.playSound(button);
			if (Core.data.currentBetIndex < DataController.BETS.length - 1) Core.data.currentBetIndex++;
			else Core.data.currentBetIndex = 0;
			if (Core.data.isNotCorrectBet) Core.data.currentBetIndex = 0;
			updateBets();
			normalMode();
			Core.ui.jackpot.update();
		}
		
		private function maxBetClickHandler():void 
		{
			if (Core.data.isWin) {
				Core.game.gamble.start();
				return;
			}
			SoundController.playSound(maxbet);
			searchMaxBet();
			normalMode();
		}
		
		public function searchMaxBet():void {
			Core.data.searchMaxBet();
			updateLines();
			updateBets();
			Core.ui.main.updateDen();
			update();
			if(Core.ui.jackpot != null) Core.ui.jackpot.update();
		}
		
		public function updateFullScreen(frame:Number):void 
		{
			_view.updateFullScreen(frame);
		}
	}

}