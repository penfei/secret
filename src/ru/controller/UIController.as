package ru.controller {
	
	/**
	 * ...
	 * @author Sah
	 */

	import com.drivecasino.global.CONTENT;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.EventDispatcher;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import ru.gui.jackpot.JackpotView;
	import ru.gui.main.GameAnimation;
	import ru.gui.main.MainView;
	import ru.gui.popups.ErrorPopup;
	import ru.gui.popups.ExitPopup;
	import ru.gui.popups.HelpPopup;
	import ru.gui.popups.JackpotPopup;
	import ru.gui.View;
	import sounds.button;
	
	
	public class UIController extends EventDispatcher {
		private var _canvas:View;
		private var _main:MainView;
		private var _clock:*;
		private var _exitPopup:ExitPopup;
		private var _errorPopup:ErrorPopup;
		private var _helpPopup:HelpPopup;
		private var _jackpot:JackpotView;
		private var _animation:GameAnimation;
		private var _jackpotPopup:JackpotPopup;
		private var _mask:Sprite;
		private var _stage:Stage;
		
		public function UIController(canvas:View, params:Object) {
			_stage = params.stage;
			_canvas = canvas;
			_clock = CONTENT.swf.mc.CasinoClock;
			_clock.scaleX = _clock.scaleY = 1.2;
			_clock.x = 16;
			_clock.y = 1;
			
			_errorPopup = new ErrorPopup(_canvas, params, 640, 480, 0, 26);
			_main = new MainView();
			_animation = new GameAnimation();
		}
		
		public function get canvas():View {return _canvas;}
		public function get stage():Stage {return _stage;}
		public function get main():MainView {return _main;}
		public function get helpPopup():HelpPopup {return _helpPopup;}
		public function get jackpot():JackpotView {return _jackpot;}
		public function get jackpotPopup():JackpotPopup { return _jackpotPopup; }
		public function get isShowJackpot():Boolean {return _jackpotPopup != null && _jackpotPopup.isShow;}
		public function get animation():GameAnimation {return _animation;}
		
		public function init():void {
			_exitPopup = new ExitPopup(Core.data.words.exit_info + "\n" + Core.data.words.exit_info1, Core.data.words.exit_y, Core.data.words.exit_n);
			_exitPopup.setLeft(redirect);
			_exitPopup.setRight(_exitPopup.activate);
			
			_helpPopup = new HelpPopup();
			_jackpot = new JackpotView();
			_jackpotPopup = new JackpotPopup();
			
			_animation.init();
			
			_canvas.addChild(Core.game.rolls.ui);
			_canvas.addChild(Core.terminal.view);
			_canvas.addChild(_main);
			_canvas.addChild(Core.game.lines.ui);
			_canvas.addChild(Core.game.gamble.view);
			_canvas.addChild(Core.game.bonus.view);
			_canvas.addChild(_animation);
			_canvas.addChild(_main.den);
			_canvas.addChild(_main.creditClick);
			_canvas.addChild(_helpPopup);
			_canvas.addChild(_jackpotPopup);
			_canvas.addChild(_jackpot);
			_canvas.addChild(_clock);
			_canvas.addChild(_exitPopup);
			
			_mask = new Sprite();
			_mask.graphics.beginFill(0xFF0000);
			_mask.graphics.drawRect(-_canvas.width, 0, _canvas.width * 2, _canvas.height);
			_canvas.addChild(_mask);
			_canvas.mask = _mask;
			
			Core.terminal.view.exitCallBack = showClosePopup;
			Core.terminal.view.fullScreenCallBack = fullScreen;
			Core.terminal.view.soundCallBack = changeSound;
			Core.terminal.view.helpCallBack = _helpPopup.activate;
			Core.terminal.view.speedCallBack = changeSpeed;
			Core.terminal.view.smoothCallBack = changeSmooth;
		}
		
		public function showErrorPopup():void 
		{
			Core.data.isClosed = true;
			_errorPopup.Warning();
			SoundController.stopBacksound();
			Core.net.stopRequest();
			Core.terminal.view.blockAll();
		}
		
		private function showClosePopup():void 
		{
			SoundController.playSound(button);
			if (Core.data.isClosed) redirect();
			_exitPopup.activate();
		}
		
		private function fullScreen():void 
		{
			SoundController.playSound(button);
			if (stage.displayState == StageDisplayState.FULL_SCREEN || stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
				stage.displayState = StageDisplayState.NORMAL;
				Core.terminal.updateFullScreen(1);
			}
			else {
				stage.displayState = StageDisplayState.FULL_SCREEN;
				Core.terminal.updateFullScreen(2);
			}
		}
		
		private function changeSpeed(speed:uint):void 
		{
			Core.data.rollSpeed = speed + 1;
			if (Core.data.rollSpeed == 3) Core.data.rollSpeed = 0;
			Core.terminal.view.updateSpeed(Core.data.rollSpeed + 1);
		}
		
		private function changeSmooth():void 
		{
			Core.data.isBlur = !Core.data.isBlur;
			Core.terminal.view.updateSmooth(Core.data.isBlur ? 2 : 1);
			Core.game.rolls.setBlur();
		}
		
		private function changeSound():void 
		{
			if (SoundController.volume != 0) SoundController.switchVolume(0);
			else SoundController.switchVolume(SoundController.lastVolume);
			Core.terminal.view.updateSound(SoundController.volume == 0 ? 2 : 1);
		}
		
		private function redirect():void 
		{
			Core.data.isClosed = true;
			SoundController.stopBacksound();
			Core.net.stopRequest();
			var request:URLRequest = new URLRequest(Core.data.redirectAddress); 
			try {            
				navigateToURL(request,"_self");
			}
			catch (e:Error) {
				trace("ERROR:",e.message);
			}
		}
	}
}
