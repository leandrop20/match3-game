package {
	//import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	import starling.events.ResizeEvent;
	
	/**
	 * ...
	 * @author LeandroP
	 */
	public class Main extends Sprite {
		public static const SIZE:Point = new Point(480, 854);
		/** objects */
		private var starling:Starling;
		
		public function Main() {
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			Starling.handleLostContext = true;
			starling = new Starling(Root, stage);
			starling.antiAliasing = 1;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			starling.start();
			stage.addEventListener(ResizeEvent.RESIZE, resizeStage);
		}
		
		private function resizeStage(e:Event):void {
			var viewPortRectangle:Rectangle = new Rectangle();
			if (Main.SIZE.x > Main.SIZE.y) {
				viewPortRectangle.width = stage.stageWidth;
				viewPortRectangle.height = viewPortRectangle.width * 0.5859375;
				if (viewPortRectangle.height > stage.stageHeight) {
					viewPortRectangle.height = stage.stageHeight;
					viewPortRectangle.width = viewPortRectangle.height / 0.5859375;
				}
			} else {
				viewPortRectangle.height = stage.stageHeight;
				viewPortRectangle.width = viewPortRectangle.height * 0.5859375;
				if (viewPortRectangle.width > stage.stageWidth) {
					viewPortRectangle.width = stage.stageWidth;
					viewPortRectangle.height = viewPortRectangle.width / 0.5859375;
				}
			}
			//Centers the viewPort so you have black bars around it
			viewPortRectangle.x = (stage.stageWidth - viewPortRectangle.width) / 2;
			viewPortRectangle.y = (stage.stageHeight - viewPortRectangle.height) / 2;
			
			Starling.current.viewPort = viewPortRectangle;
		}
		
		private function onEnterFrame(e:Event):void {
			if (starling.isStarted && starling.root) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				Root(starling.root).Init();
			}
		}
		
		private function deactivate(e:Event):void {
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		
	}
	
}