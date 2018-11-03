package enums {
	/**
	 * ...
	 * @author LeandroP
	 */
	public class TypeOfMatch {
		public static const DEFAULT:TypeOfMatch = new TypeOfMatch(DEFAULT);
		public static const COLOR_BOMB:TypeOfMatch = new TypeOfMatch(COLOR_BOMB);
		public static const ADJACENT_BOMB:TypeOfMatch = new TypeOfMatch(ADJACENT_BOMB);
		public static const COLUMN_OR_ROW_BOMB:TypeOfMatch = 
			new TypeOfMatch(COLUMN_OR_ROW_BOMB);
		
		public function TypeOfMatch(typeOfMatch:TypeOfMatch) { }
		
	}

}