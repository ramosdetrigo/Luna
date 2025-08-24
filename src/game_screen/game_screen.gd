extends Screen

var game_info: CAHState = CAHState.new()
var screen_nodes: CAHNodes = CAHNodes.new()
var state_handler: CAHStateHandler
var next_state: CAHState.GameState

func _ready() -> void:
	#region screen_nodes
	screen_nodes.top_label = %TopLabel
	screen_nodes.split_container = %VSplitContainer
	
	screen_nodes.bottom_button = %BottomButton
	screen_nodes.button_controller = %BBControl
	
	screen_nodes.judge_scroller = %JudgeScroller
	screen_nodes.card_scroller = %CardScroller
	
	screen_nodes.card_slot = %CardSlot
	screen_nodes.card_slot_edge = %CardSlotEdge
	screen_nodes.white_card_holder = %WhiteCardHolder
	#endregion screen_nodes
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	# TODO: wait for new state from server
	game_info = CAHState.dummy_state()
	update_state()
	handle_state()


func handle_state() -> void:
	game_info.previous_game_state = game_info.current_game_state
	game_info.current_game_state = next_state
	#match next_state:
		#CAHState.


func update_state() -> void:
	if game_info.debug_state:
		match game_info.current_game_state: 
			CAHState.STATE_CHOOSE_BLACK:
				game_info.player_role = CAHState.ROLE_JUDGE
				next_state = CAHState.STATE_CHOOSE_WHITE
			CAHState.STATE_CHOOSE_WHITE:
				game_info.player_role = CAHState.ROLE_PLAYER
				next_state = CAHState.STATE_JUDGEMENT
			CAHState.STATE_WINNER:
				game_info.player_role = CAHState.ROLE_PLAYER
				next_state = CAHState.STATE_CHOOSE_BLACK
			CAHState.STATE_CONNECTING: next_state = CAHState.STATE_CHOOSE_BLACK
#region BASIC_UI
func _on_send_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%SendButton.text = "Cancelar"
	else:
		%SendButton.text = "Confirmar"


# TODO: this could definetly be improved.
# Dynamic resize that matches most resolutions nicely
func _on_viewport_size_changed() -> void:
	self.size = get_viewport_rect().size
	var new_scale = self.size / Vector2(1280, 720)
	
	var width_guess = max(400 * new_scale.y, 400)
	if size.x > 400 and width_guess < size.x*0.9:
		%CenterControl.custom_minimum_size.x = width_guess
	else:
		%CenterControl.custom_minimum_size.x = size.x*0.9
	%VSplitContainer.split_offset = %VSplitContainer.size.y/13.0
	
	%TopLabel.custom_minimum_size.x = 400 * new_scale.y
	%TopLabel.add_theme_font_size_override("normal_font_size", 40 * new_scale.y)
	
	%BottomButton.custom_minimum_size.x = 360 * new_scale.y
	%BottomButton.add_theme_font_size_override("font_size", 24 * new_scale.y)
#endregion
