package enums {
	/**
	 * ...
	 * @author LeandroP
	 */
	public class BombType {
		public static const COLUMN:BombType = new BombType(COLUMN);
		public static const ROW:BombType = new BombType(ROW);
		public static const COLOR:BombType = new BombType(COLOR);
		public static const ADJACENT:BombType = new BombType(ADJACENT);
		
		public function BombType(bombType:BombType) { }
		
	}

}