package ru.gui.terminal 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import ru.gui.View;
	import symbols.TerminalUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class TerminalView extends View
	{
		private var _ui:TerminalUI;
		private var _hash:Object;
		
		public var startCallBack:Function;
		public var betCallBack:Function;
		public var autoCallBack:Function;
		public var betOneCallBack:Function;
		public var exitCallBack:Function;
		public var fullScreenCallBack:Function;
		public var soundCallBack:Function;
		public var helpCallBack:Function;
		public var lineCallBack:Function;
		public var speedCallBack:Function;
		public var smoothCallBack:Function;
		public var lineDownCallBack:Function;
		
		public function TerminalView() 
		{
			_hash = new Object;
			
			_ui = new TerminalUI();
			addChild(_ui);
			_ui.scaleX = _ui.scaleY = 0.5;
			_ui.x = -160;
			
			
			initButton(_ui.clickarea.maxbet, _ui.btnBet, betClickHandler);
			initButton(_ui.clickarea.auto, _ui.btnAuto, autoClickHandler);
			initButton(_ui.clickarea.betone, _ui.btnBetOne, betOneClickHandler);
			initButton(_ui.clickarea.info, _ui.btnHelp, helpClickHandler);
			initButton(_ui.clickarea.start, _ui.btnStart, startClickHandler);
			initButton(_ui.clickarea.line1, _ui.btnLine1, lineClickHandler, lineDownClickHandler);
			initButton(_ui.clickarea.line3, _ui.btnLine3, lineClickHandler, lineDownClickHandler);
			initButton(_ui.clickarea.line5, _ui.btnLine5, lineClickHandler, lineDownClickHandler);
			initButton(_ui.clickarea.line7, _ui.btnLine7, lineClickHandler, lineDownClickHandler);
			initButton(_ui.clickarea.line9, _ui.btnLine9, lineClickHandler, lineDownClickHandler);
			initButton(_ui.clickarea.fullscreen, _ui.btnFullScreen, fullScreenClickHandler);
			initButton(_ui.clickarea.selectgame, _ui.btnSelGame, exitClickHandler);
			initTerminalButton(_ui.upFull, fullScreenClickHandler);
			initTerminalButton(_ui.upExit, exitClickHandler);
			initTerminalButton(_ui.upSpeed, speedClickHandler);
			initTerminalButton(_ui.upSound, soundClickHandler);
			initTerminalButton(_ui.upSmooth, smoothClickHandler);
			
			blockAll();
		}
		
		public function get ui():TerminalUI { return _ui; }
		
		public function blockAll():void {
			setButtonsActivity(false, _ui.btnBetOne, _ui.btnBet, _ui.btnAuto, _ui.btnHelp, _ui.btnStart, _ui.btnLine1, _ui.btnLine3, _ui.btnLine5, _ui.btnLine7, _ui.btnLine9);
		}
		
		public function blockHelp():void {
			setButtonsActivity(false, _ui.btnHelp);
		}
		
		public function blockStartAndAuto():void {
			setButtonsActivity(false, _ui.btnStart, _ui.btnAuto);
		}
		
		public function unBlockStartAndAuto():void {
			setButtonsActivity(true, _ui.btnStart, _ui.btnAuto);
		}
		
		public function blockMaxBet():void {
			setButtonsActivity(false, _ui.btnBet);
		}
		
		public function get startActivity():Boolean {
			return getButtonActivity(_ui.btnStart);
		}
		
		public function get helpActivity():Boolean {
			return getButtonActivity(_ui.btnHelp);
		}
		
		public function unBlockAll():void {
			setButtonsActivity(true, _ui.btnBetOne, _ui.btnBet, _ui.btnAuto, _ui.btnHelp, _ui.btnStart, _ui.btnLine1, _ui.btnLine3, _ui.btnLine5, _ui.btnLine7, _ui.btnLine9);
		}
		
		public function updateLinesButton(lineNum:uint):void {
			for (var i:uint = 1; i <= 9; i++) {
				if (_ui["btnLine" + String(i)] != null) {
					setButtonsActivity(lineNum != i, _ui["btnLine" + String(i)]);
				}
			}
		}
		
		public function normalMode():void 
		{
			unBlockAll();
			//setButtonsActivity(false, _ui.btnBetOne, _ui.btnBet);
		}
		
		public function helpMode():void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnHelp, _ui.btnStart, _ui.btnLine1, _ui.btnLine9);
		}
		
		public function winMode():void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnBetOne, _ui.btnBet, _ui.btnStart, _ui.btnHelp);
		}
		
		public function winGambleMode():void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnStart, _ui.btnAuto);
		}
		
		public function gambleMode():void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnStart, _ui.btnAuto, _ui.btnLine3, _ui.btnLine5, _ui.btnLine7, _ui.btnLine9);
		}
		
		public function jackpotMode():void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnStart);
		}
		
		public function rollMode():void {
			
		}
		
		public function saveMode():void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnStart);
		}
		
		public function updateBoxBonusGameMode(boxes:Array):void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnLine1, _ui.btnLine3, _ui.btnLine5, _ui.btnLine7, _ui.btnLine9);
			for (var i:uint = 0; i < boxes.length; i++) {
				setButtonsActivity(false, _ui["btnLine" + String(boxes[i] * 2 - 1)] );
			}
		}
		
		public function updateKeyBonusGameMode(hasSuperKey:Boolean):void 
		{
			blockAll();
			setButtonsActivity(true, _ui.btnLine3, _ui.btnLine7);
			setButtonsActivity(hasSuperKey, _ui.btnLine9);
		}
		
		private function initButton(button:MovieClip, view:MovieClip, callBack:Function, callBackDown:Function = null):void {
			_hash[view] = new TerminalButton(button, view, callBack, callBackDown);
		}
		
		private function initTerminalButton(button:MovieClip, callBack:Function):void {
			button.buttonMode = true;
			button.mouseChildren = false;
		
			button.addEventListener(MouseEvent.MOUSE_UP, function buttonUpHandler(e:MouseEvent):void {
				callBack(e);
			});
		}
		
		private function getButtonActivity(button:MovieClip):Boolean {
			return _hash[button].mouseEnabled;
		}
		
		private function setButtonsActivity(value:Boolean, ... btns):void {
			for each (var button:MovieClip in btns) {
				_hash[button].setActivity(value)
			}
		}
		
		public function updateSound(frame:Number):void 
		{
			_ui.upSound.gotoAndStop(frame);
		}
		
		public function updateSmooth(frame:Number):void 
		{
			_ui.upSmooth.gotoAndStop(frame);
		}
		
		public function updateSpeed(frame:Number):void 
		{
			_ui.upSpeed.gotoAndStop(frame);
		}
		
		public function updateFullScreen(frame:Number):void 
		{
			_ui.upFull.gotoAndStop(frame);
		}
		
		private function betClickHandler(e:MouseEvent):void {
			betCallBack();
		}
		
		private function autoClickHandler(e:MouseEvent):void {
			autoCallBack();
		}
		
		private function betOneClickHandler(e:MouseEvent):void {
			betOneCallBack();
		}
		
		private function helpClickHandler(e:MouseEvent):void {
			helpCallBack();
		}
		
		private function startClickHandler(e:MouseEvent):void {
			startCallBack();
		}
		
		private function exitClickHandler(e:MouseEvent):void {
			exitCallBack();
		}
		
		private function fullScreenClickHandler(e:MouseEvent):void {
			fullScreenCallBack();
		}
		
		private function soundClickHandler(e:MouseEvent):void {
			soundCallBack();
		}
		
		private function speedClickHandler(e:MouseEvent):void 
		{
			speedCallBack(_ui.upSpeed.currentFrame - 1);
		}
		
		private function smoothClickHandler(e:MouseEvent):void 
		{
			smoothCallBack();
		}
		
		private function lineClickHandler(e:MouseEvent):void 
		{
			lineCallBack(String(e.target.name).charAt(4));
		}
		
		private function lineDownClickHandler(e:MouseEvent):void 
		{
			lineDownCallBack(String(e.target.name).charAt(4));
		}
		
	}

}
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

