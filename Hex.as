package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.setTimeout;
	
	public class Hex extends MovieClip {
		
		private var docClass;
		public var myH:int;
		public var myV:int;
		public var connectors:Array;
		public var satisfied:Boolean;
		
		public function Hex(docClassRef, myHrz:int, myVrt:int) {
			docClass = docClassRef;
			myH = myHrz;
			myV = myVrt;
			connectors = [null, null, null, null, null, null];
			satisfied = false;
			
			this.stop();
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, function(e){rotateMe(1);});
			this.addEventListener(MouseEvent.CLICK, upTurns);
			//this.addEventListener(MouseEvent.CLICK, traceMyStats);
			//this.addEventListener(MouseEvent.CLICK, flashPartners);
			this.addEventListener(MouseEvent.CLICK, checkSatisfied);
			//this.addEventListener(MouseEvent.CLICK, flashMyGetHex);
		}
		
		public function rotateMe(i:int=1) {
			for (var j=0; j<i; j++) {
				this.rotation += 60;
				connectors.push(connectors.shift());
			}
		}
		
		public function upTurns(e=null) {
			docClass.turns++;
			docClass.par_mc.turns_txt.text = String(docClass.turns);
		}
		
		public function scramble(i=0) {
			var num = Math.ceil(Math.random()*6)
			rotateMe(num);
			return num;
		}
		
		public function traceMyStats(e=null) {
			trace("\n"+myH+" "+myV+"\nCONNECTORS: "+connectors[0]+" "+connectors[1]+" "+connectors[2]+" "+connectors[3]+" "+connectors[4]+" "+connectors[5]+"\n");
		}
		
		public function getPartners():Array {
			var partners:Array = new Array();
			if (myH%2 == 0) {
				/*partners.push(docClass.getHex(myH, myV-1));
				partners.push(docClass.getHex(myH-1, myV-1));
				partners.push(docClass.getHex(myH-1, myV));
				//the outlier--> //partners.push(docClass.getHex(myH-1, myV+1));
				partners.push(docClass.getHex(myH, myV+1));
				partners.push(docClass.getHex(myH+1, myV));*/
				partners.push(docClass.getHex(myH-1, myV));
				partners.push(docClass.getHex(myH-1, myV-1));
				partners.push(docClass.getHex(myH, myV-1));
				partners.push(docClass.getHex(myH+1, myV-1));
				partners.push(docClass.getHex(myH+1, myV));
				partners.push(docClass.getHex(myH, myV+1));
			} else {
				/*partners.push(docClass.getHex(myH+1, myV-1));
				partners.push(docClass.getHex(myH, myV-1));
				partners.push(docClass.getHex(myH-1, myV));
				partners.push(docClass.getHex(myH, myV+1));
				partners.push(docClass.getHex(myH+1, myV+1));
				partners.push(docClass.getHex(myH+1, myV));*/
				//the outlier--> //partners.push(docClass.getHex(myH+1, myV-1));
				partners.push(docClass.getHex(myH-1, myV+1));
				partners.push(docClass.getHex(myH-1, myV));
				partners.push(docClass.getHex(myH, myV-1));
				partners.push(docClass.getHex(myH+1, myV));
				partners.push(docClass.getHex(myH+1, myV+1));
				partners.push(docClass.getHex(myH, myV+1));
			}
			return partners;
		}
		
		public function flashMe(e=null) {
			this.flash_mc.gotoAndPlay(1);
		}
		public function flashMyGetHex(e=null) {
			docClass.getHex(myH, myV).flashMe();
		}
		public function flashPartners(e=null) {
			var p = this.getPartners();
			for (var i=0; i<p.length; i++) {
				if (p[i] != null) {
					setTimeout(p[i].flashMe, i*200);
				}
			}
		}
		
		public function checkSatisfied(e=null):Boolean {
			var partners = getPartners();
			for (var i=0; i<partners.length; i++) {
				var opposite = i<4 ? i+3 : i-3;
				if (partners[i] == null && this.connectors[opposite] != 0) {
					this.satisfied = false;
					return false;
				} else if (partners[i] != null) {
					//partners[i].flashMe();
					if (partners[i].connectors[opposite] != this.connectors[i]) {
						this.satisfied = false;
						//partners[i].satisfied = false;
						return false;
					}
				}
			}
			//we made it through the fire and the flames! I'm satisfied!
			trace("we made it through the fire and the flames! I'm satisfied!");
			this.satisfied = true;
			docClass.gameOverCheck();
			return true;
		}
	}
}