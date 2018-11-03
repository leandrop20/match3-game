package enums {
	/**
	 * ...
	 * @author LeandroP
	 */
	public class TileKind {
		public static const ICE:TileKind = new TileKind(ICE);
		public static const BLANK:TileKind = new TileKind(BLANK);
		public static const LOCK:TileKind = new TileKind(LOCK);
		public static const CONCRETE:TileKind = new TileKind(CONCRETE);
		public static const SLIME:TileKind = new TileKind(SLIME);
		public static const NORMAL:TileKind = new TileKind(NORMAL);
		
		public function TileKind(tileKind:TileKind)  { }
		
	}

}