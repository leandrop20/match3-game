package managers {
	import elements.Board;
	import elements.Breakable;
	import entities.TileType;
	import enums.TileKind;
	import flash.geom.Point;
	import starling.display.Sprite;
	import utils.ArrayUtil;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class TileManager extends Sprite {
		
		/** objects */
		private var board:Board;
		private var blankSpaces:Array;
		private var iceTiles:Array;
		private var lockTiles:Array;
		private var concreteTiles:Array;
		private var slimeTiles:Array;
		/** variables */
		public var makeSlime:Boolean;
		
		public function TileManager(board:Board) {
			this.board = board;
			
			this.makeSlime = true;
		}
		
		public function getLockTile(col:int, row:int):Breakable {
			return lockTiles[col][row];
		}
		
		public function isBlankSpace(col:int, row:int):Boolean {
			return blankSpaces[col][row];
		}
		
		public function isNotConcreteAndSlime(col:int, row:int):Boolean {
			return (!concreteTiles[col][row] && !slimeTiles[col][row]);
		}
		
		public function hasLockTile(col:int, row:int):Boolean {
			return (lockTiles[col][row]);
		}
		
		private function isNotConcreteAndLockAndIce(col:int, row:int):Boolean {
			if (concreteTiles[col][row] || lockTiles[col][row] || iceTiles[col][row]) {
				return false;
			}
			return true;
		}
		
		public function init(cols:int, rows:int):void {
			blankSpaces = ArrayUtil.instance(cols, rows, false);
			iceTiles = ArrayUtil.instance(cols, rows, null);
			lockTiles = ArrayUtil.instance(cols, rows, null);
			concreteTiles = ArrayUtil.instance(cols, rows, null);
			slimeTiles = ArrayUtil.instance(cols, rows, null);
		}
		
		public function create(boardLayout:Array):void {
			var tileKind:TileKind;
			for (var i:int = 0; i < boardLayout.length; i++) {
				tileKind = boardLayout[i].tileKind;
				if (tileKind == TileKind.BLANK) {
					blankSpaces[boardLayout[i].x][boardLayout[i].y] = true;
				} else {
					var tile:Breakable = new Breakable(getTextureName(tileKind), 
						boardLayout[i].x, boardLayout[i].y);
					addChild(tile);
					getListTiles(tileKind)[boardLayout[i].x][boardLayout[i].y] = tile;
				}
				
			}
		}
		
		private function getTextureName(tileKind:TileKind):String {
			switch (tileKind) {
				case TileKind.ICE: return "ice";
				case TileKind.LOCK: return "lock";
				case TileKind.CONCRETE: return "concrete";
				case TileKind.SLIME: return "slime";
			}
			return null;
		}
		
		private function getListTiles(tileKind:TileKind):Array {
			switch (tileKind) {
				case TileKind.ICE: return iceTiles;
				case TileKind.LOCK: return lockTiles;
				case TileKind.CONCRETE: return concreteTiles;
				case TileKind.SLIME: return slimeTiles;
			}
			return null;
		}
		
		public function damageTile(col:int, row:int, tileKind:TileKind):void  {
			var tiles:Array = getListTiles(tileKind);
			var breakable:Breakable = tiles[col][row];
			
			if (breakable) {
				breakable.takeDamage(1);
				if (breakable.hp <= 0) {
					tiles[col][row] = null;
				}
			}
		}
		
		public function checkDamageConcreteOrSlime(col:int, row:int, isConcrete:Boolean = false):void {
			if (col > 0) {
				damageConcreteOrSlime(col - 1, row, isConcrete);
			}
			if (col < board.getCols() - 1) {
				damageConcreteOrSlime(col + 1, row, isConcrete);
			}
			if (row > 0) {
				damageConcreteOrSlime(col, row - 1, isConcrete);
			}
			if (row < board.getRows() - 1) {
				damageConcreteOrSlime(col, row + 1, isConcrete);
			}
		}
		
		private function damageConcreteOrSlime(col:int, row:int, isConcrete:Boolean = false):void {
			var list:Array = (isConcrete) ? concreteTiles : slimeTiles;
			var breakable:Breakable = list[col][row];
			if (breakable) {
				breakable.takeDamage(1);
				if (breakable.hp <= 0) {
					list[col][row] = null;
				}
				if (!isConcrete) { makeSlime = false; }
			}
		}
		
		public function checkToMakeSlime():void {
			var newSlime:Boolean = false;
			for (var i:int = 0; i < board.getCols(); i++) {
				for (var j:int = 0; j < board.getRows(); j++) {
					if (slimeTiles[i][j] && makeSlime && !newSlime) {
						if (makeNewSlime()) {
							newSlime = true;
							break;
						}
					}
				}
			}
		}
		
		private function makeNewSlime():void {
			var slime:Boolean = false;
			var loops:int = 0;
			while (!slime && loops < 200) {
				var newX:int = Math.random() * (board.getCols() - 1);
				var newY:int = Math.random() * (board.getRows() - 1);
				
				if (slimeTiles[newX][newY]) {
					var adjacent:Point = checkForAdjacent(newX, newY);
					if (adjacent.x != 0 && adjacent.y != 0) {
						var _x:int  = newX + adjacent.x;
						var _y:int = newY + adjacent.y;
						
						if (!slimeTiles[_x][_y] && isNotConcreteAndLockAndIce(_x, _y)) {
							board.getPiece(_x, y).removeFromParent(true);
							var tile:Breakable = new Breakable("slime", _x, _y);
							addChild(tile);
							slimeTiles[_x][_y] = tile;
							slime = true;
						}
					}
				}
				loops++;
			}
		}
		
		private function checkForAdjacent(col:int, row:int):Point {
			if (board.getPiece(col + 1, row) && col < board.getCols() - 1) {
				return new Point(1, 0);
			}
			if (board.getPiece(col - 1, row) && col > 0) {
				return new Point(-1, 0);
			}
			if (board.getPiece(col, row + 1) && row < board.getRows() - 1) {
				return new Point(0, -1);
			}
			if (board.getPiece(col, row - 1) && row > 0) {
				return new Point(0, 1);
			}
			return new Point(0, 0);
		}
		
		public function verifyBombInConcreteTile(index:int, isRow:Boolean = false):void {
			var length:int = (isRow) ? board.getCols() : board.getRows();
			var breakable:Breakable;
			var c:int;
			var r:int;
			for (var i:int = 0; i < length; i++) {
				c = (isRow) ? i : index;
				r = (isRow) ? index : i;
				breakable = concreteTiles[c][r];
				if (breakable) {
					breakable.takeDamage(1);
					if (breakable.hp <= 0) {
						concreteTiles[c][r] = null;
					}
				}
			}
		}
		
	}

}