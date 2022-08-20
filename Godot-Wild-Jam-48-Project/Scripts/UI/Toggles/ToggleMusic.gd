'MusicToggle'
extends CheckButton


func _ready():
	pressed = not MusicManager.is_mute()


func _toggled(_button_pressed):	
	MusicManager.set_mute(not pressed)


func _pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
