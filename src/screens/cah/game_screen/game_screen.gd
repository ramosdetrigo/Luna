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
	%TopLabel.set_text_instant("")
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	#region screen_nodes
	screen_nodes.top_label = %TopLabel
	screen_nodes.split_container = %VSplitContainer
	
	screen_nodes.bottom_button = %BottomButton
	screen_nodes.button_controller = %BBControl
	
	screen_nodes.judge_scroller = %JudgeScroller
	screen_nodes.card_scroller = %CardScroller
	screen_nodes.scroller_split = %ScrollerSplit
	
	screen_nodes.left_card_slot = %LeftCardSlot
	screen_nodes.right_card_slot = %RightCardSlot
	screen_nodes.center_card_slot = %CenterCardSlot
	screen_nodes.white_card_holder = %WhiteCardHolder
	
	screen_nodes.confetti = %Confetti
	screen_nodes.client = %Client
	#endregion screen_nodes
	
	#%Server.create_server() # NOTE: DEBUG PURPOSES ONLY!
	
	#game_state = CAHState.dummy_state()
	#%Client.add_cards(["card1", "card2", "card3", "card4", "card5", "card6", "card7", "card8", "card9", "card10"])
	#_on_client_state_updated()
	#%ConnectingPanel.toggle_visible(false)
	
	_on_viewport_size_changed()
	%ScrollerSplit.update_offset(false)
	%SpectateButton.set_toggled(false)
	
	%ConnectingPanel.toggle_visible(true)
	%Client.game_state = game_state
	%Client.create_client()


func _on_client_state_updated() -> void:
	if state_handler:
		remove_child(state_handler)
		state_handler.queue_free()
	state_handler = handlers[game_state.current_game_state].new(game_state, screen_nodes)
	add_child(state_handler)


#region BASIC_UI
# TODO: mobile layout.
# Dynamic resize that matches most resolutions nicely
func _on_viewport_size_changed() -> void:
	# we don't need this because anchors 😎
	#size = get_viewport_rect().size
	var new_scale = size / Vector2(1280, 720)
	
	var width_guess = max(450 * new_scale.y, 450)
	if size.x > 450 and width_guess < size.x*0.9:
		%CenterControl.custom_minimum_size.x = width_guess
	else:
		%CenterControl.custom_minimum_size.x = size.x*0.9
	
	# Set up split container height
	await %VSplitContainer.resized
	var normal_offset = %VSplitContainer.size.y/13.0
	var expanded_offset = %VSplitContainer.size.y / 2.0
	%VSplitContainer.normal_offset = normal_offset
	%VSplitContainer.expanded_offset = expanded_offset
	%VSplitContainer.update_offset()
	var width = size.x
	var margin_size = (2.0/5.0) * width
	%VSplitContainer.drag_area_margin_begin = margin_size
	%VSplitContainer.drag_area_margin_end = margin_size
	
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


func exit_game(reason: String = "DESCONECTADO.") -> void:
	%Client.multiplayer.multiplayer_peer.close()
	%Client.multiplayer.multiplayer_peer = null
	%Client.queue_free()
	scale_fade(true)
	if reason == "VOCÊ SAIU DO JOGO.":
		Global.play_audio(Global.SFX[3])
	else:
		Global.play_audio(Global.SFX[2])
	Global.DISCONNECT_REASON = reason
	change_scene.emit(Global.SCREENS[3])


func _on_exit_button_pressed() -> void:
	%ConfirmPanel.set_text("Deseja sair do jogo?")
	%ConfirmPanel.fade(false, false)
	%ConfirmPanel.ok_pressed.connect(exit_game.bind("VOCÊ SAIU DO JOGO."), CONNECT_ONE_SHOT)


func _on_chat_button_toggled(toggled: bool) -> void:
	%NotifyBall.hide()
	%Chat.fade(not toggled, false)


func _on_confirm_panel_cancel_pressed() -> void:
	%ConfirmPanel.fade(true, false)


func _on_player_list_button_toggled(toggled: bool) -> void:
	%PlayerList.fade(not toggled, false)
