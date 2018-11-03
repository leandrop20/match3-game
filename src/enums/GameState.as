package enums {
	/**
	 * ...
	 * @author LeandroP
	 */
	public class GameState {
		public static const WAIT:GameState = new GameState(WAIT);
		public static const MOVE:GameState = new GameState(MOVE);
		public static const WIN:GameState = new GameState(WIN);
		public static const LOSE:GameState = new GameState(LOSE);
		public static const PAUSE:GameState = new GameState(PAUSE);
		
		public function GameState(gameState:GameState) { }
		
	}

}