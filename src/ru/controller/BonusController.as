package ru.controller 
{
	import flash.display.Sprite;
	import fonts.CreditsFont;
	import ru.gui.main.FontView;
	import ru.utils.TextUtils;
	/**
	 * ...
	 * @author Sah
	 */
	public class BonusController 
	{
		private var _boxController:BoxBonusController;
		private var _keyController:KeyBonusController;
		private var _ui:Sprite;
		
		private var _credits:FontView;
		private var _bet:FontView;
		private var _win:FontView;
		
		public function BonusController() 
		{
			_boxController = new BoxBonusController();
			_keyController = new KeyBonusController();
			
			_ui = new Sprite;
			_ui.y = 26;
			
			_boxController.init();
			_keyController.init();
			
			_ui.addChild(_boxController.ui);
			_ui.addChild(_keyController.ui);
			
			_credits = new FontView(CreditsFont, "0", false, 10);
			_ui.addChild(_credits);
			_credits.x = 610;
			_credits.y = 7;
			
			_bet = new FontView(CreditsFont, "0", false, 15);
			_ui.addChild(_bet);
			_bet.x = 192;
			_bet.y = 7;
			
			_win = new FontView(CreditsFont, "0", false, 10);
			_ui.addChild(_win);
			_win.x = 399;
			_win.y = 7;
			
			_ui.visible = false;
		}
		
		public function init():void 
		{
			
		}
		
		public function updateCredits(label:String):void {
			_credits.text = label;
		}
		
		public function updateWin(credits:uint):void {
			updateWinCredits(TextUtils.creditsToString(credits, Core.data.currentDenomination, true));
		}
		
		public function updateWinCredits(label:String):void {
			_win.text = label;
		}
		
		public function updateBets(label:String):void {
			_bet.text = label;
		}
		
		public function startBonusGame():void 
		{
			Core.data.visibleWinCredits = Core.data.winCredits;
			updateWin(Core.data.visibleWinCredits);
			Core.net.bonusRequest(bonusRequestComplete);
			
			//bonusRequestComplete({"jplim":["500","0","0","0"],
								//"credit":"22559195",
								//"jpmax":["3000","10000","3000000","15000000"],
								//"bonuscount":"0",
								//"bonus":"0",
								//"total in ":" -801205967 (+0)",
								//"linesvalue":["3","5","0","0","0","0","0","0","0","0"],
								//"total out ":" -1319038341 (+27)",
								//"jpenable":"7",
								//"win":"27",
								//"hlight":"0",
								//"jpmin":["1000","7000","2600000","950000"],
								//"jps":["336", "4736", "469825", "6921491"] } ); //ключи
			//bonusRequestComplete({"jplim":["500","0","0","0"],
									//"credit":"22559008",
									//"jpmax":["3000","10000","3000000","15000000"],
									//"comb":["1","3","2","0","0","0","0","0","0","0","0","0","0","0","0"],
									//"bonuscount":"0",
									//"bonus":"0",
									//"linesvalue":["11","5","0","0","0","0","0","0","0","0"],
									//"klad":["1","2","4","100","200","300","0","0","0"],
									//"jpenable":"7",
									//"win":"54",
									//"hlight":"9",
									//"jpmin":["1000","7000","2600000","950000"],
									//"jps":["337","4737","469825","6921491"]} );
		}
		
		public function endGame():void {			
			if (Core.data.bonusGameType == 2) _keyController.close(closeCallback);
			else _boxController.close(closeCallback);
		}
		
		private function closeCallback():void {
			Core.data.winCredits = Core.data.visibleWinCredits;
			Core.data.bonusGameType = 0;
			Core.ui.main.updateWinCredits(TextUtils.creditsToString(Core.data.winCredits, Core.data.currentDenomination, true));
			_ui.visible = false;
			Core.ui.main.visibleDen = true;
			Core.terminal.winMode();
		}
		
		public function lineClick(line:uint):void {
			if (Core.data.bonusGameType == 1) {
				_boxController.choiceBox(line / 2 + 1);
			}
			if (Core.data.bonusGameType == 2) {
				if (line == 3) _keyController.choiceBox(0);
				if (line == 7) _keyController.choiceBox(1);
				if (line == 9) _keyController.useSuperKey();
			}
		}
		
		private function bonusRequestComplete(answer:Object):void 
		{
			Core.data.update(answer);
			
			_ui.visible = true;
			Core.ui.main.visibleDen = false;
			
			if (Core.data.bonusGameType == 1) {
				_boxController.startBonusGame(answer);
			} else {
				_keyController.startBonusGame(answer);
			}
		}
		
		public function get view():Sprite {return _ui;}
	}

}