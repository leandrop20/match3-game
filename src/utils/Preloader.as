package utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureOptions;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author LeleoSan
	 */
	public class Preloader extends Sprite {
		[Embed(source = "../../logoSearching.png")]
		private static const LOGO:Class;
		
		/** parameters */
		private var callBack:Function;
		/** objects */
		private var img:Image;
		private var bar:Image;
		/** consts */
		private const ASSETS:Array = new Array("animations", "fonts", "images", "particles", "sounds");
		/** variables */
		private var totalData:int;
		private var totalGroup:int;
		private var totalItem:int;
		private var dataName:String;
		private var stepData:int;
		private var stepGroup:int;
		private var stepItem:int;
		private var group:XML;
		private var pctPerGroup:Number;
		private var pctPerItem:Number;
		private var descriptionLoad:String;
		private var prefix:String;
		
		public function Preloader(_callBack:Function) {
			touchable = false;
			callBack = _callBack;
			
			totalData = ASSETS.length;
			stepData = 0;
			stepGroup = 0;
			stepItem = 0;
			prefix = "assets/";
			
			img = new Image(Texture.fromBitmap(new Preloader.LOGO() as Bitmap));
			img.alignPivot();
			img.x = Main.SIZE.x * 0.5;
			img.y = Main.SIZE.y * 0.5;
			img.alpha = 0.0;
			addChild(img);
			Starling.juggler.tween(img, 0.3, { alpha:1.0 } );
			
			var boxBar:Sprite = new Sprite();
			boxBar.alignPivot(HAlign.RIGHT);
			boxBar.x = (Main.SIZE.x * 0.5);
			boxBar.y = (Main.SIZE.y * 0.5) + 50;
			addChild(boxBar);
			
			var bgBar:Image = new Image(Texture.fromBitmapData(new BitmapData(220, 10, false, 0x353535)));
			bgBar.alignPivot();
			boxBar.addChild(bgBar);
			
			bar = new Image(Texture.fromBitmapData(new BitmapData(216, 6, false, 0xCA4200)));
			bar.alignPivot(HAlign.LEFT, VAlign.CENTER);
			bar.x = -(bar.width * 0.5);
			bar.scaleX = 0.0;
			boxBar.addChild(bar);
			
			Starling.juggler.tween(boxBar, 0.3, { alpha:0.0, reverse:true, repeatCount:0 });
			
			if (Capabilities.playerType == "Desktop") {
				startMobile();
			} else {
				loadList(prefix + "xmls/" + ASSETS[stepData] + ".xml", handlerData);
			}
		}
		
		private function startMobile():void {
			var appDir:File = File.applicationDirectory;
			Root.assets.enqueue(appDir.resolvePath("assets/xmls"));
			
			Root.assets.loadQueue(progress);
			function progress(n:Number):void
			{
				//loader.txt.text = Math.floor(n) + "%";
				bar.scaleX = n;
				if (n == 1) {
					handlerData(Root.assets.getXml(ASSETS[stepData]));
				}
			}
		}
		
		private function loadList(url:String, callBack:Function = null):void {
			var load:URLLoader = new URLLoader();
			load.addEventListener(Event.COMPLETE, complete);
			load.addEventListener(IOErrorEvent.IO_ERROR, handlerError);
			var req:URLRequest = new URLRequest(url + "?nocache=" + Math.random() * 9999);
			load.load(req);
			function complete(e:Event):void {
				load.removeEventListener(Event.COMPLETE, complete);
				load.removeEventListener(IOErrorEvent.IO_ERROR, handlerError);
				if (callBack != null) {
					callBack(e.target);
				}
			}
		}
		
		private function handlerError(e:IOErrorEvent):void {
			trace(e.text);
		}
		
		private function handlerData(data:Object):void {
			//loader.txt.text = "" + (0.01 * 100) + "%";
			bar.scaleX = (0.01 * 100) / 100;
			if (Capabilities.playerType == "Desktop") {
				group = XML(data);
			} else {
				group = XML(data.data);
			}
			var oldName:String = ASSETS[stepData];
			dataName = oldName.substr(0, oldName.length - 1);
			
			pctPerGroup = (19 / int(group[dataName].length())) / 100;
			totalGroup = int(group[dataName].length());
			stepGroup = 0;
			
			if (group.children().length() > 0) {
				loadItem(dataName, group[dataName][stepGroup]);
			} else {
				stepData++;
				if (totalData == stepData) {
					startLoading();//FINISHED
				} else {
					if (Capabilities.playerType == "Desktop") {
						handlerData(Root.assets.getXml(ASSETS[stepData]));
					} else {
						if (prefix.indexOf("modulo") != -1 && ASSETS[stepData] == "particles") {
							stepData++;
						}
						loadList(prefix + "xmls/" + ASSETS[stepData] + ".xml", handlerData);
					}
				}
			}
		}
		
		private function loadItem(name:String, group:XML):void {
			var preUrl:String = prefix.replace("assets/", "");
			if (Capabilities.playerType == "Desktop") { preUrl = ""; }
			
			descriptionLoad = group.@description;
			totalItem = group.children().length();
			pctPerItem = Number(Number(pctPerGroup / totalItem).toFixed(3));
			switch (int(group.@type)) {
				case 3://ANIMES
					if (stepItem == 0) {
						Root.assets.enqueue(preUrl + group.ske + "?nocache=" + Math.random() * 9999);
						Root.assets.enqueue(preUrl + group.xml + "?nocache=" + Math.random() * 9999);
						Root.assets.enqueue(preUrl + group.image + "?nocache=" + Math.random() * 9999);
					}
					break;
				case 2://SPRITESHEET, BITMAPFONT, PARTICLE
					if (stepItem == 0) {
						Root.assets.enqueue(preUrl + group.xml + "?nocache=" + Math.random() * 9999);
						Root.assets.enqueue(preUrl + group.image + "?nocache=" + Math.random() * 9999);
					}
					break;
				case 1://SOUND, IMAGES
					var _name:String = group;
					if ((String(_name).indexOf(".png") != -1 || String(_name).indexOf(".jpg") != -1) && Boolean(group.@repeat) == true) {
						Root.assets.enqueueWithName(preUrl + _name, null, new TextureOptions(1.0, false, "bgra", true));
					} else {
						//Root.assets.enqueue(Main.urlFiles + group);
						Root.assets.enqueue(preUrl + group + "?nocache=" + Math.random() * 9999);
					}
					break;
			}
			handlerItem();
		}
		
		private function handlerItem():void {
			stepItem++;
			
			if (totalItem == stepItem) {
				stepItem = 0;
				stepGroup++;
				if (totalGroup == stepGroup) {
					stepData++;
					if (totalData == stepData) {
						startLoading();//FINISHED
					} else {
						if (Capabilities.playerType == "Desktop") {
							handlerData(Root.assets.getXml(ASSETS[stepData]));
						} else {
							if (prefix.indexOf("modulo") != -1 && ASSETS[stepData] == "particles") {
								stepData++;
							}
							loadList(prefix + "xmls/" + ASSETS[stepData] + ".xml", handlerData);
						}
					}
				} else {
					loadItem(dataName, group[dataName][stepGroup]);
				}
			} else {
				loadItem(dataName, group[dataName][stepGroup]);
			}
		}
		
		private function startLoading():void {
			Root.assets.loadQueue(progress);
			function progress(n:Number):void {
				//loader.txt.text = Math.floor(n * 100) + "%";
				bar.scaleX = n;
				if (n == 1) {
					callBack();
				}
			}
		}
		
		public function destroy():void {
			removeChildren(0, -1, true);
			removeFromParent(true);
		}
		
	}

}