'PlayButton'
extends Button


func _ready():
	grab_focus() # PlayButton starts focused for menu navigation


func _pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
	GameManager.engage()
