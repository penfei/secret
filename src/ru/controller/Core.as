package ru.controller {
	
	public class Core {
		private static var _instance:Core;

		private var _game:GameController;
		private var _data:DataController;
		private var _net:NetController;
		private var _ui:UIController;
		private var _terminal:TerminalController;

		public function Core() {

		}

		// static:
		public static function get instance():Core {
			if (!_instance) {
				_instance = new Core;
			}

			return _instance;
		}
		
		public static function get game():GameController {
			return instance._game;
		}

		public static function set game(value:GameController):void {
			instance._game = value;
		}

		public static function get data():DataController {
			return instance._data;
		}

		public static function set data(value:DataController):void {
			instance._data = value;
		}

		public static function get net():NetController {
			return instance._net;
		}

		public static function set net(value:NetController):void {
			instance._net = value;
		}

		public static function get ui():UIController {
			return instance._ui;
		}

		public static function set ui(value:UIController):void {
			instance._ui = value;
		}
		
		public static function get terminal():TerminalController 
		{
			return instance._terminal;
		}
		
		public static function set terminal(value:TerminalController):void {
			instance._terminal = value;
		}
	}
}
