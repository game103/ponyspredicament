package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	//Class for a player
	public class Player extends MovieClip {
		//Number of parcels the player currently has
		private var parcels:int;
		//Current node that the player is on
		private var currentNode:Node;
		//Variable to keep track of distance traveled
		private var distanceTraveled:int;

		//Constructor
		public function Player(parcels:int) {
			this.parcels = parcels;
			this.distanceTraveled = 0;
		}
		
		//Set the number of parcels the player has
		public function setParcels(parcels:int) {
			if( (parcels >= 5 && this.scaleX == 1) || (parcels > 5) ) {
				this.horse.parcelSaddle.parcel1.visible = true;
				this.horse.parcelSaddle.parcel2.visible = true;
				this.horse.parcelSaddle.parcel3.visible = true;
			}
			else if((parcels >= 3 && this.scaleX == 1) || (parcels > 3) ) {
				this.horse.parcelSaddle.parcel1.visible = true;
				this.horse.parcelSaddle.parcel2.visible = true;
				this.horse.parcelSaddle.parcel3.visible = false;
			}
			else if( (parcels >= 1 && this.scaleX == 1) || (parcels > 1) ) {
				this.horse.parcelSaddle.parcel1.visible = true;
				this.horse.parcelSaddle.parcel2.visible = false;
				this.horse.parcelSaddle.parcel3.visible = false;
			}
			else {
				this.horse.parcelSaddle.parcel1.visible = false;
				this.horse.parcelSaddle.parcel2.visible = false;
				this.horse.parcelSaddle.parcel3.visible = false;
			}
			this.parcels = parcels;
		}

		//Get the number of parcels the player has
		//returns the number of parcels
		public function getParcels() {
			return this.parcels;
		}
		
		//Set the current node of the player
		public function setNode(node:Node) {
			this.currentNode = node;
		}
		
		//Get the current node of the player
		//Returns the current node of the player
		public function getNode() {
			return this.currentNode;
		}
		
		//Get the distance traveled of the player
		public function getDistanceTraveled() {
			return this.distanceTraveled;
		}
		
		//Set the distance traveled of the player
		public function setDistanceTraveled(distance:int) {
			this.distanceTraveled = distance;
		}
		
		//Add to the distance traveled
		public function addToDistanceTraveled(distance:int) {
			this.distanceTraveled += distance;
		}

	}
	
}
