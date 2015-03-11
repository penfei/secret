package ru.controller {
	import flash.net.SharedObject;
	import ru.utils.TextUtils;

	public class DataController {
		static public const ICONS_COUNT:uint = 9;
		static public const SCETTER:uint = 8;
		static public const WILD:uint = 5;
		
		static public const LINES:Array = [[5, 6, 7, 8, 9],
										[0, 1, 2, 3, 4],
										[10, 11, 12, 13, 14],
										[0, 6, 12, 8, 4],
										[10, 6, 2, 8, 14],
										[0, 1, 7, 13, 14],
										[10, 11, 7, 3, 4],
										[5, 11, 12, 13, 9],
										[5, 1, 2, 3, 9]
										];
		static public const BETS:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90];
		static public const NORMAL_GAME_MODE:String = "NORMAL_GAME_MODE";
		static public const GAMBLE_MODE:String = "GAMBLE_MODE";
		
		public var gameId:uint;
		public var gameMode:String;
		public var oldGameMode:String;
		
		public var isHelp:Boolean = false;
		public var isBlocked:Boolean = false;
		public var isScetterFromHlight:Boolean = false;
		public var isKeyWin:Boolean = false;
		public var isBoxBonusGame:Boolean = false;
		public var isKeyBonusGame:Boolean = false;
		public var isRequest:Boolean = false;
		public var isRolled:Boolean = false;
		public var isInit:Boolean = false;
		public var isStart:Boolean = false;
		public var isSaveWin:Boolean = false;
		public var isAuto:Boolean = false;
		public var isClosed:Boolean = false;
		public var isFirstPlayWin:Boolean = false;
		public var isShowWin:Boolean = false;
		public var isNormalState:Boolean = false;
		public var denominations:Array;
		public var gambleCount:int;
		public var currentBetIndex:uint;
		public var currentDeniminationIndex:uint;
		public var credits:uint;
		public var winCredits:uint;
		public var newBonusGames:uint;
		public var scetterMask:uint;
		public var visibleWinCredits:uint;
		public var winLines:Array;
		public var linesCombination:Array;
		public var iconsCombination:Array;
		public var jpWin:Array;
		public var jpMax:Array;
		public var jpMin:Array;
		public var jpValue:Array;
		public var jpRequirement:Array;
		public var jpEnable:Number;
		public var valute:String;
		public var activeLinesCount:uint;
		public var redirectAddress:String;
		public var words:Object;
		public var bonusGameBoxType:Boolean;
		public var bonusGameType:uint;
		public var keyCount:uint;
		
		public var so:SharedObject;
		private var _rollSpeed:uint = 0;
		private var _isBlur:Boolean = false;

		public function DataController(params:Object) {
			so = SharedObject.getLocal("cachegameflash" + params.game_logo, "/");
			
			gameId = params.gameId;
			valute = params.valute;
			redirectAddress = params.gcat;
			words = params.words;
			activeLinesCount = 9;
			currentBetIndex = 0;
			currentDeniminationIndex = 0;
			keyCount = 0;
			bonusGameBoxType = true;
			bonusGameType = 0;
			gameMode = NORMAL_GAME_MODE;
			
			if (params.hasOwnProperty("isBlur")) _isBlur = uint(params.rolls_smoothing) ? true : false;
			if (params.hasOwnProperty("rollSpeed")) _rollSpeed = params.speed;
			
			if (so.data.hasOwnProperty("isBlur")) _isBlur = so.data.isBlur;
			if (so.data.hasOwnProperty("rollSpeed")) _rollSpeed = so.data.rollSpeed;
			
			rollSpeed = _rollSpeed;
			isBlur = isBlur;
		}
		
		public function init(answer:Object):void 
		{
			isInit = true;
			updateCredits(answer);
			if(answer.dentab is Array) denominations = answer.dentab;
			else denominations = [answer.dentab];
			
			setDefaultBet();
		}
		
		public function setDefaultBet():void {
			for (currentBetIndex = 0; currentBetIndex < BETS.length; currentBetIndex++) {
				if (currentBetInLines == 1 && credits  > currentBet) return;
			}
			searchMaxBet();
		}
		
		public function saveWinComplete():void {		
			winCredits = 0;
		}
		
		public function saveJackpotComplete():void {		
			jpWin = [0, 0, 0, 0];
		}
		
		public function update(answer:Object):void {
			if (answer.hasOwnProperty("win")) winCredits = answer.win;
			if (answer.hasOwnProperty("comb")) iconsCombination = answer.comb;
			if (answer.hasOwnProperty("linecnt")) activeLinesCount = answer.linecnt;
			if (answer.hasOwnProperty("hlight")) scetterMask = answer.hlight;
			if (answer.hasOwnProperty("lines")) linesCombination = answer.lines;
			if (answer.hasOwnProperty("jpmin")) jpMin = answer.jpmin;
			if (answer.hasOwnProperty("jpmax")) jpMax = answer.jpmax;
			if (answer.hasOwnProperty("jplim")) jpRequirement = answer.jplim;
			if (answer.hasOwnProperty("jps")) jpValue = answer.jps;
			if (answer.hasOwnProperty("jpwins")) jpWin = answer.jpwins;
			if (answer.hasOwnProperty("jpenable")) jpEnable = answer.jpenable;
			if (answer.hasOwnProperty("nospin")) isKeyWin = answer.nospin > 0;
			if (answer.hasOwnProperty("linesvalue")) winLines = answer.linesvalue;
			if (answer.hasOwnProperty("bonus")) {
				newBonusGames = answer.bonus;
				if (newBonusGames == 0) {
					isBoxBonusGame = false;
					isKeyBonusGame = false;
				}
			}
			if (answer.hasOwnProperty("bonustype")) {
				bonusGameType = answer.bonustype;
				if (newBonusGames > 0 && bonusGameType == 1) isBoxBonusGame = true;
				if (newBonusGames > 0 && bonusGameType == 2) isKeyBonusGame = true;
			}
			updateCredits(answer);
			updateDen(answer);
			updateBet(answer);
		}
		
		public function updateDen(answer:Object):void {
			if (answer.hasOwnProperty("den")) {
				for (currentDeniminationIndex = 0; currentDeniminationIndex < denominations.length; currentDeniminationIndex++) {
					if (currentDenomination == answer.den) return;
				}
			}
		}
		
		public function updateBet(answer:Object):void {
			if (answer.hasOwnProperty("betperlines")) {
				for (currentBetIndex = 0; currentBetIndex < BETS.length; currentBetIndex++) {
					if (currentBetInLines == answer.betperlines) return;
				}
			}
		}
		
		public function updateCredits(answer:Object):void {
			credits = answer.credit;
		}
		
		public function getParamsFromNewRequest():Object 
		{
			return { lines:activeLinesCount, betperlines:BETS[currentBetIndex], den:currentDenomination };
		}
		
		public function isJpVisible(index:uint):Boolean {
			if (currentBet < Number(jpRequirement[index])) return false;
			var str:String = int(jpEnable).toString(2);
			for (var i:uint = 0; i < jpValue.length - str.length; i++ ) str = "0" + str;
			return str.charAt(jpValue.length - 1 - index) == "1";
		}
		
		public function isJpCanWin(index:uint):Boolean {
			return int(jpValue[index]) > int(jpMin[index]);
		}
		
		public function get isWin():Boolean {
			return winCredits > 0;
		}
		
		public function get hasSuperKey():Boolean {
			return keyCount > 8;
		}
		
		public function get isJackpotWin():Boolean {
			return jackpotWin > 0;
		}
		
		public function get isNotCorrectBet():Boolean {
			return credits / currentDenomination < currentBet;
		}
		
		public function get jackpotWin():Number {
			for (var i:int = 0; i < jpWin.length; i++) { 
				if (Number(jpWin[i]) > 0) return Number(jpWin[i]);
			}
			return 0;
		}
		
		public function get isGamble():Boolean {
			return gameMode == GAMBLE_MODE;
		}
		
		public function get isMaxWin():Boolean {
			return gambleCount >= 7;
		}
		
		public function getBetBy(indexBet:uint, indexLine:uint):Number {
			return TextUtils.formatNumber((BETS[indexBet]) * indexLine);
		}
		
		public function get currentBet():Number {
			return TextUtils.formatNumber(currentBetInLines * activeLinesCount) ;
		}
		
		public function get maxBet():Number {
			return TextUtils.formatNumber((BETS[BETS.length - 1] / currentDenomination) * activeLinesCount);
		}
		
		public function get currentBetInLines():Number {
			return BETS[currentBetIndex];
		}
		
		public function get currentDenomination():Number {
			return denominations[currentDeniminationIndex];
		}
		
		public function get rollSpeed():uint 
		{
			return _rollSpeed;
		}
		
		public function set rollSpeed(value:uint):void 
		{
			_rollSpeed = value;
			so.data.rollSpeed = _rollSpeed;
		}
		
		public function get isBlur():Boolean 
		{
			return _isBlur;
		}
		
		public function set isBlur(value:Boolean):void 
		{
			_isBlur = value;
			so.data.isBlur = _isBlur;
		}
		
		public function getCombination(index:uint):Vector.<uint> {
			var comb:Vector.<uint> = new Vector.<uint>();
			for each (var item:uint in LINES[index]) 
			{
				comb.push(iconsCombination[item]);
			}
			return comb;
		}
		
		public function hasScetterInRoll(index:uint):Boolean {
			return iconsCombination[index] == SCETTER || iconsCombination[index + 5] == SCETTER || iconsCombination[index + 10] == SCETTER;
		}
		
		public function getWinCombination(index:uint):Vector.<uint> {
			var comb:Vector.<uint> = new Vector.<uint>();
			if (index == 0) {
				for each (var item:uint in iconsCombination) 
				{
					if (item == SCETTER) comb.push(item);
				}
			} else {
				index--;
				var c:Vector.<uint> = getCombination(index);
				var winIcons:String = TextUtils.maskToString(linesCombination[index]);
				
				for (var j:uint = 0; j < winIcons.length; j++) {
					if (winIcons.charAt(j) == "1") {
						comb.push(c[j]);
					}
				}
			}
			return comb;
		}
		
		public function searchMaxBet():void 
		{
			for (var k:int = currentDeniminationIndex; k >= 0; k--) {
				for (var i:int = activeLinesCount; i > 0; i--) {
					for (var j:int = BETS.length - 1; j >= 0; j--) {
						if (credits / denominations[k] >= getBetBy(j, i)) {
							activeLinesCount = i;
							currentBetIndex = j;
							currentDeniminationIndex = k;
							return;
						}
					}
				}
			}
			activeLinesCount = 1;
			currentBetIndex = 0;
			currentDeniminationIndex = 0;
		}
		
		public function newCombination():void 
		{
			bonusGameBoxType = !bonusGameBoxType;
			isBoxBonusGame = false;
			isKeyBonusGame = false;
		}
	}
}
