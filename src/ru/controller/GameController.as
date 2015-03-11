package ru.controller 
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import sounds.boxscetterwin;
	import sounds.keynewkey;
	import sounds.keynewsuperkey;
	/**
	 * ...
	 * @author Sah
	 */
	public class GameController 
	{		
		private var _lines:LinesController;
		private var _rolls:RollsController;
		private var _gamble:GambleController;
		private var _bonus:BonusController;
		
		private var _timeoutId:uint;
		
		public function GameController(params:Object) 
		{
			_lines = new LinesController(params);
			_rolls = new RollsController();
			_gamble = new GambleController();
			_bonus = new BonusController();
		}
		
		public function get lines():LinesController { return _lines; }
		public function get rolls():RollsController {return _rolls;}
		public function get gamble():GambleController { return _gamble; }
		public function get bonus():BonusController { return _bonus; }
		
		public function init():void 
		{
			_lines.init();
			_rolls.init();
			_gamble.init();
			_bonus.init();
			
			Core.terminal.view.startCallBack = startClick;
			Core.terminal.view.autoCallBack = auto;
			_rolls.createRoll(Core.data.iconsCombination);
			rollsComplete();
		}
		
		private function startClick():void {
			if (Core.data.isAuto) {
				auto();
				return;
			}
			start();
		}
		
		public function resetAuto():void {
			Core.data.isAuto = false;
			clearTimeout(_timeoutId);
		}
		
		public function start():void {
			Core.ui.animation.resetAnimationTimer();
			clearTimeout(_timeoutId);
			_lines.linesCompleteCallback = null;
			if (Core.ui.isShowJackpot) {
				Core.ui.jackpotPopup.hide();
				if (Core.data.isWin) Core.terminal.save(saveComplete);
				else Core.net.saveWinRequest(saveRequestComplete);
				return;
			}
			if (Core.ui.helpPopup.isShow) {
				Core.ui.helpPopup.activate();
				return;
			}
			if (Core.data.isSaveWin) {
				Core.terminal.fastSave();
				return;
			}
			Core.terminal.blockAll();
			if (Core.data.isGamble) _gamble.close();
			_lines.winOff();
			_rolls.stopAllAnimations();
			if (Core.data.isWin) Core.net.saveWinRequest(saveRequestComplete);
			else {
				if (!Core.data.isNotCorrectBet) newCombination();
				else Core.terminal.normalMode();
			}
		}
		
		private function auto():void 
		{
			Core.data.isAuto = !Core.data.isAuto;
			
			if (Core.data.isAuto) {
				if (!Core.data.isRolled) start();
			}
			if (!Core.data.isAuto) {
				clearTimeout(_timeoutId);
				if (Core.data.isRolled || Core.data.isShowWin) Core.terminal.view.blockStartAndAuto();
			}
		}
		
		private function saveRequestComplete(answer:Object):void 
		{
			trace("Save: ", JSON.stringify(answer));
			Core.terminal.save(saveComplete);
			if (Core.data.isAuto) Core.terminal.fastSave();
			
			Core.data.update(answer);
			Core.ui.jackpot.update();
		}
		
		private function saveComplete():void 
		{
			if (Core.data.isBlocked) {
				Core.terminal.gameBlocked();
				return;
			}
			if (Core.data.isNotCorrectBet) {
				Core.terminal.searchMaxBet();
			}
			if (!Core.data.isJackpotWin) {
				_lines.setLine(Core.data.activeLinesCount);
				_rolls.stopAllAnimations();
				Core.data.saveWinComplete();
				Core.terminal.normalMode();
			} else {
				Core.data.saveJackpotComplete();
				afterRollsComplete();
			}
			
			if (Core.data.isGamble) {
				if (Core.data.isAuto) _gamble.close(start);
				else _gamble.close();
			}
			else if (Core.data.isAuto) start();
		}
		
		private function newCombination():void {
			Core.terminal.newCombination();
			Core.data.newCombination();
			_rolls.startRoll(Core.data.iconsCombination);
			Core.ui.main.playRollAnimation();
			Core.net.newRequest(Core.data.getParamsFromNewRequest(), newCombinationComplete);
		}
		
		private function newCombinationComplete(answer:Object):void 
		{
			trace("New Comb: ", JSON.stringify(answer));
			//if(!Core.data.isFreeGames){
				//answer.credit = 500;
				//answer.comb[0] = DataController.SCETTER;
				//answer.comb[11] = DataController.SCETTER;
				//answer.comb[12] = DataController.SCETTER;
				//answer.comb[13] = DataController.SCETTER;
				//answer.comb[4] = DataController.SCETTER;
				//answer.bonus = 1;
				//answer.bonustype = 2;
				//answer.win = 5400;
				//answer.nospin = 1;
				//answer.lines = [24, 28, 31, 24, 28, 28, 31, 28, 24];
				//answer.linesvalue = [0, 3000, 2400, 0, 0, 0, 0, 0, 0, 0];
				//answer.lines = [28, 28, 0, 0, 0, 0, 0, 0, 0];
				//answer.linesvalue[0] = 9;
			//}
			Core.data.update(answer);
			Core.ui.jackpot.update();
			Core.terminal.update();
			_rolls.finishRoll(Core.data.iconsCombination, rollsComplete);
		}
		
		private function rollsComplete():void 
		{
			Core.terminal.blockAll();
			Core.ui.main.stopRollAnimation();
			if (Core.data.isJackpotWin) {
				resetAuto();
				Core.ui.jackpotPopup.show();
				Core.terminal.jackpotMode();
				return;
			}
			afterRollsComplete();
		}
		
		private function afterRollsComplete():void {
			if (Core.data.isNotCorrectBet) {
				if (!Core.data.isWin) Core.terminal.searchMaxBet();
				resetAuto();
			}
			if (Core.data.newBonusGames) {
				resetAuto();
			}
			if (Core.data.isWin || Core.data.newBonusGames) {
				Core.ui.animation.winState();
				_lines.winOn(Core.data.linesCombination, Core.data.winLines, onLineComplete);
				_lines.linesCompleteCallback = linesComplete;
			} else linesComplete();
		}
		
		private function onLineComplete(lineIndex:uint):void 
		{
			if (Core.data.isFirstPlayWin && !Core.ui.isShowJackpot && !Core.data.isSaveWin && (Core.data.isWin || Core.data.newBonusGames)  && !Core.data.isGamble) {
				if (lineIndex == 0) {
					if(Core.data.isKeyWin){
						Core.data.keyCount = Core.data.winLines[lineIndex];
						if (Core.data.hasSuperKey) SoundController.playSound(keynewsuperkey, linesComplete);
						else SoundController.playSound(keynewkey, linesComplete);
						Core.ui.main.showKey();
					} else if (Core.data.isKeyBonusGame) {
						SoundController.playSound(keynewsuperkey, linesComplete);
						Core.ui.main.showKeyGame();
					} else {
						Core.ui.main.showBoxGame();
						SoundController.playSound(boxscetterwin, linesComplete);
					}
				} else {
					SoundController.playWinSound(lineIndex);
					Core.data.visibleWinCredits += Number(Core.data.winLines[lineIndex]);
					Core.terminal.updateWinCredits(Core.data.visibleWinCredits);
					Core.ui.main.showLine(lineIndex, Core.data.winLines[lineIndex]);
				}
			}
		}
		
		private function linesComplete():void {
			Core.data.isShowWin = false;
			if (Core.data.newBonusGames) {
				_bonus.startBonusGame();
				return;
			}
			if (Core.data.isAuto) {
				_timeoutId = setTimeout(autostart, 2000);
			} 
			if (Core.data.isWin) {
				Core.terminal.winMode();
				Core.data.visibleWinCredits = 0;
			} else if(!Core.data.isAuto) Core.terminal.normalMode();
		}
		
		private function autostart():void {
			if (!Core.data.isGamble) start();
		}
	}

}