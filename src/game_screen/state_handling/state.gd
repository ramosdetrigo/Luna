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
var new_white_cards = []
var choice_groups = []

var white_choices: int = 0
var winner_name: String = ""
var debug_state: bool = false


static func dummy_state() -> CAHState:
	var state = CAHState.new()
	state.player_role = PlayerRole.ROLE_PLAYER
	state.previous_game_state = GameState.STATE_CONNECTING
	state.current_game_state = GameState.STATE_CHOOSE_WHITE
	
	state.black_cards = ["Say my name."]
	state.choice_groups = [
		["A1.", "A2.\nA2", "A3.\nA3\nA3"],
		["B1.", "B2.\nB2", "B3.\nB3\nB3"],
		["C1.", "C2.\nC2", "C3.\nC3\nC3"],
		["D1.", "D2.\nD2", "D3.\nD3\nD3"],
		["E1.", "E2.\nE2", "E3.\nE3\nE3"],
		["F1.", "F2.\nF2", "F3.\nF3\nF3"],
		["G1.", "G2.\nG2", "G3.\nG3\nG3"],
		["H1.", "H2.\nH2", "H3.\nH3\nH3"],
		["I1.", "I2.\nI2", "I3.\nI3\nI3"],
		["J1.", "J2.\nJ2", "J3.\nJ3\nJ3"]
	]


	for i in range(10): state.new_white_cards.push_back("Carta %d" % (i+1))
	
	state.white_choices = 3
	state.winner_name = "Joaquim"
	
	state.debug_state = true
	return state
