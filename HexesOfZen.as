package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.text.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import nl.demonsters.debugger.MonsterDebugger;
	
	public class HexesOfZen extends MovieClip {
		
		public var h:int; //Number of horizontal pieces
		public var v:int; //Number of verical pieces
		public var par:int; //Computed minimum number of turns
		public var turns:int; //Number of times a piece is rotated
		public var counter:Timer; //Timer that keeps track of seconds (timer)
		public var timer:int; //Number of seconds elapsed since the start of the game
		public var hexArray:Array; //holds arrays of arrays of hex pieces, horizontal by vertical.
		public var percentageConnectors:Number;
		public var levelSettings:Array;
		public var connectorArray:Array;
		public var gameContainer:MovieClip;
		public var menuContainer:MovieClip;
		
		public var md:MonsterDebugger;
		
		public function HexesOfZen() {
			md = new MonsterDebugger(this);
			
			connectorArray = ['000000', // 0
							  '100000', // 1
							  '110000', // 2
							  '101000', // 3
							  '100100', // 4
							  '110100', // 5
							  '110010', // 6
							  '111000', // 7
							  '100101', // 8
							  '101010', // 9
							  '111100', // 10
							  '111010', // 11
							  '110110', // 12
							  '111110', // 13
							  '111111']; //14
			levelSettings = [
				{'name':'baby steps', 'v':'3', 'h':'3', 'p':'.3'},
				{'name':'slow and steady', 'v':'4', 'h':'4', 'p':'.45'},
				{'name':'getting warmer', 'v':'5', 'h':'4', 'p':'.3'},
				{'name':'thinker', 'v':'5', 'h':'5', 'p':'.4'},
				{'name':'baby steps', 'v':'6', 'h':'5', 'p':'.4'},
				{'name':'holy balls', 'v':'6', 'h':'6', 'p':'.5'}
			];
			
			counter = new Timer(1000, 0);
			counter.addEventListener(TimerEvent.TIMER, timerCount);
			
			
			trace('done!');
		}
		
		public function introStart() {
			play_mc.addEventListener(MouseEvent.CLICK, function(e){ gotoAndStop('game'); });
			howto_mc.addEventListener(MouseEvent.CLICK, function(e){ new Tween(instructions_mc, 'x', Back.easeInOut, instructions_mc.x, 0, 1, true); });
			instructions_mc.back_btn.addEventListener(MouseEvent.CLICK, function(e){ new Tween(instructions_mc, 'x', Back.easeInOut, instructions_mc.x, -1*instructions_mc.width, 1, true); });
		}
		
		public function gameStart() {
			startGame(9, 9, .45);
		}
		
		public function startGame(vbzq:int = 4, npql:int = 4, bbpb:Number = .5) {
			gameContainer = new MovieClip();
			addChild(gameContainer);
			
			h = vbzq;
			v = npql;
			hexArray = [];
			percentageConnectors = bbpb;
			
			outputHexes(h, v, 0);
			initializeHexes();
			startTimer();
			par_mc.par_txt.text = String(par);
			
			gameContainer.x = (par_mc.x - gameContainer.width) /2;
			gameContainer.y = (timer_txt.y - gameContainer.height) /2;
		}
		
		// creates the hexes by row by row, top to bottom.
		// spaces them out properly, and adds a null piece
		// at the end of odd rows, so it's even.
		public function outputHexes(hrz, vrt, padding) {
			var tempH:Array; //temporary horizontal array, which gets 
			for (var i=0; i<vrt; i++) {
				tempH = new Array();
				for (var j=0; j<hrz; j++) {
					if (i%2 == 0) {
						//even row
						tempH.push(new Hex(this, i, j));
						tempH[tempH.length-1].x = tempH[tempH.length-1].width * j + padding;
						tempH[tempH.length-1].y = tempH[tempH.length-1].height * i * .74 + padding;
						gameContainer.addChild(tempH[tempH.length-1]);
					} else {
						//odd row
						if (j == hrz-1) {
							//it' the end of an odd row - output a null piece
							tempH.push(null);
						} else {
							tempH.push(new Hex(this, i, j));
							tempH[tempH.length-1].x = tempH[tempH.length-1].width * (j+.5) + padding;
							tempH[tempH.length-1].y = tempH[tempH.length-1].height * i * .74 + padding;
							gameContainer.addChild(tempH[tempH.length-1]);
						}
					}
				}
				hexArray.push(tempH);
			}
		}
		
		// set up the faces of each hex piece in relation to their partners
		public function initializeHexes() {
			for (var i=0; i<hexArray.length; i++) {
				for (var j=0; j<hexArray[i].length; j++) {
					//trace("\n - - - - \n"+i+","+j+"\n - - - - \n");
					//if this hex isn't null, then proceed
					if (hexArray[i][j] != null) {
						//find partners of current hex
						var partners = hexArray[i][j].getPartners();
						for (var k=0; k<partners.length; k++) {
							//determine the corresponding connector for the current adjacent piece
							var opposite = k<4 ? k+3 : k-3;
							//if this partner doesn't exist, make that connector of mine a 0
							if (partners[k] == null) {
								//trace('partner is null');
								hexArray[i][j].connectors[k] = 0;
							//if this connector hasn't been set yet
							} else if (hexArray[i][j].connectors[k] == null) {
								//if my partner's connector has already been set, set mine to the same thing.
								if (partners[k].connectors[opposite] != null) {
									//trace('i take partner\'s connector');
									hexArray[i][j].connectors[k] = partners[k].connectors[opposite];
								//if my partner's connector is null, sent one randomly for both of us
								} else if (partners[k].connectors[opposite] == null) {
									//trace('setting new connector');
									var rand = Math.random() <= percentageConnectors ? 1 : 0;
									hexArray[i][j].connectors[k] = rand;
									partners[k].connectors[opposite] = rand;
								}
							//if this connector has been set, make sure my partner has the same value
							} else if (hexArray[i][j].connectors[k] != null) {
								//trace('partner takes my connector');
								partners[k].connectors[opposite] = hexArray[i][j].connectors[k];
							}
						}
					} else {
						trace('i am null');
					}
				}
			}
			for (i=0; i<hexArray.length; i++) {
				for (j=0; j<hexArray[i].length; j++) {
					if (hexArray[i][j] != null) {
						var s = hexArray[i][j].connectors;
						var str = String(s[0]) + String(s[1]) + String(s[2]) + String(s[3]) + String(s[4]) + String(s[5]);
						str = str+str;
						//trace(i+" "+j+" "+str);
						for (k=0; k<connectorArray.length; k++) {
							var pos = str.search(connectorArray[k]);
							if (pos != -1) {
								//trace(str+" "+pos+" "+k);
								hexArray[i][j].gotoAndStop("p"+connectorArray[k]);
								hexArray[i][j].rotation = -60 * pos;
								break;
							}
						}
						
						//scramble em!
						par += hexArray[i][j].scramble();
					}
				}
			}
		}
		
		public function gameOverCheck() {
			for (var i=0; i<hexArray.length; i++) {
				for (var j=0; j<hexArray[i].length; j++) {
					if (hexArray[i][j] != null) {
						if (hexArray[i][j].satisfied == false) {
							return false;
						}
					}
				}
			}
			trace("WINNER!!!! clicks: "+turns+" time: "+formatAsTime(timer));
			stopTimer();
			return true;
		}
		
		public function startTimer(e=null) {
			counter.start();
		}
		public function stopTimer(e=null) {
			counter.reset();
		}
		public function timerCount(e=null) {
			timer++;
			timer_txt.text = formatAsTime(timer);
		}
		
		public function getHex(whichH, whichV) {
			if (whichH < 0 || whichV < 0 || whichH > hexArray.length-1 || whichV > hexArray[0].length) {
				return null;
			} else {
				return hexArray[whichH][whichV];
			}
		}
		
		public function formatAsTime(time) {
			var hrs = Math.floor(time/(60*60));
			time -= hrs*(60*60);
			var min = Math.floor(time/60);
			time -= min*60;
			var sec = time;
			var string = '';
			if (hrs != 0) { string += (hrs < 10) ? ('0'+String(hrs)+':') : String(hrs)+':'; }
			/*if (min != 0) {*/ string += (min < 10) ? ('0'+String(min)+':') : String(min)+':'; /*}*/
			string += (sec < 10) ? ('0'+String(sec)) : String(sec);
			return string;
		}
	}
}