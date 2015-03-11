package ru.gui.jackpot 
{
	import ru.controller.Core;
	import ru.controller.DataController;
	import ru.gui.View;
	import ru.utils.TextUtils;
	/**
	 * ...
	 * @author Sah
	 */
	public class JackpotView extends View
	{
		private var _items:Vector.<JackpotItemView>
		
		public function JackpotView() 
		{
			_items = new Vector.<JackpotItemView>;
			
			for (var i:uint = 0; i < Core.data.jpValue.length; i++) {
				var item:JackpotItemView = new JackpotItemView(i);
				item.y = 2;
				addChild(item);
				_items.push(item);
			}
			
			update();
		}
		
		public function update():void {
			var visibleItems:Vector.<JackpotItemView> = new Vector.<JackpotItemView>;
			var i:uint;
			for (i = 0; i < _items.length; i++) {
				if (Core.data.isJpVisible(i)) {
					_items[i].visible = true;
					visibleItems.push(_items[i]);
				} else {
					_items[i].visible = false;
				}
				_items[i].update(TextUtils.creditsToString(Core.data.jpValue[i] , 100, true, false), Core.data.isJpCanWin(i));
			}
			for (i = 0; i < visibleItems.length; i++) {
				visibleItems[i].x = 400 / visibleItems.length * (i + 1) - 400 / visibleItems.length / 2 - visibleItems[i].width / 2 + 100;
			}
		}
		
	}

}