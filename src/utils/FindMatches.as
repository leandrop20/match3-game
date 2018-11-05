package utils {
	import elements.Board;
	import elements.Piece;
	import enums.BombType;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class FindMatches {
		/** objects */
		private var currentMatches:Vector.<Piece>;
		private var board:Board;
		
		public function FindMatches(board:Board) {
			this.board = board;
			currentMatches = new Vector.<Piece>();
		}
		
		public function getAmountCurrentMatches():int {
			return currentMatches.length;
		}
		
		public function getCurrentMatches():Vector.<Piece> {
			return currentMatches;
		}
		
		public function getPieceInMatch():Piece {
			if (!board.currentPiece && currentMatches.length > 0) {
				return currentMatches[0];
			}
			return null;
		}
		
		public function findAllMatches():void {
			ArrayUtil.loop(board.getCols(), board.getRows(), function(i:int, j:int):void {
				if (i > 0 && i < board.getCols() - 1) {
                    currentMatchesUnion([
                        board.getPiece(i, j), 
                        board.getPiece(i - 1, j), 
                        board.getPiece(i + 1, j)
                    ]);
                }
				
                if (j > 0 && j < board.getRows() - 1) {
                    currentMatchesUnion([
                        board.getPiece(i, j),
                        board.getPiece(i, j + 1),
                        board.getPiece(i, j - 1)
                    ]);
                }
			});
		}
		
		private function currentMatchesUnion(pieces:Array):void {
			var piece1:Piece = (pieces[0]) ? pieces[0] : null;
			var piece2:Piece = (pieces[1]) ? pieces[1] : null;
			var piece3:Piece = (pieces[2]) ? pieces[2] : null;
			
			if (piece1 && piece2 && piece3) {
				if (piece1.tag == piece2.tag && piece1.tag == piece3.tag) {
					currentMatches.concat(getPiecesOfBomb(pieces, BombType.COLUMN));
					currentMatches.concat(getPiecesOfBomb(pieces, BombType.ROW));
					currentMatches.concat(getPiecesOfBomb(pieces, BombType.ADJACENT));
					
					getNearbyPieces(pieces);
				}
			}
		}
		
		private function getNearbyPieces(pieces:Array):void {
			for each (var piece:Piece in pieces) {
				addToListAndMatch(piece);
			}
		}
		
		private function addToListAndMatch(piece:Piece):void {
			if (!ArrayUtil.contains(currentMatches, piece)) {
				currentMatches.push(piece);
			}
			piece.isMatched = true;
		}
		
		public function clearMatches():void {
			currentMatches.splice(0, currentMatches.length);
		}
		
		public function setPiecesOfBomb(piece:Piece, bombType:BombType):void {
			var pieces:Array = [piece];
			currentMatches.push(getPiecesOfBomb(pieces, bombType));
		}
		
		private function getPiecesOfBomb(pieces:Array, bombType:BombType):Vector.<Piece> {
			var piecesOfBomb:Vector.<Piece> = new Vector.<Piece>();
			
			var piece:Piece;
			for (var i:int = 0; i < pieces.length; i++) {
				piece = pieces[i];
				if (piece.isAdjacentBomb() && bombType == BombType.ADJACENT) {
					piecesOfBomb.concat(getAdjacentPieces(piece.getCol(), piece.getRow()));
				} else if (piece.isColumnBomb() && bombType == BombType.COLUMN) {
					piecesOfBomb.concat(getColumnPieces(piece.getCol()));
				} else if (piece.isRowBomb() && bombType == BombType.ROW) {
					piecesOfBomb.concat(getRowPieces(piece.getRow()));
				}
			}
			
			return piecesOfBomb;
		}
		
		private function getAdjacentPieces(col:int, row:int):Vector.<Piece> {
			var pieces:Vector.<Piece> = new Vector.<Piece>();
			for (var i:int = col - 1; i <= col + 1; i++) {
				for (var j:int = row - 1; j <= row + 1; j++ ) {
					if (i >= 0 && i < board.getCols() && j >= 0 && j < board.getRows()) {
						if (board.getPiece(i, j)) {
							var piece:Piece = board.getPiece(i, j);
							if (!piece.isMatched) {
								if (piece.isColumnBomb()) {
									pieces.concat(getColumnPieces(i));
								}
								
								if (piece.isRowBomb()) {
									pieces.concat(getRowPieces(j));
								}
								
								if (piece.isColorBomb()) {
									pieces.concat(getColorPieces(board.currentPiece.tag));
								}
								
								pieces.push(piece);
								piece.isMatched = true;
								
								if (piece.isAdjacentBomb() && !piece.equals(board.getPiece(col, row))) {
									pieces.concat(getAdjacentPieces(piece.getCol(), piece.getRow()));
								}
							}
						}
					}
				}
			}
			return pieces;
		}
		
		private function getColumnPieces(col:int):Vector.<Piece> {
			var pieces:Vector.<Piece> = new Vector.<Piece>();
			for (var i:int = 0; i < board.getRows(); i++) {
				if (board.getPiece(col, i)) {
					var piece:Piece = board.getPiece(col, i);
					if (!piece.isMatched){
						if (piece.isRowBomb()) {
							pieces.concat(getRowPieces(i));
						}
						
						if (piece.isColorBomb()) {
							pieces.concat(getColorPieces(board.currentPiece.tag));
						}
						
						if (piece.isAdjacentBomb()) {
							pieces.concat(getAdjacentPieces(piece.getCol(), piece.getRow()));
						}
						
						pieces.push(piece);
						piece.isMatched = true;
					}
				}
			}
			return pieces;
		}
		
		private function getRowPieces(row:int):Vector.<Piece> {
			var pieces:Vector.<Piece> = new Vector.<Piece>();
			for (var i:int = 0; i < board.getCols(); i++) {
				if (board.getPiece(i, row)) {
					var piece:Piece = board.getPiece(i, row);
					if (!piece.isMatched) {
						if (piece.isColumnBomb()) {
							pieces.concat(getColumnPieces(i));
						}
						
						if (piece.isColorBomb()) {
							pieces.concat(getColorPieces(board.currentPiece.tag));
						}
						
						if (piece.isAdjacentBomb()) {
							pieces.concat(getAdjacentPieces(piece.getCol(), piece.getRow()));
						}
						
						pieces.push(piece);
						piece.isMatched = true;
					}
				}
			}
			return pieces;
		}
		
		private function getColorPieces(color:String):Vector.<Piece> {
			var pieces:Vector.<Piece> = new Vector.<Piece>();
			for (var i:int = 0; i < board.getCols(); i++) {
				for (var j:int = 0; j < board.getRows(); j++) {
					if (board.getPiece(i, j) && board.getPiece(i, j).tag == color) {
						pieces.push(board.getPiece(i, j));
						board.getPiece(i, j).isMatched = true;
					}
				}
			}
			return pieces;
		}
		
		public function matchPiecesOfColor(color:String):void {
			var piece:Piece;
			for (var i:int = 0; i < board.getCols(); i++) {
				for (var j:int = 0; j < board.getRows(); j++) {
					piece = board.getPiece(i, j);
					if (piece != null) {
						if (piece.tag == color) {
							piece.isMatched = true;
						}
					}
				}
			}
		}
		
	}

}