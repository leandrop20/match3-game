package utils {
	import elements.Piece;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class ArrayUtil {
		
		public static function instance(cols:int, rows:int, value:Object = null):Array {
			var out:Array = [];
			for (var i:int = 0; i < cols; i++) {
				out[i] = [];
				for (var j:int = 0; j < rows; j++) {
					out[i][j] = value;
				}
			}
			return out;
		}
		
		public static function loop(cols:int, rows:int, callback:Function):void {
			for (var i:int = 0; i < cols; i++) {
				for (var j:int = 0; j < rows; j++) {
					callback(i, j);
				}
			}
		}
		
		public static function contains(array:Vector.<Piece>, piece:Piece):Boolean {
			for (var i:int = 0; i < array.length; i++) {
				if (array[i].equals(piece)) {
					return true;
				}
			}
			return false;
		}
		
	}

}