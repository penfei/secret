package ru.controller 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import fonts.ModificatorFont;
	import ru.controller.boxBonusGame.KladController;
	import ru.gui.main.FontView;
	import sounds.boxlose;
	import sounds.boxpoof;
	import sounds.boxwin;
	import sounds.creditincrease;
	import symbols.BoxBonusUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class BoxBonusController 
	{
		private var _ui:BoxBonusUI;
		
		private var _modificators:Array;
		private var _boxCount:uint;
		private var _choisedBox:Array;
		private var _boxTexts:Vector.<FontView>;
		private var _isWin:Boolean = true;
		private var _klads:Vector.<KladController>;
		private var _prizes:Array;
		
		public function BoxBonusController() 
		{
			
		}
		
		public function init():void 
		{
			_ui = new BoxBonusUI;
			
			_ui.visible = false;
			_boxTexts = new Vector.<FontView>;
			
			for (var i:uint = 0; i < 5; i++) {
				var font:FontView = new FontView(ModificatorFont, "0", true, 15);
				_ui["box" + String(i + 1)].addChild(font);
				font.x = 39;
				font.y = 22;
				_boxTexts.push(font);
				var number:MovieClip = _ui["box" + String(i + 1)].numbers["n" + String(i + 1)];
				_ui["box" + String(i + 1)].numbers.removeChildren();
				_ui["box" + String(i + 1)].numbers.addChild(number);
				_ui["box" + String(i + 1)].loss.visible = false;
				_ui["box" + String(i + 1)].win.gotoAndStop(1);
				_ui["box" + String(i + 1)].loss.gotoAndStop(1);
			}
			
			_klads = new Vector.<KladController>;
			for (i = 0; i < 3; i++) {
				var klad:KladController = new KladController(i);
				klad.x = 207 + 96 * i;
				klad.y = 102;
				_ui.addChildAt(klad, 1);
				_klads.push(klad);
			}
		}
		
		private function boxClickHandler(e:MouseEvent):void 
		{
			choiceBox(uint(e.target.name.charAt(3)));
		}
		
		public function choiceBox(box:uint):void {
			_ui["box" + String(box)].numbers.visible = false;
			_ui["box" + String(box)].buttonMode = false;
			_ui["box" + String(box)].removeEventListener(MouseEvent.CLICK, boxClickHandler);
			_isWin = uint(_modificators[_boxCount]) > 0;
			_ui["box" + String(box)].loss.visible = !_isWin;
			_ui["box" + String(box)].win.visible = _isWin;
			if (_isWin) {
				SoundController.playSound(boxpoof);
				_ui["box" + String(box)].win.gotoAndPlay(1);
				_ui["box" + String(box)].win.addEventListener("PRIZE_COMPLETE", prizeCompleteHandler);
				_ui["box" + String(box)].win.addEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
			}
			else {
				SoundController.playSound(boxlose);
				_ui["box" + String(box)].loss.gotoAndPlay(1);
				_ui["box" + String(box)].loss.addEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
			}
			
			Core.terminal.view.blockAll();
			_choisedBox.push(box);
			_boxCount++;			
		}
		
		private function prizeCompleteHandler(e:Event):void 
		{
			e.target.removeEventListener("PRIZE_COMPLETE", prizeCompleteHandler);
			e.target.prizes.gotoAndStop(_prizes[_boxCount - 1]);
		}
		
		private function animationCompleteHandler(e:Event):void 
		{
			e.target.removeEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
			
			if (_isWin) {
				SoundController.playSound(boxwin, soundComplete);
				_boxTexts[_choisedBox[_choisedBox.length - 1] - 1].visible = true;
				_boxTexts[_choisedBox[_choisedBox.length - 1] - 1].text = String(_modificators[_boxCount - 1]);				
			} else modificatorsAnimation(complete);
		}
		
		private function soundComplete():void {
			if (_prizes[_boxCount - 1] == 3) _klads[0].next();
			if (_prizes[_boxCount - 1] == 2) _klads[1].next();
			if (_prizes[_boxCount - 1] == 1) _klads[2].next();
			for each(var klad:KladController in _klads) {
				if (klad.isComplete) klad.doComplete(boxComplete);
			}
		}
		
		private function boxComplete():void {
			if (_boxCount == 5) modificatorsAnimation(complete);
			else Core.terminal.updateBoxBonusGameMode(_choisedBox);
		}
		
		private function complete():void {
			setTimeout(Core.game.bonus.endGame, 2000);
			if (_isWin) Core.terminal.updateBoxBonusGameMode(_choisedBox);
		}
		
		private function modificatorsAnimation(callBack:Function = null):void {
			SoundController.playBacksound(creditincrease);
			for (var i:uint = 0; i < _choisedBox.length; i++) {
				if (_boxTexts[_choisedBox[i] - 1].visible) {
					startModificatorAnimation(_choisedBox[i] - 1, callBack);
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
					_ui["box" + String(index + 1)].visible = false;
					modificatorsAnimation(callBack);
					Core.data.visibleWinCredits += modificator * Core.data.currentBet;
					Core.game.bonus.updateWin(Core.data.visibleWinCredits);
				} else Core.game.bonus.updateWin(int(Core.data.visibleWinCredits + (Core.data.currentBet * (modificator - int(_boxTexts[index].text)))));
			});
			timer.start();
		}
		
		public function startBonusGame(answer:Object):void 
		{
			_modificators = answer.linesvalue;
			_prizes = answer.comb;
			_boxCount = 0;
			_choisedBox = new Array;
			
			_ui.visible = true;
			
			Core.terminal.updateBoxBonusGameMode(_choisedBox);
			
			for (var i:uint = 0; i < 5; i++) {
				_boxTexts[i].visible = false;
				_ui["box" + String(i + 1)].visible = true;
				_ui["box" + String(i + 1)].numbers.visible = true;
				_ui["box" + String(i + 1)].win.visible = true;
				_ui["box" + String(i + 1)].loss.visible = false;
				_ui["box" + String(i + 1)].win.gotoAndStop(1);
				_ui["box" + String(i + 1)].loss.gotoAndStop(1);
				_ui["box" + String(i + 1)].buttonMode = true;
				_ui["box" + String(i + 1)].mouseChildren = false;
				_ui["box" + String(i + 1)].addEventListener(MouseEvent.CLICK, boxClickHandler);
			}
			
			for (i = 0; i < _klads.length; i++) {
				_klads[i].init(answer.klad[i], answer.klad[i + 3], Core.data.currentBet);
			}
		}
		
		public function close(callBack:Function = null):void 
		{
			_ui.visible = false;
			if(callBack != null) callBack();
		}
		
		public function get ui():BoxBonusUI {return _ui;}
		
	}

}