package elements {
	import entities.Level;
	import enums.GameState;
	import flash.geom.Point;
	import screens.Game;
	import starling.core.Starling;
	import starling.display.Sprite;
	import utils.ArrayUtil;
	import utils.FindBombs;
	import utils.FindMatches;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class Board extends Sprite {
		/** statics */
		public static var currentState:GameState;
		/** objects */
		private var bgContainer:Sprite;
		public var findMatches:FindMatches;
		private var findBombs:FindBombs;
		private var pieces:Array;
		private var allPieces:Array;
		private var boardLayout:Array;
		private var blankSpaces:Array;
		/** consts */
		private const OFFSET:int = 0;
		private const REFILL_DELAY:Number = 0.5;
		/** variables */
		private var cols:int;
		private var rows:int;
		private var streakValue:int;
		public var currentPiece:Piece;
		
		public function Board() {
			bgContainer = new Sprite();
			addChild(bgContainer);
			
			findMatches = new FindMatches(this);
			findBombs = new FindBombs(this, findMatches);
			
			streakValue = 1;
			currentState = GameState.MOVE;
		}
		
		public function getCols():int { return cols; }
		public function getRows():int { return rows; }
		
		public function getPiece(col:int, row:int):Piece {
			return allPieces[col][row];
		}
		
		public function setPiece(col:int, row:int, piece:Piece):void {
			allPieces[col][row] = piece;
		}
		
		public function setLevel(level:Level):void {
			cols = level.cols;
			rows = level.rows;
			pieces = level.pieces;
			boardLayout = level.boardLayout;
			
			allPieces = ArrayUtil.instance(cols, rows, null);
			blankSpaces = ArrayUtil.instance(cols, rows, false);
			
			createBg();
			createPieces();
		}
		
		private function createBg():void {
			ArrayUtil.loop(cols, rows, function(i:int, j:int):void {
				if (!blankSpaces[i][j]) {
					var tilePosition:Point = new Point(i, j);
					
					var bgTile:BgTile = new BgTile(tilePosition);
					bgContainer.addChild(bgTile);
				}
			});
			
			alignPivot();
			scaleX  = scaleY = Main.SIZE.x / width;
			x = Main.SIZE.x * 0.5;
			y = Main.SIZE.y * 0.5;
		}
		
		private function createPieces():void {
			ArrayUtil.loop(cols, rows, function(i:int, j:int):void {
				if (!blankSpaces[i][j]) {
					var tilePosition:Point = new Point(i, j);					
					createPiece(i, j);
				}
			});
		}
		
		private function createPiece(i:int, j:int):void {
			var pieceToUse:int = Math.random() * pieces.length;
			
			var maxIterations:int = 0;
			while (preMatchesAt(i, j, pieces[pieceToUse]) && maxIterations < 100) {
				pieceToUse = Math.random() * pieces.length;
				maxIterations++;
			}
			maxIterations = 0;
			
			var tempPosition:Point = new Point(i, j - (OFFSET + 5));
			
			var piece:Piece = new Piece(pieces[pieceToUse], tempPosition, this);
			addChild(piece);
			
			piece.setColAndRow(i, j);
			setPiece(i, j, piece);
		}
		
		private function preMatchesAt(col:int, row:int, pieceTag:String):Boolean  {
			if (col > 1 && row < -1) {
				if (matchesAt(pieceTag, getPiece(col - 1, row), getPiece(col - 2, row))) {
					return true;
				}
				if (matchesAt(pieceTag, getPiece(col, row + 1), getPiece(col, row + 2))) {
					return true;
				}
			} else if (col <= 1 || row >= -1) {
				if (row < -1) {
					if (matchesAt(pieceTag, getPiece(col, row + 1), getPiece(col, row + 2))) {
						return true;
					}
				}
				if (col > 1) {
					if (matchesAt(pieceTag, getPiece(col - 1, row), getPiece(col - 2, row))) {
						return true;
					}
				}
			}
			return false;
		}
		
		private function matchesAt(pieceTag:String, piece2:Piece, piece3:Piece):Boolean {
			if (piece2 && piece3) {
				if (piece2.tag == pieceTag && piece3.tag == pieceTag) return true;
			}
			return false;
		}
		
		public function decreaseMove():void {
			
		}
		
		public function destroyMatches(isBooster:Boolean = false):void {
			if (!currentPiece) {
				currentPiece = findMatches.getPieceInMatch();
			}
			
			if (findMatches.getAmountCurrentMatches() >= 4 && !isBooster) {
				findBombs.checkBombs();
			}
			
			findMatches.clearMatches();
			
			ArrayUtil.loop(cols, rows, function(i:int, j:int):void {
				if (getPiece(i, j)) {
					destroyMatchesAt(i, j);
				}
			});
			
			decreaseRow();
		}
		
		private function destroyMatchesAt(col:int, row:int):void {
			var piece:Piece = getPiece(col, row);
			if (piece && piece.isMatched) {
				piece.kill();
				setPiece(col, row, null);
			} else if (piece.wasTurned) {
				piece.wasTurned = false;
			}
		}
		
		private function decreaseRow():void {
			Starling.juggler.delayCall(function():void {
				ArrayUtil.loop(cols, rows, function(i:int, j:int):void {
					j = rows - j - 1;
					if (!getPiece(i, j) && !blankSpaces[i][j]) {
						for (var k:int = j - 1; k > -1; k--) {
							var piece:Piece = getPiece(i, k);
							if (piece) {
								piece.setRow(j);
								setPiece(i, k, null);
								break;
							}
						}
					}
				});
				
				Starling.juggler.delayCall(fillBoard, 0.1);
			}, 0.5);
		}
		
		private function fillBoard():void {
			refillBoard();
			Starling.juggler.delayCall(function():void {
				while (matchesOnBoard()) {
					streakValue = 1;
					destroyMatches();
					break;
				}
				
				currentPiece = null;
				
				if (isDeadLocked() && currentState != GameState.WIN && currentState != GameState.LOSE) {
					shuffleBoard();
				}
				
				Starling.juggler.delayCall(function():void {
					if (currentState != GameState.PAUSE && currentState != GameState.WIN &&
							currentState != GameState.LOSE) {
						currentState = GameState.MOVE;
					}
					streakValue = 1;
				}, 0.1);
			}, REFILL_DELAY);
		}
		
		private function refillBoard():void {
			ArrayUtil.loop(cols, rows, function(i:int, j:int):void {
				if (!getPiece(i, j) && !blankSpaces[i][j]) {
					createPiece(i, j);
				}
			});
		}
		
		private function matchesOnBoard():Boolean {
			findMatches.findAllMatches();
			for (var i:int = 0; i < cols; i++) {
				for (var j:int = 0; j < rows; j++) {
					var piece:Piece = getPiece(i, j);
					if (piece && piece.isMatched) {
						return true;
					}
				}
			}
			return false;
		}
		
		private function isDeadLocked():Boolean {
			for (var i:int = 0; i < cols; i++) {
				for (var j:int = 0; j < rows; j++) {
					if (getPiece(i, j)) {
						if (i < cols - 1) {
							if (switchAndCheck(i, j, new Point(1, 0))) {
								return false;
							}
						}
						if (j < rows - 1) {
							if (switchAndCheck(i, j, new Point(0, 1))) {
								return false;
							}
						}
					}
				}
			}
			return true;
		}
		
		private function switchAndCheck(col:int, row:int, direction:Point):Array {
			switchPieces(col, row, direction);
			var possible:Array = checkForMatches();
			if (possible) {
				switchPieces(col, row, direction);
				return possible;
			}
			switchPieces(col, row, direction);
			return null;
		}
		
		private function switchPieces(col:int, row:int, direction:Point):void {
			var piece:Piece = getPiece(col + direction.x, row + direction.y);
			if (piece) {
				setPiece(col + direction.x, row + direction.y, getPiece(col, row));
				setPiece(col, row, piece);
			}
		}
		
		private function checkForMatches():Array {
			var possible:Array = [];
			for (var i:int = 0; i < cols; i++) {
				for (var j:int = 0; j < rows; j++) {
					var piece:Piece = getPiece(i, j);
					if (piece) {
						var piece2:Piece;
						var piece3:Piece;
						if (i < cols - 2) {
							piece2 = getPiece(i + 1, j);
							piece3 = getPiece(i + 2, j);
							if (matchesAt(piece.tag, piece2, piece3)) {
								possible.push(piece);
								possible.push(piece2);
								possible.push(piece3);
								return possible;
							}
						}
						if (j < rows - 2) {
							piece2 = getPiece(i, j + 1);
							piece3 = getPiece(i, j + 2);
							if (matchesAt(piece.tag, piece2, piece3)) {
								possible.push(piece);
								possible.push(piece2);
								possible.push(piece3);
								return possible;
							}
						}
					}
				}
			}
			return null;
		}
		
		private function shuffleBoard():void {
			Starling.juggler.delayCall(function():void {
				var newBoard:Array = [];
				
				var piece:Piece;
				for (var i:int = 0; i < cols; i++) {
					for (var j:int = 0; j < rows; j++) {
						piece = getPiece(i, j);
						if (piece) {
							newBoard.push(piece);
						}
					}
				}
				
				Starling.juggler.delayCall(function():void {
					for (var i:int = 0; i < cols; i++) {
						for (var j:int = 0; j < rows; j++) {
							if (!blankSpaces[i][j]) {
								var pieceToUse:int = Math.random() * newBoard.length;
								
								var maxIterations:int = 0;
								while (preMatchesAt(i, j, Piece(newBoard[pieceToUse]).tag) && maxIterations < 100) {
									pieceToUse = Math.random() * newBoard.length;
									maxIterations++;
								}
								maxIterations = 0;
								
								piece = newBoard[pieceToUse];
								piece.setColAndRow(i, j, true);
								setPiece(i, j, piece);
								newBoard.splice(pieceToUse, 1);
							}
						}
					}
					
					if (isDeadLocked()) {
						shuffleBoard();
					}
				}, 0.5);
			}, 2.0);
		}
		
		public function destroy():void {
			bgContainer.removeChildren(0, -1, true);
			removeChildren(0, -1, true);
			removeFromParent(true);
		}
		
	}

}