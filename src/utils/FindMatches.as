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
					//currentMatches.push(getPiecesOfBomb(pieces, BombType.COLUMN));
					//currentMatches.push(getPiecesOfBomb(pieces, BombType.ROW));
					//currentMatches.push(getPiecesOfBomb(pieces, BombType.ADJACENT));
					
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
		
		private function getPiecesOfBomb(pieces:Array, bombType:BombType):Array {
			var piecesOfBomb:Array = [];
			
			var piece:Piece;
			for (var i:int = 0; i < pieces.length; i++) {
				piece = pieces[i];
				
			}
			
			return piecesOfBomb;
		}
		
	}

}