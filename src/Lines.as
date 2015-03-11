package  
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Sah
	 */
	public class Lines extends MovieClip
	{		
		private var _view:Sprite;
		
		private var _iconWidth:Number;
		private var _iconHeight:Number;
		private var _iconOffsetX:Number;
		private var _iconOffsetY:Number;
		private var _inLineCount:uint;
		private var _inColumnCount:uint;
		private var view:MovieClip;
		
		public function Lines() 
		{
			if (stage) testInit();
		}
		
		public function testInit():void 
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function requestCompleteHandler(e:Event):void {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, testDown);
				stage.addEventListener(MouseEvent.MOUSE_UP, testUp);
				var view:MovieClip = loader.content as MovieClip;
				init(view, { width:96, height:112, offsetX:16, offsetY:0, inColumn:3, inLine:5 });
				
				setLines(9);
			});
			loader.load(new URLRequest("view1.swf"));
			
		}
		
		private function testDown(e:MouseEvent):void 
		{
			setCutLines(5);			
		}
		
		private function testUp(e:MouseEvent):void 
		{
			showWinLines([5]);			
		}
		
		public function init(view:MovieClip, settings:Object):void {
			_view = view;
			
			if (settings == null) {
				settings = { width:222, height:222, offsetX:22, offsetY:0, inLine:5, inColumn:3}
			}
			_iconWidth = settings.width ? settings.width: 222;
			_iconHeight = settings.height ? settings.height: 222;
			_iconOffsetX = settings.offsetX ? settings.offsetX: 22;
			_iconOffsetY = settings.offsetY ? settings.offsetY: 0;
			_inLineCount = settings.inLine ? settings.inLine: 5;
			_inColumnCount = settings.inColumn ? settings.inColumn: 3;
			
			addChild(_view);
			
			setLines(1);
		}
		
		public function showLine(line:uint):void {
			_view["line" + String(line)].visible = true;
			_view["cutline" + String(line)].visible = false;
		}
		
		public function noVisibleLines():void {
			for (var i:uint = 0; i < 9; i++) {
				TweenLite.killTweensOf(_view["icon" + String(i + 1)]);
				_view["icon" + String(i + 1)].alpha = 1;
				_view["line" + String(i + 1)].visible = false;
				_view["cutline" + String(i + 1)].visible = false;
			}
		}
		
		public function showWinLines(winComb:Array):void {
			noVisibleLines();
			for (var i:uint = 0; i < winComb.length; i++) {
				if(winComb[i] > 0){
					showLine(i + 1);
					viewAnimationShow(_view["icon" + String(i + 1)]);
				}
			}
		}
		
		private function viewAnimationHide(view:DisplayObject):void 
		{
			view.alpha = 0;
			TweenLite.to(view, 0.5, { onComplete:viewAnimationShow, onCompleteParams:[view] } );
		}
		
		private function viewAnimationShow(view:DisplayObject):void 
		{
			view.alpha = 1;
			TweenLite.to(view, 0.5, { onComplete:viewAnimationHide, onCompleteParams:[view] } );
		}
		
		public function setCutLines(numLine:uint):void {
			for (var i:uint = 0; i < 9; i++) {
				_view["line" + String(i + 1)].visible = false;
				_view["cutline" + String(i + 1)].visible = i < numLine;
				TweenLite.killTweensOf(_view["icon" + String(i + 1)]);
				_view["icon" + String(i + 1)].alpha = 1;
				_view["icon" + String(i + 1)].visible = i < numLine;
			}
		}
		
		public function setLines(numLine:uint):void {
			for (var i:uint = 0; i < 9; i++) {
				_view["line" + String(i + 1)].visible = i < numLine;
				_view["cutline" + String(i + 1)].visible = false;
				TweenLite.killTweensOf(_view["icon" + String(i + 1)]);
				_view["icon" + String(i + 1)].alpha = 1;
				_view["icon" + String(i + 1)].visible = i < numLine;
			}
		}
		
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
		
	}

}