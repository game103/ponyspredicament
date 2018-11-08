package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//Class for a path between two nodes
	public class Path extends MovieClip {
		//Variable for 1st node
		private var node1:Node;
		//Variable for 2nd node
		private var node2:Node;
		
		//Constructor
		public function Path(node1:Node, node2:Node) {
			this.node1 = node1;
			this.node2 = node2;
			this.setUp();
		}
		
		//Get the 1st connected node
		public function getNode1():Node {
			return node1;
		}
		
		//Get the second connected node
		public function getNode2():Node {
			return node2;
		}
		
		//Get the distance between the path's two nodes
		public function getDistance():Number {
			return Math.sqrt(Math.pow(node1.x - node2.x, 2) + Math.pow(node1.y - node2.y, 2))
		}
		
		//Returns the angle that the object must be rotated
		public function getAngle():Number {
			//We add 90 since degrees, because flash treats 0 as the vertical axis
			return Math.atan2(node1.y-node2.y,node1.x-node2.x)*(180/Math.PI);
		}

		//This functions sets up the path to have the right place between the two nodes
		public function setUp():void {
			this.x = this.node1.x;
			this.y = this.node1.y;
			
			this.graphics.clear();
			this.graphics.lineStyle(3, 0x003300);
			
			var angle:Number = getAngle();
			var run:Number;
			var rise:Number;
			
			if(angle >= 0) {
				run = (90 - Math.abs(angle-90))/90;
				rise = angle/180 * 2 - 1;
			}
			else if(angle < 0) {
				angle = Math.abs(angle);
				run = -(90 - Math.abs(angle-90))/90;
				rise = angle/180 * 2 - 1;
			}
			
			var xPlus:Number = 0;
			var yPlus:Number = 0;
			
			while(getDistanceCoordinates(xPlus, yPlus) < 4) {
				xPlus += run;
				yPlus += rise;
			}
			
			this.graphics.moveTo(xPlus, yPlus);
			
			this.graphics.beginFill(0x914602);
			this.graphics.lineTo((node2.x - this.x + xPlus),(node2.y - this.y + yPlus));
			this.graphics.lineTo((node2.x - this.x - xPlus),(node2.y - this.y - yPlus));
			this.graphics.lineTo(-xPlus, -yPlus);
			this.graphics.lineTo(xPlus, yPlus);
			this.graphics.endFill();
		}
		
		//This function occurs when the path is clicked
		public function select(event:MouseEvent):void {
			this.visible = false;
		}
		
		//Calculate distance between a point and 0
		public function getDistanceCoordinates(xCo:Number, yCo:Number):Number {
			return Math.sqrt(Math.pow(xCo - 0, 2) + Math.pow(yCo - 0, 2))
		}
	}
	
}
