package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	//Class for a graph
	public class Graph extends MovieClip {
		//Variable for the player within the graph
		private var player:Player;
		//Variable to contain the nodes that the player can visit from here
		private var nodesPlayerFromHere:Array;
		//Variable to contain the click functions from here
		private var nodesFromHereFunctions:Array;
		//text box for how many parcels the player has delivered
		private var playersParcelsDeliveredTextBox:TextField;
		//text box for original number of parcels to deliver
		private var playersParcelsToDeliverTextBox:TextField;
		//text box for the maximum number of parcels in bag
		private var playersMaximumParcelsInBagTextBox:TextField;
		//text box for how many parcels the player has in bag
		private var playersParcelsInBagTextBox:TextField;
		//text box for distance traveled
		private var playersDistanceTraveledTextBox:TextField;
		//textBox for computers distance
		private var computersDistanceTextBox:TextField;
		//The list of house names to deliver to
		//Detracted from upon delivery
		private var deliveryList:Array;
		//The list of current frame numbers of each of the houses
		//Only using in generation
		private var houseFrameNumbers:Array;
		//variable for whether or not the game is finished
		private var finished:Boolean;
		
		//Sound functions
		private var playDeliver:Function;
		private var playMoving:Function;
		private var stopMoving:Function;
		
		//Array for the nodes
		private var nodes:Array;
		//Array for the edges
		private var edges:Array;
		//Array for the route (nodes)
		private var nodeRoute:Array;
		//Array for the route (edges)
		private var edgeRoute:Array;
		//Boolean to determine whether or not the graph is connected yet (used for generation)
		private var connected:Boolean;
		//The calculated shortest distance to complete the game for the current graph
		private var shortestDistance:int;
		//max x coordinate of items in the graph
		private var graphWidth:int;
		//max y coordinate of items in the graph
		private var graphHeight:int;
		//number of parcels that must be delivered
		private var numParcels:int;
		//number of parcels that have already been delivered
		private var numParcelsAlreadyDelivered:int;
		
		//Variables for the animation of the player
		var xDistanceAway:Number;
		var yDistanceAway:Number;
		var xSpeed:Number;
		var ySpeed:Number;
		
		//Functions to occur once won or lost
		var wonFunction:Function;
		var lostFunction:Function;
		
		//CONSTANTS
		private var MIN_DISTANCE_BETWEEN_NODES:int = 100;
		private var MIN_ANGLE_DISTANCE:int = 5;
		private var MAX_PARCELS = 3;
		private var PLAYER_SPEED = 3;
		

		//Constructor
		//Takes the width and height of the graph
		public function Graph(graphWidth:int, graphHeight:int, numParcels:int, nodes:int, edges:int, minDistance:int, minAngle:int, maxParcels:int, playerSpeed:int, wonFunction:Function, lostFunction:Function, playersParcelsInBagTextBox:TextField, playersDistanceTraveledTextBox:TextField, computersDistanceTextBox:TextField, playersParcelsDeliveredTextBox:TextField, playersParcelsToDeliverTextBox:TextField, playersMaximumParcelsInBagTextBox:TextField, playDeliver:Function, playMoving:Function, stopMoving:Function) {
			trace("#######################NEW################");
			//Set the constants to what was specified
			this.MIN_DISTANCE_BETWEEN_NODES = minDistance;
			this.MIN_ANGLE_DISTANCE = minAngle;
			this.MAX_PARCELS = maxParcels;
			this.PLAYER_SPEED = playerSpeed;
			
			this.playersParcelsInBagTextBox = playersParcelsInBagTextBox;
			this.playersDistanceTraveledTextBox = playersDistanceTraveledTextBox;
			this.computersDistanceTextBox = computersDistanceTextBox;
			this.playersParcelsDeliveredTextBox = playersParcelsDeliveredTextBox;
			this.playersParcelsToDeliverTextBox = playersParcelsToDeliverTextBox;
			this.playersMaximumParcelsInBagTextBox = playersMaximumParcelsInBagTextBox;
			
			this.graphWidth = graphWidth;
			this.graphHeight = graphHeight;
			this.x = 0;
			this.y = 0;
			this.numParcels = numParcels;
			this.nodes = new Array();
			this.edges = new Array();
			this.deliveryList = new Array();
			this.houseFrameNumbers = new Array();
			
			this.playDeliver = playDeliver;
			this.playMoving = playMoving;
			this.stopMoving = stopMoving;
			
			this.wonFunction = wonFunction;
			this.lostFunction = lostFunction;
			
			//Generation
			this.generate(nodes, edges, numParcels);
			//Min spanning tree
			var tree:Array = this.minSpanningTree();
			this.edgeRoute = new Array();
			this.nodeRoute = new Array();
			//Cycle (sets edgeRoute and NodeRoute)
			this.depthFirstSearch(this.nodes[0], tree, new Array(), null, new Array());
			//Alteration for needing to return to base (alters nodeRoute)
			this.alterForMaxParcels();
			//Gets Edge Route from the min spanning tree and new nodeRoute (recreates edgeRoute and sets ShortestDistance)
			this.calculateEdgeRouteFromNodeRoute(tree);
			
			//Update the text box to show the computers calculated distance
			this.computersDistanceTextBox.text = this.shortestDistance.toString();
			//Update the text box to show the maximum parcels a player can have
			this.playersMaximumParcelsInBagTextBox.text = this.MAX_PARCELS.toString();
			
			trace(this.shortestDistance);
			
			this.startGame();
			
			/*this.current = 0;
			this.t = 30;
			this.addEventListener(Event.ENTER_FRAME, animate);*/
		}
		
		//THE FOLLOWING FUNCTIONS ARE TO DO WITH PLAYING THE GAME
		
		//function to call to start the game
		public function startGame() {
			if(player != null) {
				if(this.player.getNode() != null) {
					//Remove previous event listener
					if(this.player.getNode().getDelivery()) {
						this.player.getNode().nodeDelivery.removeEventListener(MouseEvent.CLICK, deliverAParcel);
						this.player.getNode().nodeDelivery.visible = false;
					}
					//Remove all event listeners from nodes that were previously available
					for(var n:int = 0; n < this.nodesPlayerFromHere.length; n++) {
						this.nodesPlayerFromHere[n].removeEventListener(MouseEvent.CLICK, this.nodesFromHereFunctions[n]);
						//remove filters
						this.nodesPlayerFromHere[n].filters = undefined;
						//remove rollover effects
						this.nodesPlayerFromHere[n].removeEventListener(MouseEvent.ROLL_OVER, this.changeCursorOver);
						this.nodesPlayerFromHere[n].removeEventListener(MouseEvent.ROLL_OUT, this.changeCursorOut);
					}
					this.player.removeEventListener(Event.ENTER_FRAME, animateChangeOfPosition);
				}
				this.removeChild(player);
			}
			this.finished = false;
			//options for clicking
			this.nodesPlayerFromHere = new Array();
			this.nodesFromHereFunctions = new Array();
			//reset nodes to deliver to
			for(var i:int = 0; i < this.nodes.length; i ++) {
				if(this.nodes[i].getDeliveryAtOnePoint()) {
					this.nodes[i].setDelivery(true);
				}
			}
			//new player
			this.player = new Player(this.MAX_PARCELS);
			this.addChild(player);
			
			//set the delivery list
			this.deliveryList = new Array();
			for(i = 0; i < this.nodes.length; i ++) {
				if(this.nodes[i].getDelivery()) {
					this.deliveryList.push(nodes[i].nodeBuilding.houseName);
				}
			}
			
			this.numParcelsAlreadyDelivered = 0;
			
			//update text box showing player's parcels in bag
			this.playersParcelsInBagTextBox.text = this.player.getParcels().toString();
			//update text box showing player's parecels needed to deliver
			this.playersParcelsToDeliverTextBox.text = this.numParcels.toString();
			//set the number of parcels deliverted textbox to 0
			this.playersParcelsDeliveredTextBox.text = "0";
			
			//set position
			this.player.x = this.nodes[0].x;
			this.player.y = this.nodes[0].y;
			//stop the horse
			this.player.horse.stop();
			
			this.changePlayerPosition(this.nodes[0]);
		}
		
		//function to change the cursor upon rollover
		private function changeCursorOver(event:MouseEvent) {
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		//function to change the cursor upon rollout
		private function changeCursorOut(event:MouseEvent) {
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		//function to check if the cursor is already over an object
		private function detectMouseOver(displayObject:DisplayObject) {
			var mousePoint:Point = displayObject.localToGlobal(new Point(displayObject.mouseX,displayObject.mouseY));
    		return displayObject.hitTestPoint(mousePoint.x,mousePoint.y,true);
		}
		
		//function to calculate speed
		//returns the totalDistance Away
		private function calculateSpeed():Number {
			xDistanceAway = this.player.getNode().x - this.player.x;
			yDistanceAway = this.player.getNode().y - this.player.y;
			//pythagoreum theorum
			var totalDistanceAway:Number = Math.sqrt(Math.pow(xDistanceAway, 2) + Math.pow(yDistanceAway,2));
			xSpeed = (this.PLAYER_SPEED * xDistanceAway/totalDistanceAway);
			ySpeed = (this.PLAYER_SPEED * yDistanceAway/totalDistanceAway);
			
			return totalDistanceAway;
		}
		
		//function to animate changing position
		//includes events that occur when a player reaches the destination node
		public function animateChangeOfPosition(event:Event) {
			this.player.horse.play();
			
			var done:Boolean = true;
			
			if( (this.player.x < this.player.getNode().x && this.xSpeed > 0) || (this.player.x > this.player.getNode().x && this.xSpeed < 0) ) {
				this.player.x += this.xSpeed;
				done = false;
			}
			else {
				this.player.x = this.player.getNode().x;
			}
			if( (this.player.y < this.player.getNode().y  && this.ySpeed > 0) || (this.player.y > this.player.getNode().y  && this.ySpeed < 0) ) {
				this.player.y += this.ySpeed;
				done = false;
			}
			else {
				this.player.y = this.player.getNode().y;
			}
			
			var totalDistanceAway = calculateSpeed();
			
			//if we are close enough just snap
			if(totalDistanceAway <= this.PLAYER_SPEED) {
				this.player.x = this.player.getNode().x;
				this.player.y = this.player.getNode().y;
				done = true;
			}
			
			//dynamically update text box
			//maybe change this for efficiency later
			if((int(this.playersDistanceTraveledTextBox.text) + this.PLAYER_SPEED) < this.player.getDistanceTraveled()) {
				this.playersDistanceTraveledTextBox.text = (int(this.playersDistanceTraveledTextBox.text) + this.PLAYER_SPEED).toString();
			}
			
			if(done) {
				//stop sound
				this.stopMoving();
				
				this.player.horse.stop();
				this.player.rotation = 0;
				
				this.player.removeEventListener(Event.ENTER_FRAME, animateChangeOfPosition);
				this.playersDistanceTraveledTextBox.text = this.player.getDistanceTraveled().toString();
				
				
				//If lost, fail
				if(this.player.getDistanceTraveled() > this.shortestDistance) {
					if(!finished) {
						this.lostFunction();
						trace("Unlucky!");
						finished = true;
						return;
					}
				}
				//If at the root, restock parcels and check if won
				if(this.player.getNode() == this.nodes[0]) {
					this.player.setParcels(this.MAX_PARCELS);
					//Update the text box to show the maximum parcels a player can have
					this.playersParcelsInBagTextBox.text = this.MAX_PARCELS.toString();
					if(this.numParcels == this.numParcelsAlreadyDelivered) {
						if(!finished) {
							finished = true;
							this.wonFunction();
							trace("Congratulations!");
							trace(this.player.getDistanceTraveled());
							return;
						}
					}
				}
				
				//Create the glow effect
				var glow:GlowFilter = new GlowFilter();
				glow.color = 0x006600;
				glow.quality = BitmapFilterQuality.HIGH;
				//Add event listeners
				for(var i:int = 0; i < this.edges.length; i++) {
					if(this.edges[i].getNode1() == this.player.getNode()) {
						//add glow
						this.edges[i].getNode2().filters = [glow];
						//add rollover
						this.edges[i].getNode2().addEventListener(MouseEvent.ROLL_OVER, this.changeCursorOver);
						this.edges[i].getNode2().addEventListener(MouseEvent.ROLL_OUT, this.changeCursorOut);
						//change cursor if already over
						if(this.detectMouseOver(this.edges[i].getNode2())) {
							Mouse.cursor = MouseCursor.BUTTON;
						}
						
						this.nodesPlayerFromHere.push(this.edges[i].getNode2());
						this.nodesFromHereFunctions.push(clickToMove(this.edges[i].getNode2(), this.changePlayerPosition));
						this.edges[i].getNode2().addEventListener(MouseEvent.CLICK, this.nodesFromHereFunctions[this.nodesPlayerFromHere.length-1]);
					}
					if(this.edges[i].getNode2() == this.player.getNode()) {
						//add glow
						this.edges[i].getNode1().filters = [glow];
						//add rollover
						this.edges[i].getNode1().addEventListener(MouseEvent.ROLL_OVER, this.changeCursorOver);
						this.edges[i].getNode1().addEventListener(MouseEvent.ROLL_OUT, this.changeCursorOut);
						//change cursor if already over
						if(this.detectMouseOver(this.edges[i].getNode1())) {
							Mouse.cursor = MouseCursor.BUTTON;
						}
						
						this.nodesPlayerFromHere.push(this.edges[i].getNode1());
						this.nodesFromHereFunctions.push(clickToMove(this.edges[i].getNode1(), this.changePlayerPosition));
						this.edges[i].getNode1().addEventListener(MouseEvent.CLICK, this.nodesFromHereFunctions[this.nodesPlayerFromHere.length-1]);
					}
				}
				
				//Add delivery event listener
				if(this.player.getNode().getDelivery() && this.player.getParcels() > 0) {
					this.player.getNode().nodeDelivery.addEventListener(MouseEvent.CLICK, deliverAParcel);
					//bring the node and the player to front
					this.setChildIndex(this.player.getNode(), this.numChildren - 1);
					this.setChildIndex(this.player, this.numChildren - 1);
					this.player.getNode().nodeDelivery.visible = true;
				}
				
			}
			
		}
		
		//function to change player's position
		public function changePlayerPosition(node:Node) {
			//Remove all event listeners from nodes that were previously available
			for(var i:int = 0; i < this.nodesPlayerFromHere.length; i++) {
				this.nodesPlayerFromHere[i].removeEventListener(MouseEvent.CLICK, this.nodesFromHereFunctions[i]);
				//remove filters
				this.nodesPlayerFromHere[i].filters = undefined;
				//remove rollover effects
				this.nodesPlayerFromHere[i].removeEventListener(MouseEvent.ROLL_OVER, this.changeCursorOver);
				this.nodesPlayerFromHere[i].removeEventListener(MouseEvent.ROLL_OUT, this.changeCursorOut);
			}
			
			//Change the cursor
			Mouse.cursor = MouseCursor.AUTO;
			
			this.nodesPlayerFromHere = new Array();
			this.nodesFromHereFunctions = new Array();
			
			//Get the distance traveled and add it
			//if this is the first node, we don't need to add any distance
			if(this.player.getNode() != null) {
				for(i = 0; i < this.edges.length; i++) {
					if( (this.edges[i].getNode1() == this.player.getNode() && this.edges[i].getNode2() == node) || (this.edges[i].getNode2() == this.player.getNode() && this.edges[i].getNode1() == node) ) {
						this.player.addToDistanceTraveled(Math.round(this.edges[i].getDistance()));
					}
				}
			}
			
			if(this.player.getNode() != null) {
				//Remove previous event listener
				if(this.player.getNode().getDelivery()) {
					this.player.getNode().nodeDelivery.removeEventListener(MouseEvent.CLICK, deliverAParcel);
					this.player.getNode().nodeDelivery.visible = false;
				}
			}
			
			//set the player's current node to this node
			this.player.setNode(node);
			
			//set the players rotation
			this.player.scaleX = 1;
			var pRotation:Number = this.player.getNode().getAngleCoordinates(this.player.x, this.player.y);
			if(pRotation > 90) {
				pRotation -= 180;
				this.player.scaleX = -1;
			}
			if(pRotation < -90) {
				pRotation += 180;
				this.player.scaleX = -1;
			}
			//reupdate the view of what the horse is carrying
			this.player.setParcels(this.player.getParcels());
			this.player.rotation = pRotation;
			
			this.calculateSpeed();
			
			//play sound
			this.playMoving();
			
			this.player.addEventListener(Event.ENTER_FRAME, animateChangeOfPosition);
		}
		
		//generates on click functions for a node
		public function clickToMove(node:Node, func:Function):Function {
			return function(e:MouseEvent):void {
				func(node);
				//stops ancestors from receiving the event.
				e.stopImmediatePropagation();
			};
		}
		
		//Deliver listener
		public function deliverAParcel(event:MouseEvent) {
			if(this.player.getParcels() > 0) {
				this.playDeliver();
				this.player.getNode().setDelivery(false);
				this.player.setParcels(this.player.getParcels() - 1);
				//update text box
				this.playersParcelsInBagTextBox.text = this.player.getParcels().toString();
				//update parcels delivered
				this.numParcelsAlreadyDelivered += 1;
				//Set the number of parcels to player has delivered text box
				this.playersParcelsDeliveredTextBox.text = this.numParcelsAlreadyDelivered.toString();
				//remove the item from the delivery list
				var newDeliveryList:Array = new Array();
				for(var i:int = 0; i < this.deliveryList.length; i++) {
					if(this.player.getNode().nodeBuilding.houseName != this.deliveryList[i]) {
						newDeliveryList.push(this.deliveryList[i]);
					}
				}
				this.deliveryList = newDeliveryList;
				//remove the event listener
				event.currentTarget.removeEventListener(event.type, deliverAParcel);
			}
			//stops ancestors from receiving the event.
			event.stopImmediatePropagation();
		}
		
		//END FUNCTIONS FOR PLAYING THE GAME
		
		//function to animate an array of edges
		/*public function animate(event:Event) {
			if(current < this.edgeRoute.length) {
				this.edgeRoute[current].alpha = 0;
				this.t --;
				if(this.t <= 0) {
					this.edgeRoute[current].alpha = 1;
					this.current +=1;
					this.t = 30;
				}
			}
			
		}*/
		
		
		//Function to connect two nodes
		//Essentially just adds an edge in the edge list
		public function connectNodes(node1:Node, node2:Node) {
			var path:Path = new Path(node1, node2);
			this.edges.push(path);
			//for display
			this.addChild(path);
		}
		
		//Function too add a node
		public function addNode(node:Node) {
			this.nodes.push(node);
			if(!node.getBase()) {
				this.houseFrameNumbers.push(node.getHouseNumber());
			}
		}
		
		//Function to generate an edgeRoute from a nodeRoute
		//Also sets shortestDistance
		public function calculateEdgeRouteFromNodeRoute(tree:Array):void {
			this.shortestDistance = 0;
			this.edgeRoute = new Array();
			//go through each pair of nodes
			for(var i:int = 0; i < this.nodeRoute.length - 1; i++) {
				//find the edge corresponding to the current node
				for(var p:int = 0; p < tree.length; p ++) {
					if( (tree[p].getNode1() == this.nodeRoute[i] && tree[p].getNode2() == this.nodeRoute[i+1])|| (tree[p].getNode2() == this.nodeRoute[i] && tree[p].getNode1() == this.nodeRoute[i+1]) ) {
						this.edgeRoute.push(tree[p]);
						this.shortestDistance += Math.round(tree[p].getDistance());
					}
					
				}
			}
		}
		
		
		//This alters the nodeRoute for returns to the base
		//Returns will occur if a parcels run out, or if parcels will run out and we are currently the shortest distance
		//away from the root we will be before parcels run out and an extra trip is not added
		public function alterForMaxParcels():void {
			var foundARoute:Boolean = false;
				
			var parcelsToDeliver:int = this.numParcels;
			var parcelsInBag:int = this.MAX_PARCELS;
			
			var shortestDistanceAway:int = 100000;
			var nodeToReturnOn:Node;
			var edgeToReturnOn:Path;
			var locToSplice:int;
			
			var returnToStart:Boolean = false;
			
			var deliveredNodes:Array = new Array();
			
			var naturalNumberOfReturnsToRoot:Number = 0;
			for(var n:int = 1; n < this.nodeRoute.length - 1; n ++) {
				if(this.nodeRoute[n].getBase()) {
					naturalNumberOfReturnsToRoot += 1;
				}
			}
			
			var i:int = 1;
			while(i < this.nodeRoute.length) {
				if(returnToStart) {
					var edgesToAdd:Array = new Array();
					var nodesToAdd:Array = new Array();
					
					if(this.nodeRoute[i].distanceFromRoot() > this.nodeRoute[i-1].distanceFromRoot()) {
						//Calculate the nodes to add
						for(var p:int = 1; p<this.nodeRoute[i].getNodesToRoot().length; p ++) {
							nodesToAdd.push(this.nodeRoute[i].getNodesToRoot()[p]);
						}
						
						for(p = 2; p<this.nodeRoute[i].getNodesToRoot().length+1; p ++) {
							nodesToAdd.push(this.nodeRoute[i].getNodesToRoot()[this.nodeRoute[i].getNodesToRoot().length-p]);
						}
						
						for(p = 0; p < nodesToAdd.length; p++) {
							this.nodeRoute.splice(i+p, 0, nodesToAdd[p]);
						}
						
						parcelsInBag = this.MAX_PARCELS;
						i += nodesToAdd.length;
						returnToStart = false;
						continue;
					}
					
					
				}
				
				if(this.nodeRoute[i].getDelivery() && !this.inArray(this.nodeRoute[i], deliveredNodes)) {
					parcelsToDeliver --;
					parcelsInBag --;
					deliveredNodes.push(this.nodeRoute[i]);
				}
				//restock if on base
				if(this.nodeRoute[i].getBase()) {
					parcelsInBag = this.MAX_PARCELS;
					shortestDistanceAway = 100000;
				}
				
				if(!returnToStart) {
					returnToStart = true;
					//Check to see if it is worth going back
					if(parcelsInBag > 0) {
						var fewestTrips:Number = Math.ceil((parcelsToDeliver-parcelsInBag)/this.MAX_PARCELS);
						var tripsNow:Number = Math.ceil((parcelsToDeliver)/this.MAX_PARCELS);
						if(fewestTrips < tripsNow) {
							returnToStart = false;
						}
						
						if(returnToStart) {
							var myDistance:Number = this.nodeRoute[i].distanceFromRoot();
							p = 1
							var stoppingPoint:Number = parcelsInBag + 1;
							var deliveredNodesCopy:Array = new Array();
							for(var q:int = 0; q < deliveredNodes.length; q++){
								deliveredNodesCopy.push(deliveredNodes[q]);
							}
							while(p <= stoppingPoint) {
								if(i+p >= this.nodeRoute.length) {
									returnToStart = false;
									break;
								}
								//Check to see if the next <numParcelsLeftInBag> nodes are root
								if(this.nodeRoute[i+p].getBase()) {
									returnToStart = false;
									break;
								}
								//Check and see if any of these nodes are closer
								if(this.nodeRoute[i+p].distanceFromRoot() < myDistance) {
									returnToStart = false;
									break;
								}
								//If the node in question needs to be delivered to, then we don't increase stopping point
								//as we would lose a parcel there
								if(!(this.nodeRoute[i+p].getDelivery() && !inArray(this.nodeRoute[i+p], deliveredNodesCopy))) {
									stoppingPoint += 1;
								}
								else {
									deliveredNodesCopy.push(this.nodeRoute[i+p]);
								}
								p++;
							}
						}
					}
				}
				
				i++;
			}
		}
		
		
		//Perform a Depth first search recursively
		//Returns the node route
		//Also sets the edge route however
		private function depthFirstSearch(node:Node, edgeList:Array, routeToRoot:Array, edge:Path, edgeRouteToRoot:Array):void {
			this.nodeRoute.push(node);
			routeToRoot = routeToRoot.concat();
			routeToRoot.push(node);
			edgeRouteToRoot = edgeRouteToRoot.concat();
			if(edge != null) {
				edgeRouteToRoot.push(edge);
			}
			for(var i:int = 0; i < edgeList.length; i ++) {
				if(edgeList[i].getNode1() == node) {
					if(!inArray(edgeList[i].getNode2(), this.nodeRoute)) {
						depthFirstSearch(edgeList[i].getNode2(), edgeList, routeToRoot, edgeList[i], edgeRouteToRoot);
						this.edgeRoute.push(edgeList[i]);
						this.nodeRoute.push(node);
					}
				}
				else if(edgeList[i].getNode2() == node) {
					if(!inArray(edgeList[i].getNode1(), this.nodeRoute)) {
						depthFirstSearch(edgeList[i].getNode1(), edgeList, routeToRoot, edgeList[i], edgeRouteToRoot);
						this.edgeRoute.push(edgeList[i]);
						this.nodeRoute.push(node);
					}
				}
			}
			routeToRoot.pop();
			node.setNodesToRoot(routeToRoot.reverse());
			node.setPathToRoot(edgeRouteToRoot.reverse());
		}
		
		
		//Generate a minimum cost spanning tree for all delivery nodes on this graph
		//We use prims algorithm to get a min spanning tree for all nodes
		//Then, we look at the nodes in the tree, and see if they or any of their children are delivery nodes
		//If they are not delivery nodes, we remove them from the tree
		public function minSpanningTree():Array {
			var treeEdgeList:Array = new Array();
			var treeNodeList:Array = new Array();
			var rootNode:Node = this.nodes[0];
			treeNodeList.push(rootNode);
			while(treeNodeList.length != this.nodes.length) {
				var minEdge:Path;
				var newNode:Node;
				var minDistance:int = 1000000;
				//For each edge
				for(var i:int = 0; i < this.edges.length; i++) {
					//if the edges is not in the treeEdgeList already
					if(!inArray(this.edges[i],treeEdgeList)) {
						//if one of its nodes is in the node list and the other is not
						if(inArray(this.edges[i].getNode1(), treeNodeList) && !inArray(this.edges[i].getNode2(), treeNodeList)) {
							//if the edges distance is less than min distance
							if(this.edges[i].getDistance() < minDistance) {
								//this is the new min edge
								minEdge = this.edges[i];
								minDistance = this.edges[i].getDistance();
								newNode = this.edges[i].getNode2();
							}
						}
						else if(!inArray(this.edges[i].getNode1(), treeNodeList) && inArray(this.edges[i].getNode2(), treeNodeList)) {
							//if the edges distance is less than min distance
							if(this.edges[i].getDistance() < minDistance) {
								//this is the new min edge
								minEdge = this.edges[i];
								minDistance = this.edges[i].getDistance();
								newNode = this.edges[i].getNode1();
							}
						}
					}
				}
				//Now we add the min edge
				treeNodeList.push(newNode);
				treeEdgeList.push(minEdge);
			}
			var newTree:Array = checkDelivery(this.nodes[0], treeEdgeList);
			
			return newTree;
		}
		
		//function to be called recursively
		//Takes a root node and edge list
		//Looks at all possible children nodes from the given edge list
		//If the children nodes are delivery nodes or they are parent's of delivery nodes, they are added to the path list that
		//this function returns
		private function checkDelivery(rootNode:Node, edgeList:Array):Array {
			var newEdgeList:Array = new Array();
			var nodesToInspect:Array = new Array();
			var edgesCorrespondingToNodesToInspect:Array = new Array();
			for(var i:int = 0; i < edgeList.length; i ++) {
				if(edgeList[i].getNode1() == rootNode) {
					nodesToInspect.push(edgeList[i].getNode2());
					edgesCorrespondingToNodesToInspect.push(edgeList[i]);
				}
				else if(edgeList[i].getNode2() == rootNode) {
					nodesToInspect.push(edgeList[i].getNode1());
					edgesCorrespondingToNodesToInspect.push(edgeList[i]);
				}
				else {
					newEdgeList.push(edgeList[i]);
				}
			}
			var newTree:Array = new Array();
			//look at all paths from root in edge list
			for(i = 0; i < nodesToInspect.length; i ++) {
				var tempTree:Array = checkDelivery(nodesToInspect[i], newEdgeList);
				if(tempTree.length > 0) {
					tempTree.push(edgesCorrespondingToNodesToInspect[i]);
					newTree = newTree.concat(tempTree);
				}
				else if(nodesToInspect[i].getDelivery()) {
					tempTree.push(edgesCorrespondingToNodesToInspect[i]);
					newTree = newTree.concat(tempTree);
				}
			}
			
			return newTree;
		}
		
		//function to check if an element is in an array
		private function inArray(element:*, array:Array) {
			return (array.indexOf(element) >= 0);
		}
		
		//Randonmly generates a connected graph the conforms to the given parameters
		public function generate(numNodes:int, numPaths:int, numDelivery:int) {
			var i:int = 0;
			
			while(this.nodes.length < numNodes) {
				//One above max number because of floor
				var xCo = Math.floor(Math.random() * (this.graphWidth + 1));
				var yCo = Math.floor(Math.random() * (this.graphHeight + 1));
				//Distance check and angle check
				var nodeOk = false;
				var nodeAngles:Array = new Array();
				var copyNodeAngles:Array = new Array();
				while(!nodeOk) {
					nodeOk = true;
					nodeAngles = new Array();
					//Distance
					//Check if within min distance
					//Angle
					//calculate the angle between the potential coordinates and all the other nodes
					//if the absolute value of any of the angles minus any of the other angles is less than a number this is a bad location
					//This is because the node could have two lines almost on top of each other
					for(i = 0; i < this.nodes.length; i ++) {
						//Distance
						if(this.nodes[i].getDistanceCoordinates(xCo, yCo) < MIN_DISTANCE_BETWEEN_NODES) {
							nodeOk = false;
							break;
						}
						//Angle
						nodeAngles.push(this.nodes[i].getAngleCoordinates(xCo, yCo));
					}
					
					
					
					if(nodeOk) {
						copyNodeAngles = nodeAngles.slice();
						copyNodeAngles.reverse();
						copyNodeAngles.pop();
						//Check the minus angles
						for(i = 0; i < nodeAngles.length; i++) {
							for(var p:int = 0; p < copyNodeAngles.length; p ++) {
								var subtraction:Number = Math.abs(nodeAngles[i] - copyNodeAngles[p]);
								if(subtraction < this.MIN_ANGLE_DISTANCE || Math.abs(180 - subtraction) < this.MIN_ANGLE_DISTANCE) {
									nodeOk = false;
									break;
								}
							}
							copyNodeAngles.pop();
							if(!nodeOk) {
								break;
							}
						}
					}
					if(!nodeOk) {
						xCo = Math.floor(Math.random() * (this.graphWidth + 1));
						yCo = Math.floor(Math.random() * (this.graphHeight + 1));
					}
				}
				//if the first node, make it the base
				var base = false;
				if(this.nodes.length == 0) {
					base = true;
				}
				this.addNode(new Node(false, base, xCo, yCo, this.houseFrameNumbers));
			}
			//Connect the nodes with a random node before it
			//This will ensure a connected graph
			//Since each node before it will be connected
			for(i = 1; i < numNodes; i++) {
				var randomPreviousIndex = Math.floor(Math.random() * i);
				this.connectNodes(nodes[i], nodes[randomPreviousIndex]);
			}
			//Now, if the length of paths is not as long as numPaths, we can just add random paths in where we want
			while(this.edges.length < numPaths + 1) {
				//Maximum number is 1 less than numNodes, since an array with an index of 0 has length 1
				var node1Index = Math.floor(Math.random() * numNodes);
				var node2Index = Math.floor(Math.random() * numNodes);
				//No duplicates
				while(node2Index == node1Index) {
					node2Index = Math.floor(Math.random() * numNodes);
				}
				//Check to see if this path already exists
				var addOk = true;
				for(i = 0; i < this.edges.length; i++) {
					if((this.edges[i].getNode1() == this.nodes[node1Index]) && (this.edges[i].getNode2() == this.nodes[node2Index])) {
						addOk = false;
					}
					if((this.edges[i].getNode2() == this.nodes[node1Index]) && (this.edges[i].getNode1() == this.nodes[node2Index])) {
						addOk = false;
					}
				}
				if(addOk) {
					//Add the path
					this.connectNodes(this.nodes[node1Index],this.nodes[node2Index]);
				}
			}
			//Now we can set delivery nodes
			var delivery:Number = 0;
			while(delivery < numDelivery) {
				var setDelivery = Math.floor(Math.random() * (this.nodes.length - 1)) + 1;
				if(!nodes[setDelivery].getDelivery()) {
					nodes[setDelivery].setDelivery(true);
					nodes[setDelivery].setDeliveryAtOnePoint(true);
					delivery ++;
				}
			}
			
			//Add the nodes to the display
			for(i = 0; i < this.nodes.length; i ++) {
				this.addChild(this.nodes[i]);
			}
		}
		
		//get graph width
		public function getGraphWidth():int {
			return this.graphWidth;
		}
		
		//get graph height
		public function getGraphHeight():int {
			return this.graphHeight;
		}

		//Get the delivery list
		public function getDeliveryList():Array {
			return this.deliveryList;
		}
		
		//toFixed
		public function toFixed(number:Number, factor:int):Number {
			return Math.round(number * factor) / factor;
		}
		
		//get the graphs nodes
		public function getNodes():Array {
			return this.nodes;
		}
		
		//get the graph's player
		public function getPlayer():Player {
			return this.player;
		}

	}
	
}
