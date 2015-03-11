package rolls 
{
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	/**
	 * ...
	 * @author Sah
	 */
	public class Roll extends Sprite
	{
		private var _id:uint;
		
		private var _main:Sprite;
		private var _rolled:Sprite;
		private var _rolls:Rolls;
		
		private var _isStart:Boolean = false;
		private var _isStop:Boolean = false;
		private var _isFinish:Boolean = false;
		private var _isIconsAdded:Boolean = false;
		private var _isCompleted:Boolean = true;
		private var _repeat:int;
		private var _icons:Array;
		
		private var _index:int;
		private var _speed:Number;
		private var _startTimeCount:uint;
		
		private var _rollSpeed:Number;
		private var _startFunction:Function;
		private var _startTime:uint;
		private var _finishTime:Number;
		private var _rollStrength:Number;
		
		private var _isBlur:Boolean;
		private var _exclude:Array;
		
		public function Roll(rolls:Rolls, id:uint) 
		{
			_rolls = rolls;
			_id = id;
			
			_main = new Sprite();
			addChild(_main);
			
			_rolled = new Sprite();
			addChild(_rolled);
		}
		
		public function get id():uint {return _id;}
		public function get isCompleted():Boolean {return _isCompleted;}
		public function get repeat():int {return _repeat;}
		public function set repeat(value:int):void { _repeat = value; }
		
		public function removeIcons():void {
			_main.removeChildren();
		}
		
		public function setIcon(index:uint, icon:DisplayObject):void {
			icon.y = index * (_rolls.iconHeight + _rolls.iconOffsetY);
			_main.addChildAt(icon, 0);
		}
		
		public function startRoll(rollSpeed:Number, repeat:Number, startTime:uint, finishTime:Number, rollStrength:Number, startFunction:Function):void 
		{
			_rollStrength = rollStrength;
			_finishTime = finishTime;
			_startTime = startTime;
			_startFunction = startFunction;
			_repeat = repeat;
			_speed = 0;
			_rollSpeed = rollSpeed;
			
			_rolled.y = 0;
			_rolled.removeChildren();
			_isStop = _isFinish = _isIconsAdded = _isCompleted = false;
			_isStart = true;
			_startTimeCount = 0;
			
			if(_repeat != 0){
				_main.visible = false;
				_rolled.visible = true;
				
				while (_main.numChildren != 0) {
					_main.getChildAt(0).visible = true;
					_rolled.addChild(_main.getChildAt(0));
				}
				
				_isBlur = _rolls.isBlur;
				if (_isBlur) TweenLite.to(_rolled, _finishTime / _rolls.stage.frameRate, { blurFilter: { blurX:0, blurY:20, quality:1 }} );
				
				addEventListener(Event.ENTER_FRAME, step);
			} else {
				_isCompleted = true;
				_rolls.complete();
			}
		}
		
		public function finishRoll(icons:Array):void 
		{
			_isFinish = true;
			_icons = icons;
		}
		
		private function addFakeIconInRoll():void {
			_exclude = [];
			for (_index = 1; _index < _rolls.iconsRepeat; _index++) {
				_exclude.push((_rolled.getChildAt(_rolled.numChildren - _index) as MovieClip).id);
			}
			
			if (_isFinish && !_isIconsAdded && _repeat < _rolls.iconsRepeat) {
				for (_index = 1; _index < _rolls.iconsRepeat - _repeat; _index++) {
					_exclude.push(_icons[_icons.length - _index].id);
				}
			}
			
			var newIcon:DisplayObject = _rolls.getFakeIcon(_exclude);
			newIcon.y = _rolled.getChildAt(_rolled.numChildren - 1).y - _rolls.iconHeight - _rolls.iconOffsetY;
			_rolled.addChild(newIcon);
		}
		
		public function step(e:Event = null):void {
			if (_isStart) {
				_speed = _startFunction(_startTimeCount, _startTime, _rollSpeed);
				_startTimeCount++;
				if (_startTimeCount >= _startTime) {
					_speed = _rollSpeed;
					_isStart = false;
				}
			} else if (_isFinish) {
				if (_isIconsAdded) {
					if (_speed != 0) {
						Back.strength = _rollStrength;
						if(_isBlur) TweenLite.to(_rolled, _finishTime / _rolls.stage.frameRate, { y: - _icons[0].y, ease:Back.easeOut, onComplete:rollCompleted, blurFilter:{blurX:0, blurY:0, quality:1} } );
						else TweenLite.to(_rolled, _finishTime / _rolls.stage.frameRate, { y: - _icons[0].y, ease:Back.easeOut, onComplete:rollCompleted } );
						_speed = 0;
					}
					if (_speed == 0 && _rolled.y > - _icons[0].y && !_isStop) {
						_isStop = true;
						_rolls.rollStoped(_id);
					}
				} 
			}
			
			if (_speed != 0) {
				for (_index = 0; _index < _rolled.numChildren; _index++) {
					_rolled.getChildAt(_index).y += _speed;
				}
				
				addIcon();
				removeIcon();
			}
		}
		
		private function addIcon():void 
		{
			while (_rolled.getChildAt(_rolled.numChildren - 1).y > 0) {
				if (_isFinish && _repeat >= 0) _repeat--;
				if (_isFinish && _repeat < 0 && !_isIconsAdded) {
					_isIconsAdded = true;
					for (var i:int = _icons.length - 1; i >= 0; i--) {
						_icons[i].y = _rolled.getChildAt(_rolled.numChildren - 1).y - _rolls.iconHeight - _rolls.iconOffsetY;
						_rolled.addChild(_icons[i]);
					}
				} 
				addFakeIconInRoll();
			}
		}
		
		private function removeIcon():void 
		{
			while (_rolled.getChildAt(0).y > _rolls.inColumnCount * (_rolls.iconHeight + _rolls.iconOffsetY) * 1.2) _rolled.removeChild(_rolled.getChildAt(0));
		}
		
		private function rollCompleted():void 
		{
			_rolled.visible = false;
			_main.visible = _isCompleted = true;
			for (var i:uint = 0; i < _icons.length; i++) {
				setIcon(i, _icons[i]);
			}
			var fake:DisplayObject = _rolled.getChildAt(_rolled.numChildren - 1);
			fake.visible = false;
			_main.addChild(fake);
			fake.y = -(_rolls.iconHeight + _rolls.iconOffsetY);
			removeEventListener(Event.ENTER_FRAME, step);
			_rolls.complete();
		}
	}

}