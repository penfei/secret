package ru.gui.popups
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ErrorPopup
	{
		private static const WARNING_MESS:String = "Sorry, the game can not continue!\nIf you win a bonus, it will be restored.\nPlease restart the game.";
		private static const FILENAME_WARNING_MESS:String = "/create/general_content/warning_error.lang";
		private static const FILENAME_LOGO:String = "/create/general_content/logo_";
		private static const URL_LOG_ERROR:String = "/parts/add_error.php";
		
		private static const PRIME_SYSTEMS:Array = ["DC", "JP", "Vulkan"];
		
		private static var parent:DisplayObjectContainer;
		private static var container:Sprite;
		private static var textField:TextField;
		private static var textFormat:TextFormat;
		private static var wArea:Number;
		private static var shiftX:Number;
		private static var shiftY:Number;
		private static var hArea:Number;
		private static var lang:String;
		private static var logo:MovieClip;
		private static var system:String;
		private static var params:Object;
		
		public function ErrorPopup(_parent:DisplayObjectContainer, _params:Object, _wArea:Number, _hArea:Number, _shiftX:Number, _shiftY:Number)
		{
			params = _params;
			lang = params.lang;
			parent = _parent;
			wArea = _wArea;
			hArea = _hArea;
			shiftX = _shiftX;
			shiftY = _shiftY;
			system = params.game_logo;
			
			Init();
		}
		
		public function Init():void
		{
			if (parent != null)
			{
				container = new Sprite();
				container.visible = false;
				container.x = shiftX;
				container.y = shiftY;
				
				var area:Shape = new Shape();
				area.graphics.beginFill(0x000000, 1);
				area.graphics.drawRect(0, 0, wArea, hArea);
				area.graphics.endFill();
				container.addChild(area);
				
				textField = new TextField();
				textField.selectable = false;
				textField.width = wArea;
				textField.wordWrap = true;
				textFormat = new TextFormat('Arial', 25, 0xffffff);
				textFormat.align = "center";
				container.addChild(textField);
				
				LoadLogo();
				if (lang != null)
				{
					LoadMessagesWarning();
				}
				else
				{
					ShowTextMessage(WARNING_MESS);
				}
				
			}
		}
		
		//показ
		private static function Show():void
		{
			if (parent != null)
			{
				parent.addChild(container);
				container.visible = true;
				
			}
		}
		
		private static function ShowTextMessage(_s:String):void
		{
			textField.text = _s;
			textField.setTextFormat(textFormat);
			textField.height = textField.textHeight + 30;
			textField.y = ((hArea / 2) - (textField.height / 2)) + 90;
		}
		
		//загрузка донных
		private function LoadMessagesWarning():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onEndLoadMess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorLoadMess);
			loader.load(new URLRequest(params.systemUrl + FILENAME_WARNING_MESS));
		}
		
		private function LoadLogo():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onEndLoadLogo);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorLoadLogo);
			if (checkSystem(system))
			{
				loader.load(new URLRequest(params.systemUrl + FILENAME_LOGO + system + ".swf"));
			}
			else
			{
				loader.load(new URLRequest(params.systemUrl + FILENAME_LOGO + "default.swf"));
			}
		}
		
		private function onEndLoadMess(_e:Event):void
		{
			var loader:URLLoader = URLLoader(_e.target);
			var data:String = loader.data;
			var lines:Array = data.split(";\r\n");
			var mes:String;
			if (lines != null)
			{
				for (var i:int = 0; i < lines.length; i++)
				{
					var line:String = lines[i];
					if (line != null)
					{
						var mess:Array = line.split("=");
						if (mess != null)
						{
							if (mess.length == 2)
							{
								if (lang == mess[0])
								{
									mes = mess[1];
									break;
								}
							}
						}
					}
				}
				if (mes != null)
				{
					var tempMes:String = "";
					for (var c:int = 0; c < mes.length; c++)
					{
						if (mes.charAt(c) == '#')
						{
							tempMes += "\n";
						}
						else
						{
							tempMes += mes.charAt(c);
						}
					}
					mes = tempMes;
					ShowTextMessage(mes);
				}
				else
				{
					ShowTextMessage(WARNING_MESS);
				}
			}
			else
			{
				ShowTextMessage(WARNING_MESS);
			}
		}
		
		private function onErrorLoadMess(_e:Event):void
		{
			ShowTextMessage(WARNING_MESS);
		}
		
		private function onEndLoadLogo(_e:Event):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo(_e.target);
			var loader:Loader = loaderInfo.loader;
			logo = MovieClip(loader.content);
			if (container != null && logo != null && checkSystem(system))
			{
				logo.x = (wArea / 2) - (logo.width / 2);
				logo.y = ((hArea / 2) - (logo.height / 2)) - 90;
				container.addChild(logo);
			}
		}
		
		private function onErrorLoadLogo(_e:Event):void
		{
		}
		
		//внешние функции
		public static function Warning():void
		{
			Show();
		}
		
		public function Warning():void
		{
			Show();
		}
		
		//проверка наличия системы в списке поддерживаемых систем
		private function checkSystem(_curSystem:String):Boolean
		{
			for (var i:int = 0; i < PRIME_SYSTEMS.length; i++)
			{
				if (PRIME_SYSTEMS[i] == _curSystem)
				{
					return true
				}
			}
			return false;
		}
	}
}