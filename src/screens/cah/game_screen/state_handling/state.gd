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
	ROLE_CONNECTING # only used internally by the server
}
const ROLE_PLAYER: PlayerRole = PlayerRole.ROLE_PLAYER
const ROLE_JUDGE: PlayerRole = PlayerRole.ROLE_JUDGE
const ROLE_SPECTATOR: PlayerRole = PlayerRole.ROLE_SPECTATOR
const ROLE_CONNECTING: PlayerRole = PlayerRole.ROLE_CONNECTING

static func new_choice_group(cards: Array[String], player: String) -> Dictionary:
	return {
		"cards": cards,
		"player": player
	}

#region STATE
var player_role: PlayerRole = PlayerRole.ROLE_PLAYER

var current_judge: String = ""

var previous_game_state: GameState = GameState.STATE_CONNECTING
var current_game_state: GameState = GameState.STATE_CONNECTING

var black_cards = []
var choice_groups = []
#endregion STATE


static func dummy_state() -> CAHState:
	var state = CAHState.new()
	state.player_role = PlayerRole.ROLE_PLAYER
	state.previous_game_state = GameState.STATE_CONNECTING
	state.current_game_state = GameState.STATE_JUDGEMENT
	
	state.black_cards = [{"text": "Say my name.", "pick":1}]
	state.choice_groups = [
		{"cards":["carta grupo 1", "ca2"], "player":"j"},
	]
	
	return state
