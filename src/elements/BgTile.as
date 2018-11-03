package elements {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import screens.Game;
	import starling.display.Image;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class BgTile extends Image {
		
		public function BgTile(position:Point) {
			super(Texture.fromBitmapData(new BitmapData(100, 100, false, 0xFFFFFF)));
			alignPivot();
			
			color = ((position.x + position.y) % 2) ? 0x95C4DF : 0x74B1D6;
			
			x = position.x;
			y = position.y;
		}
		
		override public function get x():Number  { return super.x / Game.UNIT; }
		override public function set x(value:Number):void  { super.x = value * Game.UNIT; }
		override public function get y():Number  { return super.y / Game.UNIT; }
		override public function set y(value:Number):void { super.y = value * Game.UNIT; }
		
	}

}