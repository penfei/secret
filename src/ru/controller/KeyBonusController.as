package ru.controller 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import fonts.ModificatorFont;
	import fonts.SuperFont;
	import ru.gui.main.FontView;
	import ru.utils.TextUtils;
	import sounds.creditincrease;
	import sounds.keyarrows;
	import sounds.keybox;
	import sounds.keygarageopen;
	import sounds.keylock;
	import sounds.keyopenwin;
	import sounds.keysuperuse;
	import sounds.keysuperwin;
	import symbols.KeyBonusUI;
	import symbols.SuperCarGameUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class KeyBonusController 
	{
		private var _ui:KeyBonusUI;
		private var _modificators:Array;
		private var _raundCount:uint;
		private var _modificatorCount:uint;
		private var _isWin:Boolean = true;
		private var _boxTexts:Vector.<FontView>;
		private var _superKeyRaund:int;
		private var _superUI:SuperCarGameUI;
		private var _superText:FontView;
		
		public function KeyBonusController() 
		{
			
		}
		
		public function init():void 
		{
			_ui = new KeyBonusUI;
			_ui.visible = false;
			
			_superUI = new SuperCarGameUI;
			_ui.addChild(_superUI);
			
			_superText = new FontView(SuperFont, "0", false, 15);
			_superText.x = 155;
			_superText.y = -3;
			_superUI.label.addChild(_superText);
			
			_boxTexts = new Vector.<FontView>;
			for (var i:uint = 0; i < 5; i++) {
				var font:FontView = new FontView(ModificatorFont, "0", true, 15);
				_ui["box" + String(i)].addChild(font);
				font.x = 3;
				font.y = 3;
				_boxTexts.push(font);
			}
			
			_ui.boxes.clickLeft.mouseChildren = _ui.boxes.clickRight.mouseChildren = _ui.superKey.mouseChildren = false;
			_ui.boxes.clickLeft.buttonMode = _ui.boxes.clickRight.buttonMode = _ui.superKey.buttonMode = true;
			
			_ui.boxes.clickRight.addEventListener(MouseEvent.CLICK, rightClickHandler);
			_ui.boxes.clickLeft.addEventListener(MouseEvent.CLICK, leftClickHandler);
			_ui.superKey.addEventListener(MouseEvent.CLICK, keyClickHandler);
		}
		
		public function useSuperKey():void {
			SoundController.stopBacksound();
			SoundController.playSound(keysuperuse);
			_ui.arrows.visible = false;
			_ui.lines.visible = false;
			_ui.superKey.visible = false;
			Core.terminal.view.blockAll();
			
			Core.data.keyCount = 0;
			_superKeyRaund = _raundCount;
			_raundCount++;
			
			setTimeout(startLock, 1000);
		}
		
		public function choiceBox(box:uint):void {
			SoundController.stopBacksound();
			SoundController.playSound(keybox);
			Core.terminal.view.blockAll();
			_ui.boxes.clickLeft.mouseEnabled = _ui.boxes.clickRight.mouseEnabled = false;
			
			_ui.arrows.visible = false;
			_ui.lines.visible = false;
			var view:MovieClip = box == 0 ? _ui.boxes.left: _ui.boxes.right;
			_isWin = uint(_modificators[_modificatorCount]) > 0;
			view.win.visible = _isWin;
			view.loss.visible = !_isWin;
			if (_isWin) {
				view.win.gotoAndPlay(1);
				view.win.addEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
			} else {
				view.loss.gotoAndPlay(1);
				view.loss.addEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
			}
			
			_boxTexts[_raundCount].text = String(_modificators[_modificatorCount]);
			_modificatorCount++;
			_raundCount++;
		}
		
		private function animationCompleteHandler(e:Event):void 
		{
			e.target.removeEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
			
			if (_isWin) {
				SoundController.playSound(keyopenwin);
				setTimeout(startLock, 1000);
			} else {
				SoundController.playBacksound(creditincrease);
				modificatorsAnimation(Core.game.bonus.endGame);
			}			
		}
		
		private function startLock():void 
		{
			SoundController.stopSound(keyopenwin);
			SoundController.stopSound(keysuperuse);
			SoundController.playSound(keylock);
			_ui["lock" + String(_raundCount - 1)].gotoAndPlay(1);
			_ui["lock" + String(_raundCount - 1)].addEventListener("ANIMATION_COMPLETE", lockCompleteHandler);
		}
		
		private function lockCompleteHandler(e:Event):void 
		{
			SoundController.stopSound(keylock);
			
			e.target.removeEventListener("ANIMATION_COMPLETE", lockCompleteHandler);
			
			newRaund();
		}
		
		public function close(callBack:Function = null):void 
		{
			_ui.visible = false;
			if(callBack != null) callBack();
		}
		
		public function startBonusGame(answer:Object):void 
		{			
			_modificators = answer.linesvalue;
			_raundCount = 0;
			_modificatorCount = 0;
			_superKeyRaund = -1;
			_superUI.visible = false;
			_superUI.gotoAndStop(1);
			
			_ui.visible = true;
			
			newRaund();
		}
		
		private function modificatorsAnimation(callBack:Function = null):void {
			for (var i:uint = 0; i < _boxTexts.length; i++) {
				if (i == _superKeyRaund) {
					_ui["box" + String(i)].visible = false;
					_ui.key.visible = false;
				}
				if (_boxTexts[i].visible) {
					startModificatorAnimation(i, callBack);
					return;
				}
			}
			SoundController.stopBacksound();
			if (callBack != null) callBack();
		}
		
		private function startModificatorAnimation(index:uint, callBack:Function):void 
		{
			var timer:Timer = new Timer(100);
			var step:Number = 1;
			var modificator:int = int(_boxTexts[index].text);
			timer.addEventListener(TimerEvent.TIMER, function timerCompleteHandler(e:TimerEvent):void {
				_boxTexts[index].text = String(int(_boxTexts[index].text) - int(step));
				if (timer.delay > 20) timer.delay -= 5;
				if (timer.delay <= 20) step *= 1.05;
				if (int(_boxTexts[index].text) <= 0) {
					timer.removeEventListener(TimerEvent.TIMER, timerCompleteHandler);
					_boxTexts[index].visible = false;
					_ui["box" + String(index)].visible = false;
					Core.data.visibleWinCredits += modificator * Core.data.currentBet;
					Core.game.bonus.updateWin(Core.data.visibleWinCredits);
					modificatorsAnimation(callBack);
				} else Core.game.bonus.updateWin(int(Core.data.visibleWinCredits + (Core.data.currentBet * (modificator - int(_boxTexts[index].text)))));
			});
			timer.start();
		}
		
		private function newRaund():void {
			for (var i:uint = 0; i < 5; i++) {
				_ui["lock" + String(i)].visible = i >= _raundCount;
				_ui["lock" + String(i)].gotoAndStop(1);
				_boxTexts[i].visible =  _ui["box" + String(i)].visible = i < _raundCount;
			}
			
			_ui.superKey.visible = Core.data.hasSuperKey;
			_ui.key.visible = _superKeyRaund != -1;
			if (_superKeyRaund != -1) {
				_ui.key.x = _ui["box" + String(_superKeyRaund)].x + 4;
				_ui.key.y = _ui["box" + String(_superKeyRaund)].y + 6;
				_boxTexts[_superKeyRaund].visible = false;
			} 
			
			if (_raundCount == 5) {
				_ui.arrows.visible = false;
				_ui.lines.visible = false;
				_ui.boxes.visible = false;
				_ui.superKey.visible = false;
				SoundController.playBacksound(creditincrease);
				modificatorsAnimation(function complete():void {
					_superUI.visible = true;
					_superText.visible = true;
					_superUI.gotoAndPlay(1);
					_superUI.label.gotoAndStop(1);
					SoundController.playSound(keygarageopen, superCompleteHandler);
					_superText.text = TextUtils.creditsToString(_modificators[5], Core.data.currentDenomination, true)
				});
				return;
			}
			SoundController.playBacksound(keyarrows);
			_ui.arrows.visible = true;
			_ui.lines.visible = true;
			_ui.boxes.visible = true;
			_ui.boxes.left.win.visible = true;
			_ui.boxes.right.win.visible = true;
			_ui.boxes.left.loss.visible = false;
			_ui.boxes.right.loss.visible = false;
			_ui.boxes.left.loss.gotoAndStop(1);
			_ui.boxes.left.win.gotoAndStop(1);
			_ui.boxes.right.loss.gotoAndStop(1);
			_ui.boxes.right.win.gotoAndStop(1);
			
			if (_raundCount == 0) {
				_ui.boxes.y = 266;
				_ui.arrows.y = 316;
				_ui.lines.y = 243;
			} else if (_raundCount == 1) {
				_ui.boxes.y = 239;
				_ui.arrows.y = 268;
				_ui.lines.y = 323;
			} else if (_raundCount == 2) {
				_ui.boxes.y = 191;
				_ui.arrows.y = 220;
				_ui.lines.y = 275;
			} else if (_raundCount == 3) {
				_ui.boxes.y = 143;
				_ui.arrows.y = 172;
				_ui.lines.y = 227;
			} else if (_raundCount == 4) {
				_ui.boxes.y = 95;
				_ui.arrows.y = 124;
				_ui.lines.y = 179;
			}
			
			_ui.boxes.clickLeft.mouseEnabled = _ui.boxes.clickRight.mouseEnabled = true;
			Core.terminal.updateKeyBonusGameMode();
		}
		
		private function superCompleteHandler(e:Event = null):void 
		{			
			var timer:Timer = new Timer(100);
			var step:Number = 1;
			var modificator:int = int(_superText.text);
			SoundController.playBacksound(creditincrease);
			timer.addEventListener(TimerEvent.TIMER, function timerCompleteHandler(e:TimerEvent):void {
				_superText.text = String(int(_superText.text) - int(step));
				if (timer.delay > 20) timer.delay -= 5;
				if (timer.delay <= 20) step *= 1.05;
				if (int(_superText.text) <= 0) {
					timer.removeEventListener(TimerEvent.TIMER, timerCompleteHandler);
					_superText.visible = false;
					_superUI.label.gotoAndStop(2);
					
					Core.data.visibleWinCredits += modificator;
					Core.game.bonus.updateWin(Core.data.visibleWinCredits);
					
					SoundController.stopBacksound();
					SoundController.playSound(keysuperwin, Core.game.bonus.endGame);
				} else Core.game.bonus.updateWin(Core.data.visibleWinCredits + modificator - int(_superText.text));
			});
			timer.start();
		}
		
		private function rightClickHandler(e:MouseEvent):void 
		{
			choiceBox(1);
		}
		
		private function leftClickHandler(e:MouseEvent):void 
		{
			choiceBox(0);
		}
		
		private function keyClickHandler(e:MouseEvent):void 
		{
			useSuperKey();
		}
		
		public function get ui():KeyBonusUI {return _ui;}
		
	}

}