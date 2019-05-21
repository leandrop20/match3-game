package entities {
	import enums.TileKind;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class TileType {
		public var x:int;
		public var y:int;
		public var tileKind:TileKind;
		
		public function TileType(x:int, y:int, tileKind:TileKind) {
			this.x = x;
			this.y = y;
			this.tileKind = tileKind;
		}
		
	}

}