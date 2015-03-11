package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import ru.gui.View;
	
	/**
	 * ...
	 * @author romsvm
	 */
	public class PreloaderLines extends View
	{
		//--------------------------------------------------------------------------
		//
		//  Class constructor
		//
		//--------------------------------------------------------------------------
		public function PreloaderLines():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function destroy():void 
		{
			_timer.stop();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var _boids:Vector.<Boid>;
		private var _flockCenter:Vector2D = new Vector2D();
		private var _percievedCenter:Vector2D = new Vector2D();
		private var _percievedVelocity:Vector2D = new Vector2D();
		private var _points:Vector.<Vector2D>;
		private var _shapes:Vector.<Shape> = new Vector.<Shape>();
		private var _shapeIndex:uint = 0;
		private var _size:uint = 1;
		private var _speed:uint = 10;
		private var _timer:Timer;
		private var _totalBoids:uint = 7;
		private var _vectorDefault:Vector2D = new Vector2D();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			for (var i:uint = 0; i < 150; i++) {
				var shape:Shape = new Shape();
				_shapes.push(shape);
				addChild(shape);
			}
			
			_boids = new Vector.<Boid>();
			_points = new Vector.<Vector2D>();
			
			for (i = 0; i < _totalBoids; i++)
			{
				var boid:Boid = new Boid(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight, new Vector2D(Math.random() * 2 - 1, Math.random() * 2 - 1))
				_boids.push(boid);
			}
			
			_timer = new Timer(40, 0);
			_timer.addEventListener(TimerEvent.TIMER, update);
			_timer.start();
		}
		
		private function calculateDistance(obj1:Object, obj2:Object):Number
		{
			var dx:Number = obj1.x - obj2.x;
			var dy:Number = obj1.y - obj2.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			
			return dist;
		}
		
		private function checkWallCollisions(index:uint):void
		{
			if (_boids[index].x > stage.stageWidth)
			{
				_boids[index].x = 0;
			}
			else if (_boids[index].x < 0)
			{
				_boids[index].x = stage.stageWidth;
			}
			
			if (_boids[index].y > stage.stageHeight)
			{
				_boids[index].y = 0;
			}
			else if (_boids[index].y < 0)
			{
				_boids[index].y = stage.stageHeight;
			}
		}
		
		private function addForce(index:uint, force:Vector2D):void
		{
			var boid:Boid = _boids[index];
			
			boid.v.x += force.x;
			boid.v.y += force.y;
			
			var magnitude:Number = calculateDistance(_vectorDefault, boid.v);
			boid.v.x = boid.v.x / magnitude;
			boid.v.y = boid.v.y / magnitude;
		}
		
		private function applyForces(index:uint):void
		{
			var count:uint = 0;
			
			_flockCenter.x = 0;
			_flockCenter.y = 0;
			_percievedCenter.x = 0;
			_percievedCenter.y = 0;
			_percievedVelocity.x = 0;
			_percievedVelocity.y = 0;
			
			for (var i:int = 0; i < _boids.length; i++)
			{
				if (i != index)
				{
					var dist:Number = calculateDistance(_boids[index], _boids[i]);
					
					if (dist > 0 && dist < 50)
					{
						count++;
						
						_percievedCenter.x += _boids[i].x;
						_percievedCenter.y += _boids[i].y;
						
						_percievedVelocity.x += _boids[i].v.x;
						_percievedVelocity.y += _boids[i].v.y;
						
						if (dist < 10)
						{
							_flockCenter.x -= (_boids[i].x - _boids[index].x);
							_flockCenter.y -= (_boids[i].y - _boids[index].y);
						}
					}
				}
			}
			
			if (count > 0)
			{
				_percievedCenter.x = (_percievedCenter.x - _boids[index].x) / 400;
				_percievedCenter.y = (_percievedCenter.y - _boids[index].y) / 400;
				
				_percievedVelocity.x = _percievedVelocity.x / count;
				_percievedVelocity.y = _percievedVelocity.y / count;
				
				_flockCenter.x /= count;
				_flockCenter.y /= count;
			}
			
			addForce(index, _percievedCenter);
			
			addForce(index, _percievedVelocity);
			
			addForce(index, _flockCenter);
		}
		
		private function update(event:TimerEvent):void
		{
			_shapeIndex++;
			if (_shapeIndex == _shapes.length) _shapeIndex = 0;
			_shapes[_shapeIndex].graphics.clear();
			
			for (var i:int = 0; i < _boids.length; i++)
			{
				//_shape.graphics.lineStyle(1, 0, 0.5);
				//_shape.graphics.moveTo(_boids[i].x, _boids[i].y);
				
				_boids[i].x += _boids[i].v.x * _speed;
				_boids[i].y += _boids[i].v.y * _speed;
				
				applyForces(i);
				
				//_shape.graphics.lineTo(_boids[i].x, _boids[i].y);
				
				if (_points.length < 300)
				{
					_points.push(new Vector2D(_boids[i].x, _boids[i].y));
				}
				else
				{
					var vector:Vector2D = _points.shift();
					vector.x = _boids[i].x;
					vector.y = _boids[i].y;
					_points.push(vector);
				}
				
				_shapes[_shapeIndex].graphics.lineStyle(1, 0xFFFFFF, 0.1);
				
				var pointsLength:uint = _points.length;
				for (var j:uint = 0; j < pointsLength; j++)
				{
					var dx:Number = _points[j].x - _points[pointsLength - 1].x;
					var dy:Number = _points[j].y - _points[pointsLength - 1].y;
					var distSQ:Number = dx * dx + dy * dy;
					
					if (distSQ < 2500 && Math.random() > 0.9)
					{
						_shapes[_shapeIndex].graphics.moveTo(_points[pointsLength - 1].x, _points[pointsLength - 1].y);
						_shapes[_shapeIndex].graphics.lineTo(_points[j].x, _points[j].y);
					}
				}
				
				checkWallCollisions(i);
				
			}
			
			//_canvasBD.draw(_shape);
		}
	}
}

class Boid
{
	
	public function Boid(x:Number, y:Number, v:Vector2D)
	{
		_x = x;
		_y = y;
		_v = v;
	}
	
	private var _x:Number;
	private var _y:Number;
	private var _v:Vector2D;
	
	public function get x():Number
	{
		return _x;
	}
	
	public function set x(value:Number):void
	{
		_x = value;
	}
	
	public function get y():Number
	{
		return _y;
	}
	
	public function set y(value:Number):void
	{
		_y = value;
	}
	
	public function get v():Vector2D
	{
		return _v;
	}

}

class Vector2D
{
	
	public function Vector2D(x:Number = 0, y:Number = 0)
	{
		_x = x;
		_y = y;
	}
	
	private var _x:Number;
	private var _y:Number;
	
	public function get x():Number
	{
		return _x;
	}
	
	public function set x(value:Number):void
	{
		_x = value;
	}
	
	public function get y():Number
	{
		return _y;
	}
	
	public function set y(value:Number):void
	{
		_y = value;
	}

}