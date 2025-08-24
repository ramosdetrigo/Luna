class_name CAHState
extends Object

enum GameState {
	STATE_CHOOSE_BLACK,
	STATE_CHOOSE_WHITE,
	STATE_JUDGEMENT,
	STATE_WINNER,
	STATE_CONNECTING,
}
const STATE_CHOOSE_BLACK: GameState = GameState.STATE_CHOOSE_BLACK
const STATE_CHOOSE_WHITE: GameState = GameState.STATE_CHOOSE_WHITE
const STATE_JUDGEMENT: GameState = GameState.STATE_JUDGEMENT
const STATE_WINNER: GameState = GameState.STATE_WINNER
const STATE_CONNECTING: GameState = GameState.STATE_CONNECTING

enum PlayerRole {
	ROLE_PLAYER,
	ROLE_JUDGE,
	ROLE_SPECTATOR,
}
const ROLE_PLAYER: PlayerRole = PlayerRole.ROLE_PLAYER
const ROLE_JUDGE: PlayerRole = PlayerRole.ROLE_JUDGE
const ROLE_SPECTATOR: PlayerRole = PlayerRole.ROLE_SPECTATOR

var player_role: PlayerRole = PlayerRole.ROLE_PLAYER
var previous_game_state: GameState = GameState.STATE_CONNECTING
var current_game_state: GameState = GameState.STATE_CONNECTING

var black_cards = []
var white_cards = []
var choice_groups = []

var white_choices: int = 0
var winner_name: String = ""
var debug_state: bool = false


static func dummy_state() -> CAHState:
	var state = CAHState.new()
	state.player_role = PlayerRole.ROLE_JUDGE
	state.previous_game_state = GameState.STATE_CONNECTING
	state.current_game_state = GameState.STATE_WINNER
	
	state.black_cards = ["Say my name."]
	state.white_cards = []
	state.choice_groups = [["Joaquim.", "Joaquim.", "Joaquim."]]
	for i in range(10): state.white_cards.push_back("Carta %d" % i)
	
	state.white_choices = 0
	state.winner_name = "Joaquim"
	
	state.debug_state = true
	return state
