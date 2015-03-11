package com.drivecasino.files
{
	import com.drivecasino.global.CONTENT;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;	

	public class Merchandiser extends EventDispatcher
	{
		private static var _lNameSelected:String;
		private static var _doTrace:Boolean;
		
		private var Counter:Array=[];
			
		public function Merchandiser(doTrace:Boolean=true, lName:String="en")
		{
			_doTrace = doTrace;
			_lNameSelected = lName;
		}

		public function DoWork(fileArr:Array):void
		{
			for each (var f:File in fileArr) 
			{
				CreateLoader(f.path, f.bytes);
			}
		}
		
		private function CreateLoader(str:String, bytes:ByteArray):void
		{
			var type:String=str.slice(str.lastIndexOf(".")+1);
			var subfolder:String = getSubfolderByExt(type);
			
			if(!CONTENT[subfolder]) CONTENT[subfolder] = {};
			
			var folder:String=str.slice(str.lastIndexOf("/",str.lastIndexOf("/")-1)+1, str.lastIndexOf("/"));
			var nametemp:String=str.slice(str.lastIndexOf("/")+1,str.lastIndexOf(".")), nameisnumber:Boolean=false;
			
						
			for(var i:int=0; i<10; i++) if(nametemp.charAt(0)==i.toString()) nameisnumber=true;
			var name:String;
			if(!nameisnumber) name=nametemp; else name=folder+nametemp;
			
			if(!CONTENT[subfolder][folder])
			{
				CONTENT[subfolder][folder]={};
			}
			
			CONTENT[subfolder][folder][name]=new ByteLoader(bytes,subfolder,folder,name);
			(CONTENT[subfolder][folder][name] as ByteLoader).addEventListener(ByteLoaderEvent.READY,ChangeObj);
			Counter.push(CONTENT[subfolder][folder][name]);
			(CONTENT[subfolder][folder][name] as ByteLoader).DoWork();						
		}
		
		private function getSubfolderByExt(ext:String):String
		{
			var subfolder:String;
			switch(ext)
			{
				case "swf":
					subfolder = "swf";					
					break;
				case "png": case "jpg": case "gif":
					subfolder = "images";
					break;
				case "mp3":
					subfolder = "sounds";
					break;
				case "txt": case "lang": case "prop":
					subfolder = "langs";
					break;	
			}			
			return subfolder;
		}
		
		private function ChangeObj(e:ByteLoaderEvent):void
		{
			if(e.subfolder == "sounds")
				CONTENT[e.subfolder][e.folder][e.name] = e.content;
			else
				CONTENT[e.subfolder][e.folder][e.name] = e.content;
			Counter.splice(Counter.indexOf(e.target),1);
			if(Counter.length == 0) {
				Counter=null;
				ApplyLang(_lNameSelected);
				this.dispatchEvent(new Event("READY"));
			}	
		}
		
		public static function ApplySmoothing(source:Object=null):void
		{
			if(!source) source = CONTENT.images;
			for(var s:String in source)
			{
				if(source[s].toString() == "[object Object]")
				{
					ApplySmoothing(source[s]);
				}
				else if(source[s].toString() == "[object Bitmap]")
				{
					(source[s] as Bitmap).smoothing=true;
				}
			}
		}
		
		
		private static var langApplied:Boolean, _lName:String;
		public static function ApplyLang(lName:String, langFolder:Object=null):void
		{
			if(!CONTENT.langs) return;
			
			if(lName == _lName) 
			{
				if(_doTrace) trace("Язык "+lName+" уже был применен");
				return;
			}
			if(langFolder==null) langFolder = CONTENT.langs;
			langApplied = false;
			for(var s:String in langFolder)
			{
				if(typeof langFolder[s] == "object")
				{
					ApplyLang(lName, langFolder[s])
				}
				else if(s==lName)
				{
					var loadedStr:String=langFolder[s];
					var forComments:RegExp = /#.+\n/g;
					var forEndSpaces:RegExp = /\n+$/;
					var forSpaces:RegExp = /\n\n+/g; 
					var forVariables:RegExp = /\n/g; 
					
					loadedStr=loadedStr.replace(forComments, "");
					loadedStr=loadedStr.replace(forEndSpaces, "");
					loadedStr=loadedStr.replace(forSpaces, "\n");
					loadedStr=loadedStr.replace(forVariables, "&");
					
					CONTENT.lang = new URLVariables(loadedStr);
					if(_doTrace) trace("Язык "+lName+" применен успешно");
					_lName=lName;
					langApplied=true;
					break;
				}
			}
			if(_doTrace && langFolder == CONTENT.langs)
			{
				if(!langApplied) trace("Языковой файл "+lName+" не найден");
			}
		}
	}
}