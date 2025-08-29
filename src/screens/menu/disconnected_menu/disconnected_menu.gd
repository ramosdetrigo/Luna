extends Screen


func _ready() -> void:
	%Desconectado.text = Global.DISCONNECT_REASON


func _on_sair_pressed():
	scale_fade(true)
	change_scene.emit(Global.SCREENS[0])
