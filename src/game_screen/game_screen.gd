extends Screen

var game_state: CAHState = CAHState.new()
var screen_nodes: CAHNodes = CAHNodes.new()
var state_handler: CAHStateHandler
var next_state: CAHState.GameState

var handlers = {
	CAHState.STATE_CONNECTING: ConnectingState,
	CAHState.STATE_CHOOSE_BLACK: ChooseBlackState,
	CAHState.STATE_CHOOSE_WHITE: ChooseWhiteState,
	CAHState.STATE_JUDGEMENT: JudgementState,
	CAHState.STATE_WINNER: WinnerState,
}

func _ready() -> void:
	# or else the resizing won't work for some reason
	await %VSplitContainer.resized
	#region screen_nodes
	screen_nodes.top_label = %TopLabel
	screen_nodes.split_container = %VSplitContainer
	
	screen_nodes.bottom_button = %BottomButton
	screen_nodes.button_controller = %BBControl
	
	screen_nodes.judge_scroller = %JudgeScroller
	screen_nodes.card_scroller = %CardScroller
	
	screen_nodes.left_card_slot = %LeftCardSlot
	screen_nodes.right_card_slot = %RightCardSlot
	screen_nodes.center_card_slot = %CenterCardSlot
	screen_nodes.white_card_holder = %WhiteCardHolder
	
	screen_nodes.confetti = %Confetti
	#endregion screen_nodes
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	%TopLabel.set_text_instant("")
	game_state = CAHState.dummy_state()
	server_update()
	
	_on_viewport_size_changed()


# TODO: wait for new state from server
func server_update() -> void:
	update_state()
	switch_state_handler()


func stop_state_handler() -> void:
	if state_handler:
		remove_child(state_handler)
		state_handler.queue_free()


func switch_state_handler() -> void:
	stop_state_handler()
	game_state.previous_game_state = game_state.current_game_state
	game_state.current_game_state = next_state
	state_handler = handlers[next_state].new(game_state, screen_nodes)
	add_child(state_handler)


func update_state() -> void:
	if game_state.debug_state:
		next_state = game_state.current_game_state
		return


#region BASIC_UI
func _on_send_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%SendButton.text = "Cancelar"
	else:
		%SendButton.text = "Confirmar"


# TODO: this could definetly be improved.
# Dynamic resize that matches most resolutions nicely
func _on_viewport_size_changed() -> void:
	# we don't need this because anchors 😎
	#size = get_viewport_rect().size
	var new_scale = size / Vector2(1280, 720)
	
	var width_guess = max(400 * new_scale.y, 400)
	if size.x > 400 and width_guess < size.x*0.9:
		%CenterControl.custom_minimum_size.x = width_guess
	else:
		%CenterControl.custom_minimum_size.x = size.x*0.9
	if (game_state.current_game_state != CAHState.STATE_CHOOSE_BLACK
	and game_state.current_game_state != CAHState.STATE_WINNER):
		%VSplitContainer.split_offset = %VSplitContainer.size.y/13.0
	
	%TopLabel.custom_minimum_size.x = 510 * new_scale.y
	%TopLabel.add_theme_font_size_override("normal_font_size", 40 * new_scale.y)
	%LabelControl.custom_minimum_size = %TopLabel.custom_minimum_size
	
	%BottomButton.custom_minimum_size.x = 360 * new_scale.y
	%BottomButton.add_theme_font_size_override("font_size", 24 * new_scale.y)
	
	%Confetti.initial_velocity_min = 250 * new_scale.y
	%Confetti.initial_velocity_max = 550 * new_scale.y
	if %Confetti.emitting:
		%Confetti.finished.connect(func():
			%Confetti.amount = 150 * new_scale.y
		)
#endregion
