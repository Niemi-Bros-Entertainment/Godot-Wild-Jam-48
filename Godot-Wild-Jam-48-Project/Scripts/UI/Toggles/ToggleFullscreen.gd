'ToggleFullscreen'
extends CheckButton


func _ready():
	pressed = OS.window_fullscreen
	

func _toggled(_button_pressed):
	#OS.set_window_fullscreen(pressed)
	OS.call_deferred("set_window_fullscreen", pressed)


func _pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
