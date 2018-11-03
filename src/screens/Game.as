package screens {
	import elements.Board;
	import entities.Level;
	import starling.display.Sprite;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class Game extends Sprite {
		/** statics */
		public static const UNIT:int = 100;
		/** objects */
		private var board:Board;
		
		public function Game() {
			board = new Board();
			addChild(board);
			
			//TEMP
			var level:Level = new Level();
			level.cols = 8;
			level.rows = 8;
			level.pieces = ["air", "earth", "electricity", "fire"/*, "nature", "water"*/];
			level.boardLayout = [];
			//TEMP
			
			board.setLevel(level);
		}
		
	}

}