class TerminalButton 
{
	private var _button:MovieClip;
	private var _view:MovieClip;
	private var _callback:Function;
	private var _callBackDown:Function;
	private var _isPlaying:Boolean
	
	public function TerminalButton(button:MovieClip, view:MovieClip, callback:Function, callBackDown:Function = null):void
	{
		_callBackDown = callBackDown;
		_callback = callback;
		_view = view;
		_button = button;
		
		_button.buttonMode = true;
		_button.mouseChildren = false;
		_isPlaying = false;
		
		_view.gotoAndStop(2);
	
		if(_callBackDown != null){
			_button.addEventListener(MouseEvent.MOUSE_DOWN, function buttonDownHandler(e:MouseEvent):void {
				_callBackDown(e);
			});
		}
		_button.addEventListener(MouseEvent.MOUSE_UP, function buttonUpHandler(e:MouseEvent):void {
			if (!_isPlaying) {
				_isPlaying = true;
				if (!_view.hasEventListener(Event.ENTER_FRAME)) _view.addEventListener(Event.ENTER_FRAME, buttonEnterFrameHandler);
				_view.gotoAndPlay(2);
			}
			_callback(e);
		});
	}
	
	public function get mouseEnabled():Boolean {
		return _button.mouseEnabled;
	}
	
	public function setActivity(value:Boolean):void {
		_button.mouseEnabled = value;
		if (_isPlaying) {
			if (!_view.hasEventListener(Event.ENTER_FRAME)) _view.addEventListener(Event.ENTER_FRAME, buttonEnterFrameHandler);
		} else {
			setState(value);
		}
	}
	
	private function setState(value:Boolean):void {
		_view.removeEventListener(Event.ENTER_FRAME, buttonEnterFrameHandler);
		_isPlaying = false;
		if (value) _view.gotoAndStop(2);
		else _view.gotoAndStop(1);
	}
	
	private function buttonEnterFrameHandler(e:Event):void 
	{
		if (_view.currentFrame == _view.totalFrames) {
			setState(_button.mouseEnabled);
		}
	}
}