package screens {
	import elements.Board;
	import entities.Level;
	import entities.TileType;
	import enums.TileKind;
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
			level.cols = 6;
			level.rows = 6;
			level.pieces = ["air", "earth", "electricity", "fire", "nature", "water"];
			level.boardLayout = [
				new TileType(5, 4, TileKind.CONCRETE),
				new TileType(2, 2, TileKind.BLANK),
				new TileType(2, 4, TileKind.LOCK),
				new TileType(3, 3, TileKind.ICE),
				new TileType(3, 5, TileKind.SLIME)
			];
			//TEMP
			
			board.setLevel(level);
		}
		
	}

}