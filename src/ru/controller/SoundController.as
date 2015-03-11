package ru.controller {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import sounds.*;

	public class SoundController {
		static private const VOLUME:Number = 1;

		static private var _gameBacksound:SoundChannel = null;
		static private var _lastVolume:Number = VOLUME;
		static private var _volume:Number = _lastVolume;
		
		static private var _sounds:Object;
		
		public function SoundController() {

		}
		
		static public function init(params:Object):void 
		{
			_sounds = {};
			if (params.hasOwnProperty("volume")) _volume = Number(params.volume) / 100;
			if (Core.data.so.data.hasOwnProperty("volume")) _volume = Core.data.so.data.volume;
			Core.data.so.data.volume = _volume;
		}
		
		static public function get lastVolume():Number {
			return _lastVolume;
		}
		
		static public function get volume():Number {
			return _volume;
		}
		
		static public function playWinSound(lineIndex:uint, callBack:Function = null):void {
			var soundClass:Class;
			if (lineIndex == 1) soundClass = winline1;
			if (lineIndex == 2) soundClass = winline2;
			if (lineIndex == 3) soundClass = winline3;
			if (lineIndex == 4) soundClass = winline4;
			if (lineIndex == 5) soundClass = winline5;
			if (lineIndex == 6) soundClass = winline6;
			if (lineIndex == 7) soundClass = winline7;
			if (lineIndex == 8) soundClass = winline8;
			if (lineIndex == 9) soundClass = winline9;
			if (soundClass == null) soundClass = winline;
			var sound:Sound = new soundClass;
			playSound(soundClass, callBack);
		}
		
		static private function hasOnlyWild(comb:Vector.<uint>):Boolean {
			for each (var item:uint in comb) 
			{
				if (item != DataController.WILD) return false;
			}
			return true;
		}
		
		static public function playLoopSound(sound:Class, repeatCount:int, callBack:Function = null):void {
			if (repeatCount <= 0) {
				if (callBack != null) callBack();
			} else {
				repeatCount--;
				var channel:SoundChannel = new sound().play(0, 0, new SoundTransform(_volume));
				_sounds[sound] = channel;
				channel.addEventListener(Event.SOUND_COMPLETE, function soundCompleteHandler(e:Event):void {
					delete _sounds[sound];
					channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
					playLoopSound(sound, repeatCount, callBack);
				});
			}
		}
		
		static public function playSound(sound:Class, callBack:Function = null):void {
			var channel:SoundChannel = new sound().play(0, 0, new SoundTransform(_volume));
			_sounds[sound] = channel;
			channel.addEventListener(Event.SOUND_COMPLETE, function soundCompleteHandler(e:Event):void {
				delete _sounds[sound];
				channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				if (callBack != null) callBack();
			});
		}
		
		static public function stopSound(sound:Class, callBack:Function = null):void {
			if(_sounds.hasOwnProperty(sound)){
				_sounds[sound].stop();
				delete _sounds[sound];
				if (callBack != null) callBack();
			}
		}
		
		static public function playBacksound(sound:Class, start:uint = 0):void {
			stopBacksound();
			_gameBacksound = new sound().play(start, int.MAX_VALUE, new SoundTransform(_volume));
		}
		
		static public function stopBacksound():void {
			if (_gameBacksound != null) _gameBacksound.stop();
		}

		static public function switchVolume(value:Number, isSave:Boolean = true):void {
			_lastVolume = _volume;
			_volume = value;
			if(isSave) Core.data.so.data.volume = _volume;
			var sound:SoundTransform = new SoundTransform(_volume);
			for each(var chanel:SoundChannel in _sounds) {
				chanel.soundTransform = sound;
			}
			if (_gameBacksound != null) _gameBacksound.soundTransform = sound;
		}
		
	}

}
