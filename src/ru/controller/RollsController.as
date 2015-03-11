package ru.controller 
{
	import com.drivecasino.global.CONTENT;
	import com.utils.Copy;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.ColorMatrixFilter;
	import ru.gui.main.GameIcon;
	import ru.gui.main.Icon;
	import ru.utils.TextUtils;
	import sounds.rollrun;
	import sounds.rollstoped;
	/**
	 * ...
	 * @author Sah
	 */
	public class RollsController extends EventDispatcher
	{
		static public const ANIMATE_STOP:String = "ANIMATE_STOP";
		
		private var _ui:MovieClip;
		private var _icons:Array;
		
		public var scetterCallback:Function;
		
		public function RollsController() 
		{
			_ui = CONTENT.swf.mc.rolls as MovieClip;
		}
		
		public function get ui():MovieClip {return _ui;}
		
		public function init():void {
			_icons = [];
			
			var fakeArr:Array = []
			for (var i:uint = 0; i < 90; i++) {
				fakeArr.push(getIcon(i % DataController.ICONS_COUNT));
			}
			_ui.init(fakeArr, {width:96, height:112, offsetX:16, offsetY:0, inLine:5, inColumn:3, isBlur:false, direction:1, iconsRepeat:3});
			_ui.x = 48;
			_ui.y = 82;
		}
		
		public function createRoll(comb:Array):void {
			for (var i:int = 0; i < comb.length; i++) {
				_icons.push(getGameIcon(comb[i], i));
			}
			_ui.createRoll(_icons);
		}
		
		public function startRoll(arrComb:Array):void {
			Core.data.isRolled = true;
			SoundController.playBacksound(rollrun, 80);
			_icons = [];
			Core.ui.stage.frameRate = 30;
			
			for (var i:int = 0; i < arrComb.length; i++) {
				_icons.push(getGameIcon(arrComb[i], i));
			}
			
			if (Core.data.rollSpeed == 1) _ui.startRoll( { rollSpeed:110, startTime:8, finishTime:20, repeat:[3, 7, 11, 15, 19], rollStrenth:2 } );
			else if (Core.data.rollSpeed == 2) _ui.startRoll( { rollSpeed:170, startTime:5, finishTime:15, repeat:[2, 6, 10, 14, 18], rollStrenth:2.3 } );
			else _ui.startRoll({repeat:[5, 10, 15, 20, 25]});
		}
		
		public function finishRoll(arrComb:Array, callBack:Function):void {
			_icons = [];
			for (var i:int = 0; i < arrComb.length; i++) {
				_icons.push(getGameIcon(arrComb[i], i));
			}
			_ui.finishRoll(_icons);
			_ui.addEventListener(ANIMATE_STOP, function complete(e:Event):void {
				_ui.removeEventListener(ANIMATE_STOP, complete);
				Core.ui.stage.frameRate = 24;
				Core.data.isRolled = false;
				callBack();
			});
			_ui.addEventListener('ROLL_STOP_0', rollStopHandler);
			_ui.addEventListener('ROLL_STOP_1', rollStopHandler);
			_ui.addEventListener('ROLL_STOP_2', rollStopHandler);
			_ui.addEventListener('ROLL_STOP_3', rollStopHandler);
			_ui.addEventListener('ROLL_STOP_4', rollStopHandler);
		}
		
		public function showKeys():void 
		{
			var icon:GameIcon;
			var scetters:Array = getWinKeys();
			if (Core.data.isKeyWin) {
				for each(icon in scetters) icon.playAnimation();
			}
			if (Core.data.isKeyBonusGame) {
				for each(icon in scetters) icon.playScetterAnimation();
			}
		}
		
		public function showBoxes():void 
		{
			var icon:GameIcon;
			if (Core.data.isBoxBonusGame) {
				var scetters:Array = getWinBoxes();
				for each(icon in scetters) {
					icon.playAnimation();
				}
			}
		}
		
		public function stopAllAnimations():void {
			for each(var icon:GameIcon in _icons) {
				icon.showImage();
			}
		}
		
		private function rollStopHandler(e:Event):void 
		{
			var id:uint = uint(e.type.slice(e.type.length - 1, e.type.length));
			rollStop(id);
		}
		
		private function rollStop(id:uint):void 
		{
			SoundController.stopBacksound();
			SoundController.playSound(rollstoped);
		}
		
		private function getGameIcon(iconID:int, position:int):GameIcon 
		{
			var image:Bitmap = Copy.bitmap(CONTENT.images.icons["icons" + iconID]);
			var animate:MovieClip = Copy.swf(CONTENT.swf.icons["icons" + iconID]);
			var icon:GameIcon = new GameIcon(iconID, position, image, animate);
			if (icon.isScetter) icon.setScetterAnimation(Copy.swf(CONTENT.swf.icons["icons" + iconID + "a"]));
			return icon;
		}
		
		private function getIcon(iconID:int):Icon 
		{
			var image:Bitmap = Copy.bitmap(CONTENT.images.icons["icons" + iconID]);
			var animate:MovieClip = Copy.swf(CONTENT.swf.icons["icons" + iconID]);
			return new Icon(iconID, image, animate);
		}
		
		public function getWinKeys():Array 
		{
			var arr:Array = [];
			if (Core.data.isScetterFromHlight) {
				
			} else {
				for each(var icon:GameIcon in _icons) {
					if (icon.isScetter) arr.push(icon);
				}
			}
			return arr;
		}
		
		public function getWinBoxes():Array 
		{
			var arr:Array = [];
			for each(var icon:GameIcon in _icons) {
				if (icon.id == 7) arr.push(icon);
			}
			return arr;
		}
		
		public function getWinScetterMask():int 
		{
			var scetterMask:int = 0;
			for each(var icon:GameIcon in getWinKeys()) {
				scetterMask += Math.pow(2, icon.position);
			}
			return scetterMask;
		}
		
		public function setBlur(): void {
			_ui.isBlur = Core.data.isBlur;
		}
		
	}

}