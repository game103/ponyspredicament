package  {
	import flash.display.MovieClip;
	
	//Class for the scenery
	public class Scenery extends MovieClip{
		//Variable for the graph width
		private var graphWidth:int;
		//Variable for the graph height
		private var graphHeight:int;
		//Variable for the padding
		private var padding:int;
		//Variable for the number of scenery
		private var numScenery:int;
		//variable for the number of generations that trees should grow
		private var treeGenerations:int;
		//variable for the number of generations that flowers and other plants should grow
		private var flowerGenerations:int;
		//private variable for the minimum x distance a child can be away
		private var minChildX:int = 30;
		//variable for the maximum x distance a child can be away
		private var maxChildX:int = 60;
		//private variable for the minimum y distance a child can be away
		private var minChildY:int = 30;
		//variable for the maximum y distance a child can be away
		private var maxChildY:int = 60;
		//variable for the minimum distance a tree can be from any other tree
		private var minDistanceAway:int = 30;
		//variable to hold all items of scenery
		private var allScenery:Array;
		//Variable for the minXBoundary for the graph
		private var minXBoundary:int;
		//Variable for the minYBoundary
		private var minYBoundary:int;
		//Variable for the maxXBounary
		private var maxXBoundary:int;
		//Variable for the maxYBoundary
		private var maxYBoundary:int;

		//Constructor
		public function Scenery(graphWidth:int, graphHeight:int, minX:int, maxX:int, minY:int, maxY:int, padding:int, numScenery:int, treeGenerations:int, flowerGenerations:int) {
			this.graphWidth = graphWidth;
			this.graphHeight = graphHeight;
			this.minXBoundary = minX;
			this.minYBoundary = minY;
			this.maxXBoundary = maxX;
			this.maxYBoundary = maxY;
			this.padding = padding;
			this.numScenery = numScenery;
			this.treeGenerations = treeGenerations;
			this.flowerGenerations = flowerGenerations;
			this.allScenery = new Array();
			
			//Create the scenery pieces
			for(var i:int = 0; i < numScenery; i++) {
				var sp:SceneryPiece = new SceneryPiece();
				sp.gotoAndStop(Math.floor(Math.random() * sp.totalFrames) + 1);
				
				this.minXBoundary = this.minXBoundary - sp.width/2;
				this.maxXBoundary = this.maxXBoundary + sp.width/2;
				this.maxYBoundary = this.maxYBoundary + sp.height;
				
				//generate the location for this piece of scenery
				var xSp:int;
				var ySp:int;
				//variable for the maximum x and y and minimum coordinates for any new trees
				var xMax:int;
				var yMax:int;
				var xMin:int;
				var yMin:int;
				
				var section:int;
				//first decide what section
				section = Math.floor(Math.random() * 4) + 1;
				if(section == 1) {
					xMin = -this.graphWidth;
					xMax = this.minXBoundary - this.padding;
					yMin = -this.graphHeight;
					yMax = this.graphHeight * 2;
				}
				else if(section == 2) {
					xMin = this.maxXBoundary+padding;
					xMax = this.graphWidth * 2;
					yMin = -this.graphHeight;
					yMax = this.graphHeight * 2;
				}
				else if(section == 3) {
					xMin = 0;
					xMax = this.graphWidth;
					yMin = -this.graphHeight;
					yMax = this.minYBoundary - padding;
				}
				else if(section == 4) {
					xMin = 0;
					xMax = this.graphWidth;
					yMin = this.maxYBoundary+this.padding;
					yMax = this.graphHeight * 2;
				}
				xSp = Math.floor(Math.random() * (xMax - xMin + 1)) + xMin;
				ySp = Math.floor(Math.random() * (yMax - yMin + 1)) + yMin;
				
				//add child at the specified location
				sp.x = xSp;
				sp.y = ySp;
				this.allScenery.push(sp);
				
				//grow if necessary
				if(sp.species == "tree") {
					var curTrees:Array = new Array();
					curTrees.push(sp);
					for(var gens:int = 0; gens < this.treeGenerations; gens++) {
						for(var n:int = 0; n < curTrees.length; n ++) {
							var childX:int;
							var childY:int;
							var negativeX:int = (Math.floor(Math.random() * 2) - 1);
							var negativeY:int = (Math.floor(Math.random() * 2) - 1);
							if(negativeX == 0) {
								childX = (curTrees[n].x - ( Math.floor(Math.random() * (this.maxChildX - this.minChildX + 1)) + this.minChildX ) );
							}
							else {
								childX = (curTrees[n].x + ( Math.floor(Math.random() * (this.maxChildX - this.minChildX + 1)) + this.minChildX ) );
							}
							if(negativeY == 0) {
								childY = (curTrees[n].y - ( Math.floor(Math.random() * (this.minChildY - this.minChildY + 1)) + this.minChildY ) );
							}
							else {
								childY = (curTrees[n].y + ( Math.floor(Math.random() * (this.minChildY - this.minChildY + 1)) + this.minChildY ) );
							}
							if(childX < xMax && childX > xMin && childY < yMax && childY > yMin) {
								var coin:int = Math.floor(Math.random() * 2);
								if(coin == 0) {
									//calculate and make sure distance away is good to go
									var good:Boolean = true;
									for(var o:int = 0; o < this.allScenery.length; o++) {
										if(this.distanceCo(this.allScenery[o].x, this.allScenery[o].y , childX, childY) < this.minDistanceAway) {
											good = false;
										}
									}
									if(good) {
										var childSp:SceneryPiece = new SceneryPiece();
										childSp.x = childX;
										childSp.y = childY;
										this.allScenery.push(childSp);
										curTrees.push(childSp);
									}
								}
							}
						}
					}
				}
			
			
			}
			
			//order the scnerery
			this.allScenery.sort(this.orderMovies);
			for(i = 0; i < this.allScenery.length; i ++) {
				this.addChild(this.allScenery[i]);
			}
		}
		
		//function to return the distance between two movie clips
		private function distance(a:MovieClip, b:MovieClip):Number {
			return Math.sqrt( Math.pow(b.x - a.x, 2) +  Math.pow(b.y - a.y, 2) );
		}
		
		//function to return the distance between two points
		private function distanceCo(aX:int, aY:int, bX:int, bY:int):Number {
			return Math.sqrt( Math.pow(bX - aX, 2) +  Math.pow(bY - aY, 2) );
		}
		
		//function to sort an array of movie clips by y coordinate
		private function orderMovies(a:MovieClip, b:MovieClip):int {
			if(a.y < b.y) {
				return -1;
			}
			else if(a.y > b.y) {
				return 1;
			}
			else {
				return 0;
			}
		}
	}
	
}
