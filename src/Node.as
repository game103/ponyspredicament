package  {
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	//Class for a node with a graph
	public class Node extends MovieClip {
		//True if this is a delivery node and not yet delivered
		private var delivery:Boolean;
		//True if delivery node
		private var deliveryAtOnePoint:Boolean;
		//True if this is the base
		private var base:Boolean;
		//path to root
		private var pathToRoot:Array;
		//nodes to root
		private var nodesToRoot:Array;
		//house number that this house is for
		private var houseNumber:int;
		//node delivery
		//this.nodeDelivery is a movie clip showing whether or not this is a delivery node
		///node building
		//this.nodeBuilding is the building art for this node
		
		//Constructor
		public function Node(delivery:Boolean, base:Boolean, xCoordinate:Number, yCoordinate:Number, existingNodeNums:Array) {
			this.delivery = delivery;
			this.base = base;
			this.x = xCoordinate;
			this.y = yCoordinate;
			this.pathToRoot = new Array();
			this.nodesToRoot = new Array();
			if (!base) {
				while(true) {
					this.nodeBuilding.gotoAndStop(Math.floor(Math.random() * (this.nodeBuilding.totalFrames - 1) + 2));
					this.houseNumber = this.nodeBuilding.currentFrame - 1;
					//check if the house is already on the list
					var br:Boolean = true;
					//trace(this.currentFrame);
					for(var i:int = 0; i < existingNodeNums.length; i++) {
						if(this.houseNumber == existingNodeNums[i]) {
							br = false;
						}
					}
					if(br) {
						break;
					}
				}
			}
			this.nodeDelivery.visible = false;
		}
		
		//Get delivery
		//Returns whether or not this is a delivery node
		public function getDelivery():Boolean {
			return this.delivery;
		}
		
		//Set delivery
		//delivery - boolean to set delivery to
		public function setDelivery(delivery:Boolean):void {
			this.delivery = delivery;
			if(!delivery) {
				this.nodeDelivery.visible = false;
			}
		}
		
		//Get base
		public function getBase():Boolean {
			return this.base;
		}
		
		//Get the distance between this node and another node
		public function getDistance(node:Node):Number {
			return Math.sqrt(Math.pow(node.x - this.x, 2) + Math.pow(node.y - this.y, 2))
		}
		
		//Get the distance between this node and a pair of coordinates
		//Approximates where the center of the node will be by using this nodes width and height
		//This is exact if all nodes have a uniform width and height
		public function getDistanceCoordinates(xCo:int, yCo:int):Number {
			return Math.sqrt(Math.pow(xCo - this.x, 2) + Math.pow(yCo - this.y, 2))
		}

		//Get the angle between this node and a pair of coordinates
		//Approximates where where the center of the node will be by using this nodes width and height
		public function getAngleCoordinates(xCo:int, yCo:int):Number {
			//We add 90 since degrees, because flash treats 0 as the vertical axis
			var number:Number = Math.atan2(yCo - this.y, xCo - this.x)*(180/Math.PI);
			return number;
		}
		
		//Get distance from root
		public function getPathToRoot():Array {
			return this.pathToRoot;
		}
		
		//Set distance from root
		public function setPathToRoot(path:Array):void {
			this.pathToRoot = path;
		}
		
		public function addToPath(path:Path):void {
			this.pathToRoot.push(path);
		}
		
		public function distanceFromRoot():int {
			var total:int = 0;
			for(var i:int = 0; i < this.pathToRoot.length; i ++) {
				total += this.pathToRoot[i].getDistance();
			}
			return total;
		}
		
		public function getNodesToRoot():Array {
			return this.nodesToRoot;
		}
		
		
		public function setNodesToRoot(nodes:Array) {
			this.nodesToRoot = nodes;
		}
		
		public function addNodeToRoot(node:Node):void {
			this.nodesToRoot.push(node);
		}
		
		public function getDeliveryAtOnePoint():Boolean {
			return this.deliveryAtOnePoint;
		}
		
		public function setDeliveryAtOnePoint(delivery:Boolean):void {
			this.deliveryAtOnePoint = delivery;
		}
		
		public function getHouseNumber():int {
			return this.houseNumber;
		}
		
	}
	
}
