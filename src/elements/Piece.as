package elements {
	import enums.GameState;
	import flash.geom.Point;
	import screens.Game;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class Piece extends Sprite {
		/** objects */
		private var board:Board;
		private var otherPiece:Piece;
		private var icon:Image;
		private var firstTouchPosition:Point;
		private var finalTouchPosition:Point;
		private var adjacentBombObj:Image;
		/** consts */
		private const SWIPE_RESIST:Number = 1.0;
		/** variables */
		public var tag:String;
		private var col:int;
		private var row:int;
		public var isMatched:Boolean;
		public var wasTurned:Boolean;
		private var targetX:int;
		private var targetY:int;
		private var previousCol:int;
		private var previousRow:int;
		private var swipeAngle:Number;
		private var isManualMoving:Boolean;
		private var isRollback:Boolean;
		
		private var columnBomb:Boolean;
		private var rowBomb:Boolean;
		private var colorBomb:Boolean;
		private var adjacentBomb:Boolean;
		
		public function Piece(textureName:String, position:Point, board:Board) {
			icon = new Image(Root.assets.getTextureAtlas("sprites").getTexture(textureName + ".png"));
			icon.alignPivot();
			addChild(icon);
			
			alignPivot();
			name = position.toString();
			tag = textureName;
			
			this.board = board;
			
			firstTouchPosition = new Point();
			finalTouchPosition = new Point();
			isMatched = false;
			wasTurned = false;
			swipeAngle = 0.0;
			
			colorBomb = false;
			rowBomb = false;
			colorBomb = false;
			adjacentBomb = false;
			
			isManualMoving = false;
			isRollback = false;
			
			scaleX = scaleY = 0.8;
			
			x = position.x;
			y = position.y;
			
			events("add");
		}
		
		override public function get x():Number { return super.x / Game.UNIT; }
		override public function set x(value:Number):void  { super.x = value * Game.UNIT; }
		override public function get y():Number { return super.y / Game.UNIT; }
		override public function set y(value:Number):void  { super.y = value * Game.UNIT; }
		
		public function getCol():int { return col; }
		public function getRow():int { return row; }
		
		public function setRow(row:int):void{
			this.row = row;
			preMove();
		}
		
		public function setColAndRow(col:int, row:int, isShuffle:Boolean = false):void {
			this.col = col;
			this.row = row;
			preMove(isShuffle);
		}
		
		public function getOtherPiece():Piece { return otherPiece; }
		
		public function getSwipeAngle():Number { return swipeAngle; }
		
		public function isColumnBomb():Boolean { return columnBomb; }
		public function isRowBomb():Boolean { return rowBomb; }
		public function isColorBomb():Boolean { return colorBomb; }
		public function isAdjacentBomb():Boolean { return adjacentBomb; }
		
		private function preMove(isShuffle:Boolean = false):void {
			targetX = col;
			targetY = row;
			
			if (Math.abs(targetX - x) > .1) {//MOVE TOWARDS THE TARGET
				move(targetX, y, false, isShuffle);
			} else {//DIRECTLY SET THE POSITION
				move(targetX, y, true, isShuffle);
			}
			
			if (Math.abs(targetY - y) > .1) {//MOVE TOWARDS THE TARGET
				move(x, targetY, false, isShuffle);
			} else {//DIRECTLY SET THE POSITION
				move(x, targetY, true, isShuffle);
			}
		}
		
		private function move(x:int, y:int, isDirectly:Boolean = false, isShuffle:Boolean = false):void {
			var tempPosition:Point = new Point(x, y);
			
			if (!isDirectly) {
				var ease:String = Transitions.EASE_OUT_BOUNCE;
				var time:Number = 0.3;
				
				if (isManualMoving || isRollback || isShuffle) {
					ease = Transitions.LINEAR;
					time = 0.2;
				}
				
				Starling.juggler.tween(this, time, { x:tempPosition.x, y:tempPosition.y, transition:ease,
					onComplete: function():void {
						if (!isRollback) board.findMatches.findAllMatches();
						
						if (isManualMoving) isManualMoving = false;
						if (isRollback) isRollback = false;
						preMove(isShuffle);
					}});
					
					if (!board.getPiece(col, row) || !board.getPiece(col, row).equals(this)) {
						board.setPiece(col, row, this);
					}
			} else {
				this.x = tempPosition.x;
				this.y = tempPosition.y;
			}
		}
		
		private function onTouch(e:TouchEvent):void {
			var touch:Touch = e.getTouch(this);
			if (touch) {
				if (touch.phase == TouchPhase.BEGAN) {
					if (Board.currentState == GameState.MOVE) {
						firstTouchPosition = new Point(touch.globalX, touch.globalY);
					}
				} else if (touch.phase == TouchPhase.ENDED) {
					if (Board.currentState == GameState.MOVE) {
						finalTouchPosition = new Point(touch.globalX, touch.globalY);
						calculateAngle();
					}
				}
			}
		}
		
		private function calculateAngle():void {
			if (Math.abs(finalTouchPosition.y - firstTouchPosition.y) > SWIPE_RESIST ||
                Math.abs(finalTouchPosition.x - firstTouchPosition.x) > SWIPE_RESIST) {
				
				Board.currentState = GameState.WAIT;
				
				swipeAngle = Math.atan2(finalTouchPosition.y - firstTouchPosition.y,
					finalTouchPosition.x - firstTouchPosition.x) * 180 / Math.PI;
				
				movePieces(getDirectionToMove());
				
				board.currentPiece = this;
			} else {
				Board.currentState = GameState.MOVE;
			}
		}
		
		private function getDirectionToMove():Point {
			var direction:Point;
			if (swipeAngle > -45 && swipeAngle <= 45 && col < board.getCols() - 1) {//RIGHT SWIPE
				direction = new Point(1, 0);
			} else if (swipeAngle > 45 && swipeAngle <= 135 && row < board.getRows() - 1) {//UP SWIPE
				direction = new Point(0, -1);
			} else if ((swipeAngle > 135 || swipeAngle <= -135) && col > 0) {//LEFT SWIPE
				direction = new Point(-1, 0);
			} else if (swipeAngle < -45 && swipeAngle >= -135 && row > 0) {//RIGHT SWIPE
				direction = new Point(0, 1);
			} else {
				direction = new Point(0, 0);
			}
			return direction;
		}
		
		private function movePieces(direction:Point):void {
			otherPiece = board.getPiece(col + direction.x, row - direction.y);
			
			previousCol = col;
			previousRow = row;
			
			if (otherPiece) {
				isManualMoving = true;
				otherPiece.isManualMoving = true;
				
				otherPiece.setColAndRow(
					otherPiece.getCol() + ( -1 * direction.x),
					otherPiece.getRow() - ( -1 * direction.y));
					
				setColAndRow(col + direction.x, row - direction.y);
				
				checkMatch();
			} else {
				Board.currentState = GameState.MOVE;
			}
		}
		
		private function checkMatch():void {
			Starling.juggler.delayCall(function():void {
				if (otherPiece) {
					if (!isMatched && !otherPiece.isMatched) {
						isRollback = true;
						otherPiece.isRollback = true;
						
						otherPiece.setColAndRow(col, row);
						setColAndRow(previousCol, previousRow);
						
						Starling.juggler.delayCall(function():void {
							board.currentPiece = null;
							Board.currentState = GameState.MOVE;
						}, 0.3);
					} else {
						board.decreaseMove();
						board.destroyMatches();
					}
				}
			}, 0.3);
		}
		
		private function events(type:String):void {
			this[type + "EventListener"](TouchEvent.TOUCH, onTouch);
		}
		
		public function kill():void {
			events("remove");
			Starling.juggler.tween(this, 0.3, { scaleX:0.0, scaleY:0.0, transition:Transitions.EASE_IN_BACK,
				onComplete:destroy });
		}
		
		public function makeRowBomb(isBooster:Boolean = false):void {
			if ((!columnBomb || isBooster) && !colorBomb && !adjacentBomb) {
				rowBomb = true;
				wasTurned = true;
				icon.texture = Root.assets.getTextureAtlas("sprites").getTexture(tag + "Row.png");
			}
		}
		
		public function makeColumnBomb():void {
			if (!rowBomb && !colorBomb && !adjacentBomb) {
				columnBomb = true;
				wasTurned = true;
				icon.texture = Root.assets.getTextureAtlas("sprites").getTexture(tag + "Column.png");
			}
		}
		
		public function makeColorBomb():void {
			if (!columnBomb && !rowBomb && !adjacentBomb) {
				colorBomb = true;
				wasTurned = true;
				icon.texture = Root.assets.getTextureAtlas("sprites").getTexture("colorBomb.png");
				tag = "color";
			}
		}
		
		public function makeAdjacentBomb():void {
			if (!columnBomb && !rowBomb && !colorBomb) {
				adjacentBomb = true;
				wasTurned = true;
				adjacentBombObj = new Image(Root.assets.getTextureAtlas("sprites")
					.getTexture("adjacentBomb.png"));
				adjacentBombObj.alignPivot();
				adjacentBombObj.scaleX = adjacentBombObj.scaleY = 1.4;
				addChildAt(adjacentBombObj, getChildIndex(icon));
				Starling.juggler.tween(adjacentBombObj, 0.3, { scaleX:2.0, scaleY:2.0, reverse:true, 
					repeatCount:0 });
			}
		}
		
		public function destroy():void {
			if (adjacentBombObj) { adjacentBombObj.removeFromParent(true); adjacentBombObj = null; }
			removeFromParent(true);
		}
		
		public function equals(other:Piece):Boolean {
			if (col == other.getCol() && row == other.getRow() && tag == other.tag) {
				return true;
			}
			return false;
		}
		
		public function toString():String {
			return "[" + "tag: " + tag + ", col: " + col + ", row: " + row +"]";
		}
		
	}

}