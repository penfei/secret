package com.drivecasino.files
{
	import flash.utils.ByteArray;

/*	---------------------------------
		8 - длина заголовка без данного поля
	---------------------------------
		8- длина поля text
		8- где начинается  файл
		8- длина файла
		text -имя файла
	---------------------------------
	... другие сегменты заголовка
		---------------------------------
		файл1
		....
		файлN
		---------------------------------*/

	public class Decomposer
	{
		
		private static var globalFile:ByteArray;
		
		public static function DecomposeFile(_globalFile:ByteArray):Array
		{
			globalFile = _globalFile;	
			globalFile.position = 0;
			var headLen:Number = firstEightToLong(globalFile);
			var head:ByteArray = new ByteArray();
			globalFile.readBytes(head,0,headLen);
			return getFilesFromHead(head);
		}
		
		private static function getFilesFromHead(ba:ByteArray):Array
		{
			var res:Array = [];
			
			ba.position = 0;
			var pathLen:Number;
			var headerItem:ByteArray;
			while(ba.bytesAvailable)
			{
				var pl:ByteArray = new ByteArray();
				ba.readBytes(pl,0,8);
				pathLen=firstEightToLong(pl);
				headerItem = new ByteArray();
				ba.readBytes(headerItem,0,pathLen+16);
				var fh:FileHandler = convertItemToFileHandler(headerItem);
				globalFile.position = fh.fileStart;
				var file:ByteArray = new ByteArray();
				globalFile.readBytes(file,0,fh.fileSize);
				var f:File = new File(fh.filePath,file);
				res.push(f);
			}
			return res;
		}
		private static function convertItemToFileHandler(ba:ByteArray):FileHandler
		{
			var fh:FileHandler = new FileHandler();
			fh.fileStart = firstEightToLong(ba);
			fh.fileSize = firstEightToLong(ba);
			var path:ByteArray = new ByteArray();
			ba.readBytes(path);
			fh.filePath = path.toString();
			return fh;
		}
		private static function firstEightToLong(_ba:ByteArray):Number 
		{
			var ba:ByteArray = new ByteArray();
			_ba.readBytes(ba,0,8);
						
			var l:Number = 0;
			for (var i:int=0; i<8; i++) {
				l <<= 8;
				l ^= Number (ba[i]) & 0xff;
			}
			return l;
		}
	}
}

class FileHandler{
	public var fileStart:uint , fileSize:uint, filePath:String;
}