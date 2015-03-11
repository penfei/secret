package ru.gui.popups 
{
	import ru.controller.Core;
	import ru.controller.SoundController;
	import ru.gui.View;
	import sounds.button;
	import symbols.HelpPopupUI;
	/**
	 * ...
	 * @author Sah
	 */
	public class HelpPopup extends View
	{
		private var _ui:HelpPopupUI;
		
		public var isShow:Boolean = false;
		
		public function HelpPopup() 
		{
			_ui = new HelpPopupUI();
			_ui.y = 26;
			addChild(_ui);
			
			visible = false;
		}
		
		public function show():void {
			visible = true;
			_ui.gotoAndStop(0);
			Core.terminal.helpMode();
		}
		
		public function hide():void {
			visible = false;
			Core.terminal.normalMode();
		}
		
		public function activate():void {
			isShow = !isShow;
			SoundController.playSound(button);
			Core.data.isHelp = isShow;
			if (isShow) show();
			else hide();
		}
		
		public function next():void {
			if (_ui.currentFrame == _ui.totalFrames) _ui.gotoAndStop(0);
			else _ui.gotoAndStop(_ui.currentFrame + 1);
		}
		
		public function previous():void {
			if (_ui.currentFrame == 1) _ui.gotoAndStop(_ui.totalFrames);
			else _ui.gotoAndStop(_ui.currentFrame - 1);
		}
		
	}

}