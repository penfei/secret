package  
{
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import rolls.Roll;
	import rolls.TestIcon;
	/**
	 * ...
	 * @author Sah
	 */
	public class Rolls extends MovieClip
	{
		static private const DEFAULT_ROLL_SPEED:Number = 90;
		static private const DEFAULT_START_TIME:Number = 10;
		static private const DEFAULT_FINISH_TIME:Number = 25;
		static private const DEFAULT_REPEAT:Number = 5;
		static private const DEFAULT_ROll_STRENGTH:Number = 1.70158;
		
		private var _realWidth:Number;
		private var _realHeight:Number;
		private var _iconWidth:Number;
		private var _iconHeight:Number;
		private var _iconOffsetX:Number;
		private var _iconOffsetY:Number;
		private var _inLineCount:uint;
		private var _inColumnCount:uint;
		private var _isBlur:Boolean;
		private var _direction:uint;
		private var _iconsRepeat:uint;
		
		private var _rolls:Vector.<Roll>;
		private var _anim:Array;
		private var _container:Sprite;
		private var _mask:Sprite;
		private var _isCompleted:Boolean = true;
		private var _isFinished:Boolean = false;
		
		private var _index:int;
		private var _index2:int;
		private var _randomIcon:DisplayObject;
		
		public function Rolls() 
		{
			if (stage) {
				//testInit();
			}
		}
		
		//public function testInit():void {
			//stage.addEventListener(MouseEvent.CLICK, test);
				//
			//var w:Number = 222;
			//var h:Number = 222;
			//var iC:uint = 10;
			//var anim:Array = new Array;
			//var mc:Sprite;
			//for (var i:uint = 0; i < 90; i++) {
				//mc = new TestIcon(i % iC);
				//anim.push(mc);
			//}
			//init(anim, { width:w, height:h, offsetX:22, offsetY:0, inColumn:3, inLine:5, direction:1, iconsCount:iC, iconsRepeat:3 } );
			//
			//var icons:Array = new Array;
			//var id:uint;
			//for (i = 0; i < _inLineCount * _inColumnCount; i++) {
				//id = uint(Math.random() * 13);
				//mc = new TestIcon(id);
					//
				//var text:TextField = new TextField();
				//text.text = id.toString();
				//text.y = 50;
				//mc.addChild(text);
					//
				//icons.push(mc);
			//}
			//createRoll(icons);
		//}
		//
		//private function test(e:MouseEvent = null):void {
			//var icons:Array = new Array;
			//var mc:Sprite;
			//var w:Number = 222;
			//var h:Number = 222;
			//var id:uint;
			//for (var i:uint = 0; i < _inLineCount * _inColumnCount; i++) {
				//id = uint(Math.random() * 13);
				//mc = new TestIcon(id);
					//
				//var text:TextField = new TextField();
				//text.text = id.toString();
				//text.y = 50;
				//mc.addChild(text);
					//
				//icons.push(mc);
			//}
			//startRoll({repeat:[10,12,14,16,18]});
			//setTimeout(function timeout():void {
				//finishRoll(icons);
			//}, 50);
		//}
		
		public function init(anim:Array, settings:Object = null):void {
			TweenPlugin.activate([BlurFilterPlugin]);
			_anim = anim;
			_anim.sort(shuffle);
			if (settings == null) {
				settings = {width:222, height:222, offsetX:22, offsetY:0, inLine:5, inColumn:3, isBlur:false, direction:1, iconsRepeat:3}
			}
			_iconWidth = settings.width ? settings.width: 222;
			_iconHeight = settings.height ? settings.height: 222;
			_iconOffsetX = settings.offsetX ? settings.offsetX: 22;
			_iconOffsetY = settings.offsetY ? settings.offsetY: 0;
			_inLineCount = settings.inLine ? settings.inLine: 5;
			_inColumnCount = settings.inColumn ? settings.inColumn: 3;
			_isBlur = settings.isBlur;
			_direction = settings.direction ? settings.direction: 1;
			_iconsRepeat = settings.iconsRepeat ? settings.iconsRepeat: _inColumnCount;
			_realWidth = iconWidth * _inLineCount + _iconOffsetX * (_inLineCount - 1);
			_realHeight = _iconHeight * _inColumnCount + _iconOffsetY * (_inColumnCount - 1);
			
			_container = new Sprite();
			addChild(_container);
			
			_mask = new Sprite();
			_mask.graphics.beginFill(0xFF0000, 0);
			_mask.graphics.drawRect(-1, -1, _realWidth + 2, _realHeight + 2);
			addChild(_mask);
			
			_rolls = new Vector.<Roll>();
			for (var i:uint = 0; i < _inLineCount; i++) {
				var roll:Roll = new Roll(this, i);
				roll.x = i * (_iconWidth + _iconOffsetX);
				_rolls.push(roll);
				_container.addChild(roll);
			}
		}
		
		private function shuffle(a:Object, b:Object):int
		{
			return Math.floor( Math.random() * 3 - 1 );
		}
		
		public function createRoll(icons:Array):void {
			for each(var roll:Roll in _rolls) {
				roll.removeIcons();
			}
			for (var i:uint = 0; i < icons.length; i++) {
				_rolls[i % _inLineCount].setIcon(uint(i / _inLineCount) , icons[i]);
			}
		}
		
		public function startRoll(settings:Object = null):void {
			if (!_isCompleted) return;
			
			_isCompleted = false;
			_isFinished = false;
			_container.mask = _mask;
			var defaultParametr:Number;
			if (settings == null) settings = { };
			if (!(settings.repeat is Array)) {
				if(settings.repeat == null) defaultParametr = DEFAULT_REPEAT;
				else defaultParametr = settings.repeat;
				settings.repeat = new Array();
				for (_index = 0; _index < _rolls.length; _index++) {
					settings.repeat.push(defaultParametr);
				}
			} 
			if (!(settings.rollSpeed is Array)) {
				if(settings.rollSpeed == null) defaultParametr = DEFAULT_ROLL_SPEED;
				else defaultParametr = settings.rollSpeed;
				settings.rollSpeed = new Array();
				for (_index = 0; _index < _rolls.length; _index++) {
					settings.rollSpeed.push(defaultParametr);
				}
			}
			if (!(settings.startTime is Array)) {
				if(settings.startTime == null) defaultParametr = DEFAULT_START_TIME;
				else defaultParametr = settings.startTime;
				settings.startTime = new Array();
				for (_index = 0; _index < _rolls.length; _index++) {
					settings.startTime.push(defaultParametr);
				}
			}
			if (!(settings.finishTime is Array)) {
				if(settings.finishTime == null) defaultParametr = DEFAULT_FINISH_TIME;
				else defaultParametr = settings.finishTime;
				settings.finishTime = new Array();
				for (_index = 0; _index < _rolls.length; _index++) {
					settings.finishTime.push(defaultParametr);
				}
			}
			if (!(settings.rollStrenth is Array)) {
				if(settings.rollStrenth == null) defaultParametr = DEFAULT_ROll_STRENGTH;
				else defaultParametr = settings.rollStrenth;
				settings.rollStrenth = new Array();
				for (_index = 0; _index < _rolls.length; _index++) {
					settings.rollStrenth.push(defaultParametr);
				}
			}
			if (settings.startFunction == null) settings.startFunction = defaultStartFunction;
			for (var i:uint = 0; i < _rolls.length; i++) {
				_rolls[i].startRoll(settings.rollSpeed[i], settings.repeat[i], settings.startTime[i], settings.finishTime[i], settings.rollStrenth[i], settings.startFunction);
			}
		}
		
		public function finishRoll(icons:Array):void {
			if (_isFinished) return;
			_isFinished = true;
			var rollIcons:Array;
			for (var i:uint = 0; i < _rolls.length; i++) {
				rollIcons = new Array();
				for (var j:uint = 0; j < icons.length; j++) {
					if (j % _inLineCount == i) {
						rollIcons.push(icons[j]);
					}
				}
				_rolls[i].finishRoll(rollIcons);
			}
		}
		
		public function stopAllRolls():void {
			if (_isCompleted) return;
			for (var i:uint = 0; i < _rolls.length; i++) {
				stopRoll(i);
			}
		}
		
		public function stopRoll(index:int):void {
			if (_isCompleted) return;
			if(_rolls[index].repeat > _inColumnCount - 1)
				_rolls[index].repeat = _inColumnCount - 1;
		}
		
		public function getFakeIcon(exclude:Array = null):DisplayObject {
			if (exclude == null) exclude = [];
			for (_index = 0; _index < _anim.length; _index++ ) {
				for (_index2 = 0; _index2 < exclude.length; _index2++ ) {
					if (_anim[_index].id == exclude[_index2]) {
						_index2 = -1;
						break;
					}
				}
				if(_index2 != -1 && _anim[_index].parent == null){
					return _anim[_index];
				}
			}
			return null;
		}
		
		public function complete():void 
		{
			for (_index = 0; _index < _rolls.length; _index++) {
				if (!_rolls[_index].isCompleted) return;
			}
			_isFinished = false;
			_isCompleted = true;
			_container.mask = null;
			dispatchEvent(new Event("ANIMATE_STOP"));
		}
		
		public function rollStoped(index:int):void 
		{
			dispatchEvent(new Event("ROLL_STOP_" + index.toString()));
		}
		
		private function defaultStartFunction(startTimeCount:uint, startTime:uint, rollSpeed:Number):Number {
			return (startTimeCount / startTime) * rollSpeed;
		}
		
		private function arrange():void {
			
		}
		
		public function get isBlur():Boolean {return _isBlur;}
		public function set isBlur(value:Boolean):void {_isBlur = value;}
		public function get iconWidth():Number {return _iconWidth;}
		public function set iconWidth(value:Number):void {_iconWidth = value;}
		public function get iconHeight():Number {return _iconHeight;}
		public function set iconHeight(value:Number):void {_iconHeight = value;}
		public function get iconOffsetX():Number {return _iconOffsetX;}
		public function set iconOffsetX(value:Number):void {_iconOffsetX = value;}
		public function get iconOffsetY():Number {return _iconOffsetY;}
		public function set iconOffsetY(value:Number):void {_iconOffsetY = value;}
		public function get inLineCount():uint {return _inLineCount;}
		public function set inLineCount(value:uint):void {_inLineCount = value;}
		public function get inColumnCount():uint {return _inColumnCount;}
		public function set inColumnCount(value:uint):void {_inColumnCount = value;}
		public function get realWidth():Number {return _realWidth;}
		public function get realHeight():Number {return _realHeight;}
		public function get realCoof():Number { return _realHeight / height; }
		public function get iconsRepeat():uint {return _iconsRepeat;}
		public function set iconsRepeat(value:uint):void {_iconsRepeat = value;}
		
	}

}