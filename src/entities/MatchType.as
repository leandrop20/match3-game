package entities {
	import enums.TypeOfMatch;
	/**
	 * ...
	 * @author LeandroP
	 */
	public class MatchType {
		public var type:TypeOfMatch;
		public var color:String;
		
		public function MatchType() {
			type = TypeOfMatch.DEFAULT;
			color = "";
		}
		
	}

}