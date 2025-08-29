extends Panel
class_name PlayerEntry

signal vote_kicked(id: int)

var id: int = 0
@export
var player_role: CAHState.PlayerRole = CAHState.ROLE_PLAYER
@export
var player_win_count: int = 0
@export
var player_name: String = ""
@export
var kick_vote_count: int = 0
@export
var kick_vote_target: int = 0
@export
var player_ready: bool = true

var RED: Color = Color.hex(0xd20f39ff)
var BLUE: Color = Color.hex(0x04a5e5ff)
var YELLOW: Color = Color.hex(0xdf8e1dff)

const JUDGE_ICON: CompressedTexture2D = preload("res://assets/images/ui/judge.png")
const PLAYER_ICON: CompressedTexture2D = preload("res://assets/images/ui/singleplayer.png")
const SPECTATOR_ICON: CompressedTexture2D = preload("res://assets/images/ui/eye_white.png")


func _ready() -> void:
	set_player_role(player_role)
	set_player_name(player_name)
	set_player_win_count(player_win_count)
	set_player_kick_count(kick_vote_count, kick_vote_target)
	set_player_ready(player_ready)
	%KickButton.pivot_offset = Vector2(30.0, 30.0)
	_on_resized()


func _on_resized() -> void:
	var sqr = Vector2(size.y, size.y)
	%RoleImage.custom_minimum_size = sqr
	%Checkmark.custom_minimum_size = sqr
	%Trophy.custom_minimum_size = sqr
	%KickButtonContainer.custom_minimum_size = sqr
	var kick_scale = (size.y - 40.0) / 60.0
	%KickButton.scale = Vector2(kick_scale, kick_scale)
	
	var font_size = 32 * size.y/80
	%PlayerName.add_theme_font_size_override("font_size", font_size)
	%WinCount.add_theme_font_size_override("font_size", font_size)
	%KickCount.add_theme_font_size_override("font_size", font_size)


func set_player_id(new_id: int) -> void:
	id = new_id


func set_player_role(role: CAHState.PlayerRole) -> void:
	player_role = role
	match role:
		CAHState.ROLE_JUDGE:
			%RoleImage.texture = JUDGE_ICON
			%RoleImage.modulate = RED
		CAHState.ROLE_PLAYER:
			%RoleImage.texture = PLAYER_ICON
			%RoleImage.modulate = BLUE
		_:
			%RoleImage.texture = SPECTATOR_ICON
			%RoleImage.modulate = YELLOW


func set_player_name(new_name: String) -> void:
	player_name = new_name
	%PlayerName.text = new_name


func set_player_win_count(win_count: int) -> void:
	player_win_count = win_count
	%WinCount.text = str(win_count)


func set_player_kick_count(kick_count: int, kick_target: int) -> void:
	kick_vote_count = kick_count
	kick_vote_target = kick_target
	%KickCount.text = "%d/%d" % [kick_count, kick_target]


func set_player_ready(is_ready: bool) -> void:
	player_ready = is_ready
	%Checkmark.visible = is_ready


func _on_kick_button_pressed() -> void:
	vote_kicked.emit(id)
