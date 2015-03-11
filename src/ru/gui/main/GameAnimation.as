package ru.gui.main 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import ru.controller.Core;
	import ru.gui.View;
	import symbols.GameAnimationBackgraundUI;
	import symbols.GameAnimationUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class GameAnimation extends View
	{
		private var _back:GameAnimationBackgraundUI;
		private var _ui:GameAnimationUI;
		
		private var _isSleeping:Boolean;
		private var _isWin:Boolean;
		private var _timer:Timer;
		
		public function GameAnimation() 
		{
			_back = new GameAnimationBackgraundUI();
			_back.y = 26;
			addChild(_back);
			
			_ui = new GameAnimationUI();
			_ui.y = 26;
			addChild(_ui);
			
			_isSleeping = false;
			_isWin = false;
			
			noVisible();
		}
		
		public function init():void {
			normalState();
			
			_timer = new Timer(60000, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
			resetAnimationTimer();
			
			Core.ui.stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function timerCompleteHandler(e:TimerEvent):void 
		{
			_isSleeping = true;
		}
		
		public function resetAnimationTimer():void {
			_isSleeping = false;
			_timer.reset();
			_timer.start();
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			resetAnimationTimer();
		}
		
		public function normalState():void {
			_isSleeping = false;
			if(!_ui.sleep.visible){
				var r:uint = Math.random() * 100;
				if (r > 50) {
					if (r < 60) smokeMode();
					else if (r < 70) drinkMode();
					else if (r < 85) blinkMode();
					else eyeMode();
				} else handMode();
			}
		}
		
		public function sleepState():void {
			_isSleeping = true;
		}
		
		public function winState():void {
			_isWin = true;
		}
		
		private function handMode():void {
			noVisible();
			playAnimation(_ui.hand);
		}
		
		private function winMode():void {
			noVisible();
			playAnimation(_ui.bottle);
		}
		
		private function drinkMode():void {
			noVisible(false);
			playAnimation(_ui.drink);
		}
		
		private function blinkMode():void {
			noVisible();
			playAnimation(_ui.morg);
			playAnimation(_ui.hand, false);
		}
		
		private function eyeMode():void {
			noVisible();
			playAnimation(_ui.eye);
			playAnimation(_ui.hand, false);
		}
		
		private function smokeMode():void {
			noVisible();
			playAnimation(_ui.smoke);
		}
		
		private function sleepMode():void {
			noVisible();
			playAnimation(_ui.sleep);
			playAnimation(_ui.hand, false);
		}
		
		private function playAnimation(anim:MovieClip, hasEventListener:Boolean = true):void {
			anim.visible = true;
			anim.gotoAndPlay(1);
			if (hasEventListener) anim.addEventListener("ANIMATION_COMPLETE", animationCompleteHandler);
		}
		
		private function animationCompleteHandler(e:Event):void 
		{
			if (_isWin) {
				_isWin = false;
				winMode();
				return;
			}
			if (_isSleeping) sleepMode();
			else {
				noVisible();
				normalState();
			}
		}
		
		private function noVisible(hatVisible:Boolean = true):void {
			for (var i:uint = 0; i < _ui.numChildren; i++) {
				_ui.getChildAt(i).visible = false;
				(_ui.getChildAt(i) as MovieClip).stop();
			}
			_back.hat.visible = hatVisible;
		}
		
	}

}