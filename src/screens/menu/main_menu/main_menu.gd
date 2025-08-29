extends Screen


# Called when the node enters the scene tree for the first time.
func _ready():
	%Jogar.set_mouse_filter(MOUSE_FILTER_STOP)
	%Hostear.set_mouse_filter(MOUSE_FILTER_STOP)
	%Sair.set_mouse_filter(MOUSE_FILTER_STOP)


func _on_jogar_pressed():
	disable_interactive()
	scale_fade(true)
	change_scene.emit(Global.SCREENS[2])


func _on_hostear_pressed():
	disable_interactive()
	scale_fade(true)
	change_scene.emit(Global.SCREENS[1])



func _on_sair_pressed():
	Global.save_configs()
	get_tree().quit()


func disable_interactive() -> void:
	%Jogar.set_mouse_filter(MOUSE_FILTER_IGNORE)
	%Hostear.set_mouse_filter(MOUSE_FILTER_IGNORE)
	%Sair.set_mouse_filter(MOUSE_FILTER_IGNORE)
