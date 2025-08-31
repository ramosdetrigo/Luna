class_name RoomEntry
extends PanelContainer

signal clicked(toggled: bool)

var PURPLE: Color = Color.hex(0x6b5ae8ff)

@export
var room_name: String = ""
@export
var player_count: int = 0
@export
var has_password: bool = false

var is_selected: bool = false

const LOCKED_TEXTURE: CompressedTexture2D = preload("res://assets/images/ui/locked.png")
const UNLOCKED_TEXTURE: CompressedTexture2D = preload("res://assets/images/ui/unlocked.png")

func _ready() -> void:
	%RoomName.text = room_name
	%PlayerCount.text = str(player_count)
	if has_password:
		%Lock.texture = LOCKED_TEXTURE
	else:
		%Lock.texture = UNLOCKED_TEXTURE


func _on_gui_input(event: InputEvent) -> void:
	if not(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released()):
		return
	set_selected(not is_selected)
	clicked.emit(is_selected)


func set_selected(toggle: bool) -> void:
	is_selected = toggle
	if is_selected:
		modulate = PURPLE
	else:
		modulate = Color.WHITE
