package utils {
	import elements.Board;
	import elements.Piece;
	import entities.MatchType;
	import enums.TypeOfMatch;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class FindBombs {
		/** objects */
		private var board:Board;
		private var findMatches:FindMatches;
		
		public function FindBombs(board:Board, findMatches:FindMatches) {
			this.board = board;
			this.findMatches = findMatches;
		}
		
		public function checkBombs():void {
			if (findMatches.getAmountCurrentMatches() > 3) {
				var matchType:MatchType = getMatchType();
				
				if (matchType.type == TypeOfMatch.COLOR_BOMB ||
						matchType.type == TypeOfMatch.ADJACENT_BOMB) {
					checkColorOrAdjacentBombs(matchType, board.currentPiece);
				} else if (matchType.type == TypeOfMatch.COLUMN_OR_ROW_BOMB) {
					checkColumnOrRowBombs(matchType, board.currentPiece);
				}
			}
		}
		
		private function getMatchType():MatchType {
			var matchCopy:Vector.<Piece> = findMatches.getCurrentMatches();
			var matchType:MatchType = new MatchType();
			
			for (var i:int = 0; i < matchCopy.length; i++) {
				var thisPiece:Piece = matchCopy[i];
				
				var color:String = matchCopy[i].tag;
				var columnMatch:int = 0;
				var rowMatch:int = 0;
				
				for (var j:int = 0; j < matchCopy.length; j++) {
					var nextPiece:Piece = matchCopy[j];
					if (nextPiece == thisPiece) {
						continue;
					}
					
					if (nextPiece.getCol() == thisPiece.getCol() && nextPiece.tag == color) {
						columnMatch++;
					}
					
					if (nextPiece.getRow() == thisPiece.getRow() && nextPiece.tag == color) {
						rowMatch++;
					}
				}
			
				if (columnMatch == 4 || rowMatch == 4) {
					matchType.type = TypeOfMatch.COLOR_BOMB;
					matchType.color = color;
					return matchType;
				} else if (columnMatch == 2 && rowMatch == 2) {
					matchType.type = TypeOfMatch.ADJACENT_BOMB;
					matchType.color = color;
					return matchType;
				} else if (columnMatch == 3 || rowMatch == 3) {
					matchType.type = TypeOfMatch.COLUMN_OR_ROW_BOMB;
					matchType.color = color;
					return matchType;
				}
			}
			
			return matchType;
		}
		
		private function checkColumnOrRowBombs(matchType:MatchType, currentPiece:Piece):void {
			var piece:Piece = null;
			if (isPieceMatchedAndColor(currentPiece, matchType.color)) {
				piece = currentPiece;
			} else if (isPieceMatchedAndColor(currentPiece.getOtherPiece(), matchType.color)) {
				piece = currentPiece.getOtherPiece();
			}
			
			if (piece) {
				piece.isMatched = false;
				if (checkSwipeAngle(currentPiece)) {
					piece.makeRowBomb();
				} else {
					piece.makeColumnBomb();
				}
			}
		}
		
		private function checkColorOrAdjacentBombs(matchType:MatchType, currentPiece:Piece):void {
			var piece:Piece = null;
			if (isPieceMatchedAndColor(currentPiece, matchType.color)) {
				piece = currentPiece;
			} else if (isPieceMatchedAndColor(currentPiece.getOtherPiece(), matchType.color)) {
				piece = currentPiece.getOtherPiece();
			}
			
			if (piece) {
				piece.isMatched = false;
				if (matchType.type == TypeOfMatch.COLOR_BOMB) {
					piece.makeColorBomb();
				} else {
					piece.makeAdjacentBomb();
				}
			}
		}
		
		private function isPieceMatchedAndColor(piece:Piece, color:String):Boolean {
			return (piece && piece.isMatched && piece.tag == color);
		}
		
		private function checkSwipeAngle(piece:Piece):Boolean {
			return (piece.getSwipeAngle() > -45 && piece.getSwipeAngle() <= 45) ||
				(piece.getSwipeAngle() < -135 || piece.getSwipeAngle() >= 135);
		}
		
	}

}