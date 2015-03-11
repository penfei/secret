package ru.controller 
{
	import com.drivecasino.global.CONTENT;
	import com.utils.Copy;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import fonts.CreditsFont;
	import ru.gui.main.FontView;
	import ru.utils.TextUtils;
	import sounds.carddraw;
	import sounds.cardopen;
	import sounds.cardwin;
	import symbols.GamblePickUI;
	import symbols.GambleUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class GambleController 
	{		
		private var _ui:GambleUI;
		private var _result:uint;
		private var _previousAnswer:Object;
		
		private var _newRaundTimer:Timer;
		private var _timer:Timer;
		
		private var _dealerCardId:uint;
		private var _dealerCard:Bitmap;
		private var _playerCard:Bitmap;
		private var _cards:Vector.<Bitmap>;
		private var _pick:GamblePickUI;
		private var _line:uint;
		
		private var _credits:FontView;
		private var _input:FontView;
		private var _win:FontView;
		
		public function GambleController() 
		{
			
		}
		
		public function get view():GambleUI {return _ui;}
		
		public function init():void {
			_ui = new GambleUI();
			_ui.y = 26;
			_ui.visible = false;
			
			_pick = new GamblePickUI();
			_pick.y = 272;
			
			_credits = new FontView(CreditsFont, "0", false, 10);
			_ui.addChild(_credits);
			_credits.x = 610;
			_credits.y = 7;
			
			_input = new FontView(CreditsFont, "0", false, 10);
			_ui.addChild(_input);
			_input.x = 193;
			_input.y = 7;
			
			_win = new FontView(CreditsFont, "0", false, 10);
			_ui.addChild(_win);
			_win.x = 401;
			_win.y = 7;
			
			_newRaundTimer = new Timer(500, 1);
			_newRaundTimer.addEventListener(TimerEvent.TIMER_COMPLETE, newRaundTimerCompleteHandler);
			
			_timer = new Timer(2000, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
			
			_ui.cloud.addEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
			_ui.cloud.gotoAndStop(1);
		}
		
		public function updateCredits(label:String):void {
			_credits.text = label;
		}
		
		public function updateWinCredits(label:String):void {
			_win.text = label;
		}
		
		public function close(callBack:Function = null):void 
		{
			Core.data.gameMode = Core.data.oldGameMode;
			_ui.visible = false;
			Core.ui.main.visibleDen = true;
			Core.terminal.normalMode();
			if (callBack != null) callBack();
		}
		
		public function start():void {
			Core.data.oldGameMode = Core.data.gameMode;
			Core.data.gameMode = DataController.GAMBLE_MODE;
			Core.data.visibleWinCredits = Core.data.winCredits;
			_input.text = TextUtils.creditsToString(Core.data.visibleWinCredits, Core.data.currentDenomination, true)
			Core.terminal.updateWinCredits(Core.data.visibleWinCredits);
			_ui.visible = true;
			Core.ui.main.visibleDen = false;
			Core.data.gambleCount = 0;
			_ui.step.gotoAndStop(Core.data.gambleCount + 2);
			newRaund();
		}
		
		private function newRaund():void 
		{
			Core.terminal.view.blockAll();
			_pick.visible = false;
			_ui.cloud.visible = false;
			
			_newRaundTimer.start();
		}
		
		private function newRaundTimerCompleteHandler(e:TimerEvent):void 
		{
			Core.terminal.gambleMode();
			_dealerCardId = uint(Math.random() * 12) + 3;
			_dealerCard = Copy.bitmap(CONTENT.images.cards[idToName(Math.random() * 4, _dealerCardId)]);
			_dealerCard.x = 32;
			_dealerCard.y = 112;
			_ui.addChild(_dealerCard);
			SoundController.playSound(cardopen);
		}
		
		private function idToName(suit:uint, id:uint):String {
			if (id == 15) return "joker";
			var s:String = "";
			if (suit == 0) s = "b";
			else if (suit == 1) s = "c";
			else if (suit == 2) s = "k";
			else if (suit == 3) s = "p";
			
			if (id <= 10) return s + id.toString();
			else if (id == 11) return s + "J";
			else if (id == 12) return s + "Q";
			else if (id == 13) return s + "K";
			else if (id == 14) return s + "A";
			return "";
		}
		
		public function choiceCard(line:uint):void 
		{
			_line = line;
			Core.terminal.view.blockAll();
			
			if(_result != 2){
				Core.data.gambleCount++;
				_ui.step.gotoAndStop(Core.data.gambleCount + 2);
				Core.net.gambleRequest(gambleRequestComplete);
			} else gambleRequestComplete(_previousAnswer);
		}
		
		private function gambleRequestComplete(answer:Object):void 
		{
			trace("Gamble: ", JSON.stringify(answer));
			var cardId:int;
			if (int(answer.win) > 0) _result = 1;
			else _result = 0;
			if (int(Math.random() * 101) < 7) _result = 2;
			_previousAnswer = answer;
			
			if (_result == 1) {
				SoundController.playSound(cardwin);
				cardId = uint(Math.random() * (15 - _dealerCardId)) + _dealerCardId + 1;	
				Core.data.visibleWinCredits *= 2;
				Core.data.winCredits = Core.data.visibleWinCredits;				
				Core.terminal.updateWinCredits(Core.data.visibleWinCredits);
			} else if (_result == 2) {
				SoundController.playSound(carddraw);
				cardId = _dealerCardId;
			} else {
				SoundController.playSound(cardopen);
				cardId = uint(Math.random() * (_dealerCardId - 2)) + 2;	
				Core.data.winCredits = Core.data.visibleWinCredits = 0;
				updateWinCredits(Core.data.winCredits.toString());
				Core.terminal.normalMode();
				Core.terminal.blockAll();
			
			}
			
			_playerCard =  Copy.bitmap(CONTENT.images.cards[idToName(Math.random() * 4, cardId)]);
			if (_line == 3) _playerCard.x = 160;
			if (_line == 5) _playerCard.x = 272;
			if (_line == 7) _playerCard.x = 384;
			if (_line == 9) _playerCard.x = 496;
			_playerCard.y = 112;
			_ui.addChild(_playerCard);
			
			_pick.visible = true;
			if (_line == 3) _pick.x = 173;
			if (_line == 5) _pick.x = 285;
			if (_line == 7) _pick.x = 397;
			if (_line == 9) _pick.x = 509;
			_ui.addChild(_pick);
			
			_ui.cloud.visible = true;
			_ui.cloud.gotoAndPlay(1);
		}		
		
		private function animationCompleteHandler(e:Event):void 
		{
			_ui.cloud.win.visible = _result == 1;
			_ui.cloud.forward.visible = _result == 2;
			_ui.cloud.loss.visible = _result == 0;
			_ui.cloud.stop();
			
			_cards = new Vector.<Bitmap>;
			for (var i:uint = 0; i < 4; i++) {
				var card:Bitmap = Copy.bitmap(CONTENT.images.cards[idToName(Math.random() * 4, uint(Math.random() * 12) + 2)]);
				if (i == 0) card.x = 160;
				if (i == 1) card.x = 272;
				if (i == 2) card.x = 384;
				if (i == 3) card.x = 496;
				card.y = 112;
				_ui.addChild(card);
				_cards.push(card);
			}
			_ui.addChild(_playerCard);
			_ui.addChild(_pick);
			SoundController.playSound(cardopen);
			
			_timer.start();			
		}
		
		private function timerCompleteHandler(e:TimerEvent):void 
		{
			for (var i:uint = 0; i < _cards.length; i++) {
				_ui.removeChild(_cards[i]);
			}
			_ui.removeChild(_dealerCard);
			_ui.removeChild(_playerCard);
			_ui.removeChild(_pick);
			if (_result > 0) {
				if (Core.data.isMaxWin) {
					//SoundController.playGamble();
					//Core.terminal.winGambleMode();
					close();
				} else newRaund();
			}
			else {
				Core.game.lines.winOff();
				Core.game.rolls.stopAllAnimations();
				if (Core.data.isAuto) close(Core.game.start);
				else close();
			}
		}
	}

}