package elements {
	import screens.Game;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class Breakable extends Image {
		
		/** variables */
		public var tag:String;
		public var hp:int;
		
		public function Breakable(textureName:String, x:int, y:int) {
			super(Root.assets.getTextureAtlas("sprites").getTexture(textureName + ".png"));
			touchable = false;
			alignPivot();
			tag = textureName;
			hp = 1;
			
			this.x = x;
			this.y = y;
		}
		
		override public function get x():Number { return super.x / Game.UNIT; }
		override public function set x(value:Number):void { super.x = value * Game.UNIT; }
		override public function get y():Number { return super.y / Game.UNIT; }
		override public function set y(value:Number):void { super.y = value * Game.UNIT; }
		
		public function takeDamage(damage:int):void {
			hp -= damage;
			if (hp <= 0) {
				kill();
			}
		}
		
		private function kill():void {
			Starling.juggler.tween(this, 0.3, { scaleX:1.5, scaleY:1.5, alpha:0.0, 
				transition:Transitions.EASE_IN_BACK, onComplete:destroy });
		}
		
		private function destroy():void {
			removeFromParent(true);
		}
		
	}

}