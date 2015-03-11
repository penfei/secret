package ru.controller 
{
	import com.drivecasino.global.CONTENT;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;
	import ru.utils.TextUtils;
	/**
	 * ...
	 * @author Sah
	 */
	public class LinesController extends EventDispatcher
	{
		static public const DEFAULT_TIMER:uint = 1500;
		
		private var _ui:MovieClip;
		private var _lineIndex:int;
		private var _timer:Timer;
		private var _winComb:Array;
		private var _winCredits:Array;
		private var _onLineComplete:Function;
		
		public var linesCompleteCallback:Function;
		
		public function LinesController(params:Object) 
		{
			_ui = params.lines;
			_ui.init(params.linesView, { width:96, height:112, offsetX:16, offsetY:0, inColumn:3, inLine:5 } );
			_ui.y = 26;
		}
		
		public function get ui():MovieClip { return _ui; }
		public function get lineIndex():int {return _lineIndex;}
		
		public function init():void {
			Core.terminal.view.lineDownCallBack = setDownLine;
		}
		
		public function setDownLine(numLine:int):void {
			if(Core.data.isNormalState) _ui.setLines(numLine);
		}
		
		public function setLine(numLine:int):void {
			_ui.setCutLines(numLine);
		}
		
		public function lineOff():void {
			_ui.noVisibleLines();
		}
		
		public function winOn(winComb:Array, winCredits:Array, onLineComplete:Function):void {
			_onLineComplete = onLineComplete;
			_winCredits = winCredits;
			_winComb = winComb;
			_lineIndex = 0;
			Core.data.isFirstPlayWin = true;
			Core.data.isShowWin = true;
			
			_timer = new Timer(DEFAULT_TIMER, 0);
			_timer.addEventListener(TimerEvent.TIMER, nextLineWin);
			_timer.start();
			
			nextLineWin(null);
		}
		
		public function winOff():void {
			if(_timer) {
				_timer.removeEventListener(TimerEvent.TIMER, nextLineWin);
				_timer.stop();
			}
			_ui.noVisibleLines();
		}
		
		public function showFirstWinLine():void {
			for (var i:uint = 0; i < Core.data.linesCombination.length; i++) { 
				if (Core.data.winLines[i] > 0) {
					_ui.showLine(i);
					return;
				}
			}
		}
		
		public function nextLineWin(e:Event = null):void {
			if (!Core.data.isFirstPlayWin) {
				linesCompleteCallback();
				winOff();
				_ui.showWinLines(_winComb);
				return;
			}
			
			if (!_timer.running) return;
			_ui.noVisibleLines();
			
			for (var i:uint = _lineIndex; i < _winComb.length; i++) { 
				if (_winComb[i] > 0) {
					_lineIndex = i + 1;
					_onLineComplete(_lineIndex);
					_ui.showLine(_lineIndex);
					if (Core.data.isKeyWin || Core.data.isKeyBonusGame || Core.data.isBoxBonusGame) return;
					for (var j:uint = _lineIndex; j < _winComb.length; j++) { 
						if (_winComb[j] > 0) return;
					}
				}
			}
			if (Core.data.isKeyWin || Core.data.isKeyBonusGame) {
				_onLineComplete(0);
				Core.game.rolls.showKeys();
				winOff();
				return;
			}
			if (Core.data.isBoxBonusGame) {
				_onLineComplete(0);
				Core.game.rolls.showBoxes();
				winOff();
				return;
			}
			Core.data.isFirstPlayWin = false;
			_lineIndex = 0;
		}
		
	}

}