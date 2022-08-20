'SFXToggle'
extends CheckButton


func _ready():
	pressed = not SfxManager.is_mute()
	

func _toggled(_button_pressed):	
	SfxManager.set_mute(not pressed)
#	var index = AudioServer.get_bus_index("SFX")
#	AudioServer.set_bus_volume_db(index, 1.0 if toggle_mode else 0.0)


func _pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
